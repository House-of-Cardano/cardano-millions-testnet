#!/bin/bash

rm -rf ./blockchain/policy/
rm ./blockchain/*.raw ./blockchain/*.signed ./blockchain/*.addr ./blockchain/*.build

# ------------ Set-up enrivonment variables -------------------------

echo "Preparing environment variables..."

testnet='testnet-magic 1097911063'
address2="$(cat ../addresses/address1.addr)"
address3="$(cat ../addresses/address2.addr)"
player1="$(cat ../addresses/player-1-wallet.addr)"
bank="$(cat ../addresses/bank.addr)"
cagnotte="$(cat ../addresses/cagnotte.addr)"
charity="$(cat ../addresses/charity.addr)"
winner="$(cat ../addresses/winner.addr)"


echo "Done"

# ------------ Compile smart contract -------------------------

echo "Compiling smart contracts..."

cabal build
cabal run validate-payment-plutus 

echo "Done"

# ------------ Calculate script address -------------------------

echo "Building script address..."

cardano-cli address build \
--payment-script-file ./plutus-scripts/validate-payment.plutus \
--$testnet \
--out-file ./blockchain/script.addr

echo "Done"

# ------------ Query the network parameters -------------------------

echo "Querying network parameters..."

cardano-cli query protocol-parameters --$testnet --out-file ./blockchain/protocol.json

echo "Done"

echo "Querying wallet address..."

echo "address2 -> "
echo
cardano-cli query utxo --address $bank --$testnet
echo

scriptAddr="$(cat ./blockchain/script.addr)"

echo "scriptAddr -> "
echo
cardano-cli query utxo --address $scriptAddr --$testnet

echo "Done"