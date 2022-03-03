#!/bin/bash

# arguments:
# utxo for funding and collateral

tokenname="434d4c6f74746f546f6b656e"
tokenamount="1"
output="2000000"

mkdir -p ./blockchain/policy

# Generate key pairs ->

cardano-cli address key-gen \
    --verification-key-file ./blockchain/policy/policy.vkey \
    --signing-key-file ./blockchain/policy/policy.skey
    
# Create a policy.script file and fill it with an empty string ->

touch ./blockchain/policy/policy.script && echo "" > ./blockchain/policy/policy.script

# Use the echo command to populate the file ->

echo "{" >> ./blockchain/policy/policy.script 
echo "  \"keyHash\": \"$(cardano-cli address key-hash --payment-verification-key-file ./blockchain/policy/policy.vkey)\"," >> ./blockchain/policy/policy.script 
echo "  \"type\": \"sig\"" >> ./blockchain/policy/policy.script 
echo "}" >> ./blockchain/policy/policy.script

echo "Create policy ID..."

cardano-cli transaction policyid --script-file ./blockchain/policy/policy.script >> ./blockchain/policy/policyID

policyid=$(cat ./blockchain/policy/policyID)
scriptAddr=$(cat ./blockchain/script.addr)

echo "Build and submit the minting transaction to wallet `address2`..."

cardano-cli transaction build \
--alonzo-era \
--$testnet \
--tx-in $1 \
--tx-in-collateral $1 \
--tx-out "$bank+$output+$tokenamount $policyid.$tokenname" \
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