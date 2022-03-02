{-# OPTIONS_GHC -Wno-incomplete-uni-patterns #-}

import Cardano.Api.Shelley
    ( writeFileTextEnvelope,
      Error(displayError),
      PlutusScript,
      PlutusScriptV1,
      ScriptData(ScriptDataNumber),
      toAlonzoData )
import Cardano.Ledger.Alonzo.Data as Alonzo ( Data(Data) )
import qualified Plutus.V1.Ledger.Api as Plutus

import Prelude
import System.Environment ( getArgs )
import qualified Data.ByteString.Short as SBS

import Validate.Onchain  as O2 (apiBuyScript, buyScriptAsShortBs)

main :: IO ()
main = do
    let scriptnum = 1970
    let scriptname = "plutus-scripts/validate-payment.plutus"
    putStrLn $ "Writing output to: " ++ scriptname
    writePlutusScript scriptnum scriptname O2.apiBuyScript O2.buyScriptAsShortBs

writePlutusScript :: Integer -> FilePath -> PlutusScript PlutusScriptV1 -> SBS.ShortByteString -> IO ()
writePlutusScript scriptnum filename scriptSerial scriptSBS =
  do
  case Plutus.defaultCostModelParams of
        Just m ->
          let Alonzo.Data pData = toAlonzoData (ScriptDataNumber scriptnum)
              (logout, e) = Plutus.evaluateScriptCounting Plutus.Verbose m scriptSBS [pData]
          in do print ("Log output" :: String) >> print logout
                case e of
                  Left evalErr -> print ("Eval Error" :: String) >> print evalErr
                  Right exbudget -> print ("Ex Budget" :: String) >> print exbudget
        Nothing -> error "defaultCostModelParams failed"
  result <- writeFileTextEnvelope filename Nothing scriptSerial
  case result of
    Left err -> print $ displayError err
    Right () -> return ()
