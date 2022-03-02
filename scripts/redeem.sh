#!/bin/bash

# arguments:
# 1:- utxo containing the Cardano Millions Tokens
# 2:- utxo for funding
# 3:- value for the datum

balanceTokens="1"

echo "Building & submitting the transaction..."

# Removed the redeemer line because should no longer need it for the smart contract ==> NEED unit REPRESENTED AS A json FILE

cardano-cli transaction build \
--alonzo-era \
--$testnet \
--tx-in $1 \
--tx-in-script-file ./plutus-scripts/validate-payment.plutus \
--tx-in-datum-value $3 \
--tx-in-redeemer-file unit.json \
--tx-in $2 \
--tx-in-collateral $2 \
--tx-out "$scriptAddr + 3000000 + $balanceTokens $policyid.$tokenname" \
--tx-out-datum-hash $scriptdatumhash \
--change-address $address3 \
--protocol-params-file ./blockchain/protocol.json \
--out-file ./blockchain/test-asset.tx

cardano-cli transaction sign \
--tx-body-file ./blockchain/test-asset.tx \
--signing-key-file ../addresses/payment2.skey \
--$testnet \
--out-file ./blockchain/test-asset.signed

cardano-cli transaction submit --$testnet --tx-file ./blockchain/test-asset.signed

echo "Done"

echo "cardano-cli query utxo --address $scriptAddr --$testnet"
