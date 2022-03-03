{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE NoImplicitPrelude          #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE TypeApplications           #-}
{-# LANGUAGE TypeFamilies               #-}
{-# LANGUAGE DerivingStrategies         #-}
{-# OPTIONS_GHC -Wno-unused-matches #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# OPTIONS_GHC -Wno-deferred-out-of-scope-variables #-}

module Validate.Onchain
    ( apiBuyScript
    , buyScriptAsShortBs
    , typedBuyValidator
    , Typed
    , buyValidator
    , buyValidatorHash
    ) where

import qualified Data.ByteString.Lazy  as LB
import qualified Data.ByteString.Short as SBS
import           Codec.Serialise       ( serialise )

import           Cardano.Api.Shelley (PlutusScript (..), PlutusScriptV1, TxOutValue (TxOutValue))
import qualified PlutusTx
import Plutus.Trace.Emulator as Emulator
import PlutusTx.Prelude as Plutus
    ( Bool(..), Eq((==)), (.), (||), length, (&&), Integer, Maybe(..), (>=), fromInteger, (*), ($), (%), (-), map, traceIfFalse, BuiltinData, Group (inv) )
import Ledger
    ( PubKeyHash(..),
      ValidatorHash,
      Address(Address),
      validatorHash,
      DatumHash,
      Datum(..),
      txOutDatum,
      txSignedBy,
      ScriptContext(scriptContextTxInfo),
      ownHash,
      TxInfo,
      Validator,
      TxOut (TxOut, txOutValue),
      txInfoSignatories,
      unValidatorScript,
      txInInfoResolved,
      txInfoInputs,
      txInfoOutputs,
      valuePaidTo,
      txOutAddress, valueProduced, value, Value, Tx (txOutputs), getContinuingOutputs, findDatum)
import qualified Ledger.Typed.Scripts      as Scripts
import qualified Plutus.V1.Ledger.Scripts as Plutus
import           Ledger.Value              as Value ( valueOf, CurrencySymbol (CurrencySymbol), TokenName (TokenName), Value (Value) )
import qualified Plutus.V1.Ledger.Ada as Ada (fromValue, Ada (getLovelace), lovelaceValueOf)
import           Plutus.V1.Ledger.Credential (Credential(ScriptCredential))


import GHC.Show
import Prelude (error, putStrLn)
import           PlutusTx.Prelude     hiding (unless)
import Data.Aeson.Types (Value(Bool, String))
import qualified Plutus.V1.Ledger.Ada as ADA
import Data.Text.Lazy (Text)
import GHC.Exts (Char)
import qualified Ledger as Plutus.V1.Ledger
import qualified Plutus.V2.Ledger.Contexts as Plutus
import Ledger.Contexts (TxInInfo)
import Debug.Trace ()
import Text.Printf ()
import Data.String ()
import qualified Plutus.V1.Ledger.Value as ADA
import qualified Data.ByteString as B
import Data.ByteString
import Data.ByteString.Builder (byteString)
import PSGenerator.Common (integerBridge)

minLovelace :: Integer
minLovelace = 4000000

{-# INLINABLE mkBuyValidator #-}
mkBuyValidator :: Integer -> () -> ScriptContext -> Bool
mkBuyValidator d () ctx = whatDatum
  where
    info :: TxInfo
    info = scriptContextTxInfo ctx

    ownOutput :: TxOut
    ownOutput = case getContinuingOutputs ctx of
        [o] -> o
        _   -> traceError "expected exactly one oracle output"

    valueAmount :: Ledger.Value
    valueAmount = txOutValue ownOutput
    
    -- flattenValue -> flattens the map of maps into a flat list of triples
    flatten ::  [(CurrencySymbol, TokenName, Integer)]
    flatten = ADA.flattenValue valueAmount 

    outValue :: [(CurrencySymbol, TokenName, Integer)] -> Integer
    outValue [(cs, tn, i)] = i
     
    outputHasValue :: Bool
    outputHasValue = traceIfFalse "Incorrect payment amount" $ outValue flatten == minLovelace

    whatDatum :: Bool
    whatDatum = 
        if d == 1970
            then outputHasValue
        else True

data Typed
instance Scripts.ValidatorTypes Typed where
    type instance DatumType Typed    = Integer
    type instance RedeemerType Typed = ()

typedBuyValidator :: Scripts.TypedValidator Typed
typedBuyValidator = Scripts.mkTypedValidator @Typed
    $$(PlutusTx.compile [|| mkBuyValidator ||])
    $$(PlutusTx.compile [|| wrap ||])
  where
    wrap = Scripts.wrapValidator @Integer @()


buyValidator :: Validator
buyValidator = Scripts.validatorScript typedBuyValidator

buyValidatorHash :: ValidatorHash
buyValidatorHash = validatorHash buyValidator

buyScript :: Plutus.V1.Ledger.Script
buyScript = Ledger.unValidatorScript buyValidator

buyScriptAsShortBs :: SBS.ShortByteString
buyScriptAsShortBs = SBS.toShort . LB.toStrict $ serialise buyScript

apiBuyScript :: PlutusScript PlutusScriptV1
apiBuyScript = PlutusScriptSerialised buyScriptAsShortBs