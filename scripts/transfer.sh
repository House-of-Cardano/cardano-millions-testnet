#!/bin/bash

# arguments:
# utxo containing the Cardano Millions Tokens

# ------------ Send the Cardano Millions TOkens to the script address -------------------------

# ------------ Has the Datum -------------------------

scriptdatumhash="$(cardano-cli transaction hash-script-data --script-data-value 1970)"
echo $scriptdatumhash

# ------------ Write the transaction using the script address -------------------------

# First tx-in corresponds to the UTxO with the native asset, the second is for payments

cardano-cli transaction build \
--alonzo-era \
--$testnet \
--change-address $address2 \
--tx-in $1 \
--tx-in $2 \
--tx-in-collateral $2 \
--tx-out "$scriptAddr+$output+$tokenamount $policyid.$tokenname" \
--tx-out-datum-hash $scriptdatumhash \
--protocol-params-file protocol.json \
--out-file tx-script.build

# ------------ Sign the transaction -------------------------

cardano-cli transaction sign \
--tx-body-file tx-script.build \
--signing-key-file ../../../addresses/payment1.skey  \
--$testnet \
--out-file tx-script.signed

# ------------ Submit the transaction -------------------------

cardano-cli transaction submit --$testnet --tx-file tx-script.signed

echo "Querying wallet address..."

echo "scriptAddr -> "
echo
cardano-cli query utxo --address $scriptAddr --$testnet
echo "cardano-cli query utxo --address $scriptAddr --$testnet"