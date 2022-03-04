#!/bin/bash

# arguments:
# utxo for funding and collateral

echo "Build and submit the minting transaction to wallet `address2`..."

cardano-cli transaction build \
--alonzo-era \
--$testnet \
--tx-in $1 \
--tx-in-collateral $1 \
--tx-out "$bank+$minAdaAmount+$tokenamount $policyid.$tokenname" \
--change-address $bank \
--mint="$tokenamount $policyid.$tokenname" \
--minting-script-file ./blockchain/policy/policy.script \
--protocol-params-file ./blockchain/protocol.json \
--out-file ./blockchain/mint_tx.raw
 
cardano-cli transaction sign  \
--tx-body-file ./blockchain/mint_tx.raw \
--signing-key-file ../addresses/bank.skey  \
--signing-key-file ./blockchain/policy/policy.skey  \
--$testnet  \
--out-file ./blockchain/mint_tx.signed 

cardano-cli transaction submit --$testnet --tx-file ./blockchain/mint_tx.signed

echo "Done"

echo "Querying wallet address..."

echo "address2 -> "
echo
cardano-cli query utxo --address $bank --$testnet
echo "cardano-cli query utxo --address $bank --$testnet"