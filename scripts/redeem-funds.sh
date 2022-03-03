#!/bin/bash

# arguments:
# 1:- utxo containing the funds locked at the scriptAddr
# 2:- utxo for funding -> from bank

echo "Building & submitting the transaction..."

cardano-cli transaction build \
--alonzo-era \
--$testnet \
--tx-in $1 \
--tx-in-script-file ./plutus-scripts/validate-payment.plutus \
--tx-in-datum-value 2003 \
--tx-in-redeemer-file ./scripts/unit.json \
--tx-in $2 \
--tx-in-collateral $2 \
--tx-out "$cagnotte + 4000000" \
--change-address $bank \
--protocol-params-file ./blockchain/protocol.json \
--out-file ./blockchain/test-asset.tx

cardano-cli transaction sign \
--tx-body-file ./blockchain/test-asset.tx \
--signing-key-file ../addresses/bank.skey \
--$testnet \
--out-file ./blockchain/test-asset.signed

cardano-cli transaction submit --$testnet --tx-file ./blockchain/test-asset.signed

echo "Done"

echo "cardano-cli query utxo --address $scriptAddr --$testnet"
