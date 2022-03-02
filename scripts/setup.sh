#!/bin/bash

rm -rf policy/
rm *.raw *.signed *.addr *.build

# ------------ Set-up enrivonment variables -------------------------

echo "Preparing environment variables..."

testnet='testnet-magic 1097911063'
address2="$(cat ../../../addresses/address1.addr)"
address3="$(cat ../../../addresses/address2.addr)"

echo "Done"

# ------------ Compile smart contract -------------------------

echo "Compiling smart contracts..."

cd ../
cabal build
cabal run market-plutus
cd token-example 

echo "Done"

# ------------ Calculate script address -------------------------

echo "Building script address..."

cardano-cli address build \
--payment-script-file ../validate-payment.plutus \
--$testnet \
--out-file script.addr

echo "Done"

# ------------ Query the network parameters -------------------------

echo "Querying network parameters..."

cardano-cli query protocol-parameters --$testnet --out-file protocol.json

echo "Done"

echo "Querying wallet address..."

echo "address2 -> "
echo
cardano-cli query utxo --address $address2 --$testnet
echo

scriptAddr="$(cat script.addr)"

echo "scriptAddr -> "
echo
cardano-cli query utxo --address $scriptAddr --$testnet

echo "Done"