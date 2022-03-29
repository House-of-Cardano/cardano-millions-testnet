#!/bin/bash

rm ./blockchain/*.raw ./blockchain/*.signed ./blockchain/*.addr ./blockchain/*.build

# ------------ Set-up enrivonment variables -------------------------

# Hash of Cardano-Millions-Token -> 43617264616e6f2d4d696c6c696f6e732d546f6b656e 

echo "Preparing environment variables..."

testnet='testnet-magic 1097911063'

player1="$(cat ../addresses/player-1-wallet.addr)"
bank="$(cat ../addresses/bank.addr)"
cagnotte="$(cat ../addresses/cagnotte.addr)"
charity="$(cat ../addresses/charity.addr)"
winner="$(cat ../addresses/winner.addr)"

tokenname="43617264616e6f2d4d696c6c696f6e732d546f6b656e"
tokenamount="1"
policyid=$(cat ./blockchain/policy/policyID)

scriptdatumhash="$(cardano-cli transaction hash-script-data --script-data-value 1970)"
scriptdatumhash2="$(cardano-cli transaction hash-script-data --script-data-value 2003)"

minAdaAmount=1725000

minLovelaceAmount=4000000
gameRate=0.05
charityRate=0.1
gameFees=$(echo "$minLovelaceAmount * $gameRate" | bc)
charityTransfer=$(echo "$minLovelaceAmount * $charityRate" | bc)
cagnotteTransfer=$(echo "$minLovelaceAmount - $gameFees - $charityTransfer" | bc)

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

scriptAddr=$(cat ./blockchain/script.addr)

echo "Done"