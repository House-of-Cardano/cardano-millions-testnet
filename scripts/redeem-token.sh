#!/bin/bash

# arguments:
# 1:- utxo containing the Cardano Millions Tokens
# 2:- utxo for funding

echo "Building & submitting the transaction to transfer CMT to player..."

cardano-cli transaction build \
--alonzo-era \
--$testnet \
--tx-in $1 \
--tx-in-script-file ./plutus-scripts/validate-payment.plutus \
--tx-in-datum-value 1970 \
--tx-in-redeemer-file ./scripts/unit.json \
--tx-in $2 \
--tx-in-collateral $2 \
--tx-out "$player1 + $minAdaAmount + 1 $policyid.$tokenname" \
--tx-out "$scriptAddr + $minLovelaceAmount" \
--tx-out-datum-hash $scriptdatumhash2 \
--change-address $player1 \
--protocol-params-file ./blockchain/protocol.json \
--out-file ./blockchain/test-asset.tx

cardano-cli transaction sign \
--tx-body-file ./blockchain/test-asset.tx \
--signing-key-file ../addresses/player-1-wallet.skey \
--$testnet \
--out-file ./blockchain/test-asset.signed

cardano-cli transaction submit --$testnet --tx-file ./blockchain/test-asset.signed

echo "Done"

echo "cardano-cli query utxo --address $scriptAddr --$testnet"
