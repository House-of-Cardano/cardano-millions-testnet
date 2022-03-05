# cardano-millions-testnet
Testing scripts for a cardano lottery. Powered by Plutus smart contracts on the Cardano blockchain

*** Add in badges ***

&nbsp;
## Contents
### [Introduction](#introduction)
### [How to play the Cardano-Millions lottery](#how-to-play-the-cardano-millions-lottery)
### [How the Cardano-Millions lottery works](#how-the-cardano-millions-lottery-works)
### [To Do](#to-do)

&nbsp;
## Introduction
&nbsp;

This repo details the code base for the << Cardano Millions >> lottery, a simple lotto game running on the **Cardano blockchain** and running **Plutus Smart Contracts**. The code detailed here runs on the Cardano testnet and uses test ADA (tADA) as its currency.

The game can be played from the website https://house-of-cardano.io/cardano-millions which will also supprt a mainnet version of this game in the future.

To set-up your own version of Cardano Millions, follow the instructions below. Happy coding :sunglasses:

## How to play the Cardano-Millions lottery
&nbsp;

## How the Cardano-Millions lottery works
&nbsp;
### Wait, I need to pay how much?
&nbsp;

### Info to include in this section? Proposal for notes ->

- The absolute amount, as of March 4, 2022, is 1,725,000 lovelace or 1.725 ADA
- It will not be possible to syphone game fees in real time as the minimum amount for a valid transaction is 1 ADA, but 5% (for example) of a ticket price of 4 ADA is 0.2 ADA, so any transaction with a 5% game fee does not get validated. A news process will have to be made in which the script address is periodically queried, and especially before the end of the lotto, to mass transfer ADA accumulated at the script address to the bank (for game fees), to charity and to cagnotte
- Game fees cannot be syphoned in real time as the fee is below the minimum amount required to validate a transaction.  This means that the game fee will have to be transferred to bank en masse and periodically. This will require periodic querying of the script address
        - Through cardano-db-sync?
        - Through cardano-cli? 

## Run the code
&nbsp;
### Set-up a cardano-node
&nbsp;
### Set-up a cardano-db-sync to query the blockchain
&nbsp;

Installing and running the cardano-db-sync is not at all obvious. I had ot working fine, but then, after some node updates, it was no longer connecting to the testnet. I found that following the instructions at https://github.com/input-output-hk/cardano-db-sync/blob/master/doc/building-running.md works fine. It is important to follow these instructions, and especially to checkout the latest release and not to build from main. Also, cardano-db-sync requires a running and synchronised cardano-node (see [Set-up a cardano-node](#set-up-a-cardano-node) for installation instructions for cardano-node).

To set-up the database, I followed the instructions using cabal (see [Install cabal](#install-cabal) on how to get this running). After cloning the cardano-db-sync repo (from https://github.com/input-output-hk/cardano-db-sync), go to the instructions at https://github.com/input-output-hk/cardano-db-sync/blob/master/doc/building-running.md and scroll down to the section "Set up and run the db-sync node". After cd'ing into the cloned repo, checkout the latest release using the command

`git checkout <latest-official-tag> -b tag-<latest-official-tag>`

I was using the `12.0.2` release, so used `git checkout 12.0.2 -b tag-12.0.2`

Follow the instructions to build the node by running the command `cabal build cardano-db-sync`

The build may take some time (for me, it took approximately xxx minutes). Once the build is complete, run 

`PGPASSFILE=config/pgpass-testnet cabal run cardano-db-sync -- \
    --config config/testnet-config.yaml \
    --socket-path /home/node/cardano-my-node/db/socket \
    --state-dir ledger-state/testnet \
    --schema-dir schema/`

making sure that you replace `mainnet` with `testnet` and by replacing the `--socket-path` tag with the path to your cardano-node `node.socket` file.

### Install cabal
&nbsp;
### Install nix-shell
&nbsp;
### Install and run Cardano-Millions
&nbsp;

Code snippet
&nbsp;
`Code one block code block code`

```markdown
- one
- two
- three
```



&nbsp;
 
## To Do

- [ ] Item One
- [ ] Item Two
- :white_check_mark Item Three
- :white_large_sqaure Item Four
- :heavy_check_mark: Item Four