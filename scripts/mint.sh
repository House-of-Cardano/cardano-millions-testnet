#!/bin/bash

# arguments:
# utxo for funding and collateral

tokenname="434d4c6f74746f546f6b656e"
tokenamount="1"
output="2000000"

mkdir policy

# Generate key pairs ->

cardano-cli address key-gen \
    --verification-key-file policy/policy.vkey \
    --signing-key-file policy/policy.skey
    
# Create a policy.script file and fill it with an empty string ->

touch policy/policy.script && echo "" > policy/policy.script

# Use the echo command to populate the file ->

echo "{" >> policy/policy.script 
echo "  \"keyHash\": \"$(cardano-cli address key-hash --payment-verification-key-file policy/policy.vkey)\"," >> policy/policy.script 
echo "  \"type\": \"sig\"" >> policy/policy.script 
echo "}" >> policy/policy.script

echo "Create policy ID..."

cardano-cli transaction policyid --script-file ./policy/policy.script >> policy/policyID

policyid=$(cat policy/policyID)
scriptAddr=$(cat script.addr)

echo "Build and submit the minting transaction to wallet `address2`..."

cardano-cli transaction build \
--alonzo-era \
--$testnet \
--tx-in $1 \
--tx-in-collateral $1 \
--tx-out "$address2+$output+$tokenamount $policyid.$tokenname" \
--change-address $address2 \
--mint="$tokenamount $policyid.$tokenname" \
--minting-script-file policy/policy.script \
--protocol-params-file protocol.json \
--out-file mint_tx.raw
 
cardano-cli transaction sign  \
--tx-body-file mint_tx.raw \
--signing-key-file ../../../addresses/payment1.skey  \
--signing-key-file policy/policy.skey  \
--$testnet  \
--out-file mint_tx.signed 

cardano-cli transaction submit --$testnet --tx-file mint_tx.signed

echo "Done"

echo "Querying wallet address..."

echo "address2 -> "
echo
cardano-cli query utxo --address $address2 --$testnet
echo "cardano-cli query utxo --address $address2 --$testnet"