# cardano-millions-testnet
Testing scripts for a cardano lottery. Powered by Plutus smart contracts on the Cardano blockchain
&nbsp;
## Contents
### [Introduction](#introduction)
### [How to play the Cardano-Millions lottery](#how-to-play-the-cardano-millions-lottery)
### [How the Cardano-Millions lottery works](#how-the-cardano-millions-lottery-works)
### [Run the code](#run-the-code)
### [To Do](#to-do)

&nbsp;
## Introduction
&nbsp;

This repo details the code base for the << Cardano Millions >> lottery, a simple lotto game running on the **Cardano blockchain** and running **Plutus Smart Contracts**. The code detailed here runs on the Cardano testnet and uses test ADA (tADA) as its currency.

The game can be played from the <a href="https://house-of-cardano.io/cardano-millions" target="_blank">HouseOfCardano</a> website

 [HouseOfCardano](https://house-of-cardano.io/cardano-millions){:target="_blank"} website which will also supprt a mainnet version of this game in the future.

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
Building, synchronising and running the cardano-node is a very straightforward process, thanks entirely to the hugely awesome :heart_eyes: instructions that the great people at <a href="https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node#14-configure-your-topology-files" target="_blank">CoinCashew</a>. Follow this guide, it **will** change your life.

The only items to watch our for in these instructions are:

- Make sure you are installing and building the latest version of cardano-node. The latest releases can be found <a href="https://github.com/input-output-hk/cardano-node" target="_blank">here</a>, on the right under "Releases". The latest cardano-node version at time of writing is 1.34.0
- Make sure that you change `mainnet` to `testnet`

I believe that by following these instructions, you will automatically build the most recent release, but its always worth checking. As part the installation process you will have the opportunity to check the version that you have installed.

If building a node just to have a node, and if you have no intention of running a Cardano Stake Pool, then just follow the instructions to build a Relay, you can ignore the instructions for building a Block Producer node and everything concerning the air-gap machine (which is necessary for security of the Block Producer).

And another **GREAT** feature of these instructions is that you will also download a numnber of incredibly important tools for your journey into Cardano

- the incredibly useful `cardano-cli`, the command line interface from which you can run many transactions to the Cardano blockchain (and which is used extensively here)
- libsodium (for encryption purposes I believe)
- cabal and ghc (the Glasgow Haskell Complier) -> I am so thankful for this :pray: (and you will be too :blush:)

From time to time, the engineers working on the Cardano blockchain make new releases. I believe it is important to keep you nodes updated. To update your cardano-node to the latest release, follow the instructions below (copied from <a href="https://forum.cardano.org/t/update-cardano-node-to-1-30-1-for-coincashew-users/77213" target="_blank">here</a> 

`sudo apt-get update && sudo apt-get upgrade -y`

`cd $HOME/git
git clone https://github.com/input-output-hk/cardano-node.git cardano-node2
cd cardano-node2/
git fetch --all --recurse-submodules --tags`

`git checkout tags/1.34.0` **Find the latest release from <a href="https://github.com/input-output-hk/cardano-node" target="_blank">here</a>**

`ghcup upgrade
ghcup install ghc 8.10.4
ghcup set ghc 8.10.4
ghcup install cabal 3.4.0.0
ghcup set cabal 3.4.0.0
cabal update
ghc --version
cabal --version`

`cd $HOME/git/cardano-node2
cabal configure -O0 -w ghc-8.10.4
echo -e "package cardano-crypto-praos\n flags: -external-libsodium-vrf" > cabal.project.local
cabal build cardano-node cardano-cli`

`$(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-cli") version
$(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-node") version`

`sudo systemctl stop cardano-node`

`sudo cp $(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-cli") /usr/local/bin/cardano-cli
sudo cp $(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-node") /usr/local/bin/cardano-node`

`cardano-node version
cardano-cli version`

`sudo systemctl start cardano-node`

`cd $HOME/git/
rm -rf cardano-node-old
mv cardano-node cardano-node-old
mv cardano-node2 cardano-node`

A ton of useful and great information on Cardano items, issues, troubleshooting and be found at the <a href="https://forum.cardano.org/" target="_blank">Cardano Forum</a> and at the <a href="https://cardano.stackexchange.com/" target="_blank">Cardano Stack Exchange</a>

&nbsp;
### Install and run a cardano-db-sync to query the blockchain

From https://github.com/input-output-hk/cardano-db-sync ->

>The purpose of Cardano DB Sync is to follow the Cardano chain and take information from the chain and an internally maintained copy of ledger state. Data is then extracted from the chain and inserted into a PostgreSQL database. SQL queries can then be written directly against the database schema or as queries embedded in any language with libraries for interacting with an SQL database.

>Examples of what someone would be able to do via an SQL query against a Cardano DB Sync instance fully synced to a specific network is:

>Look up any block, transaction, address, stake pool etc on that network, usually by the hash that identifies that item or the index into another table.
Look up the balance of any stake address for any Shelley or later epoch.
Look up the amount of ADA delegated to each pool for any Shelley or later epoch.

>---------------------------------------------------------------------------------

Installing and running the cardano-db-sync is not at all obvious. I had it working fine, but then, after some node updates, it was no longer connecting to the testnet. I found that following the instructions at https://github.com/input-output-hk/cardano-db-sync/blob/master/doc/building-running.md works fine. It is important to follow these instructions, and especially to checkout the latest release and not to build from main. Also, cardano-db-sync requires a running and synchronised cardano-node (see [Set-up a cardano-node](#set-up-a-cardano-node) for installation instructions for cardano-node).

To set-up the database, I followed the instructions using cabal (see [Install cabal](#install-cabal) on how to get this running). After cloning the cardano-db-sync repo (from https://github.com/input-output-hk/cardano-db-sync), go to the instructions at https://github.com/input-output-hk/cardano-db-sync/blob/master/doc/building-running.md and scroll down to the section "Set up and run the db-sync node". After "cd'ing" into the cloned repo, checkout the latest release using the command

**TEST SECTION FOR THE EXTERNAL LINKS**

To set-up the database, I followed the instructions using cabal (see [Install cabal](#install-cabal) on how to get this running). After cloning the cardano-db-sync repo (from <a href="https://github.com/input-output-hk/cardano-db-sync" target="_blank">cardano-db-sync</a>), go to the instructions at https://github.com/input-output-hk/cardano-db-sync/blob/master/doc/building-running.md and scroll down to the section "Set up and run the db-sync node". After "cd'ing" into the cloned repo, checkout the latest release using the command




`git checkout <latest-official-tag> -b tag-<latest-official-tag>`

I was using the `12.0.2` release, so used `git checkout 12.0.2 -b tag-12.0.2`

Follow the instructions to build the node by running the command `cabal build cardano-db-sync`

The build may take some time (for me, it took approximately 35 minutes). 

Once the build is complete, run 

`PGPASSFILE=config/pgpass-testnet cabal run cardano-db-sync -- \
    --config config/testnet-config.yaml \
    --socket-path /home/node/cardano-my-node/db/socket \
    --state-dir ledger-state/testnet \
    --schema-dir schema/`

making sure that you replace `mainnet` with `testnet` and by replacing the `--socket-path` tag with the path to your cardano-node `node.socket` file.

However, running `PGPASSFILE....` the first time gave the following error message:

`cardano-db-sync: FatalError {fatalErrorMessage = "Cannot find the DbSync configuration file at : config/testnet-config.yaml"}`

This is, I guess, because the repo is set-up to query mainnet. To fix this, I copied the file at `config/mainnet-config.yaml` to `config/testnet-config.yaml` and edited the following line in this file:

`NodeConfigFile: ../../cardano-my-node/testnet-config.json`

The `testnet-config.json` file is one of the files that are created when you build the cardano-node - so build and synchronise your cardano node (testnet) before setting up cardano-db-synch.

Fixing this line in the `config/testnet-config.yaml` file and running the `PGPASSFILE....` command again started the synchronisation of cardano-db-sync to the testnet cardano node.

I ran this synchronising process detached in a tmux session. To fully synchronise the db to the node too approximately 08:51 **XXX NEED TO COMPLETE XXX**

Once up and running, there are a number of "ready made" queries that you can run, which can be found at https://github.com/input-output-hk/cardano-db-sync/blob/master/doc/interesting-queries.md, and details on the various tables can be found at https://github.com/input-output-hk/cardano-db-sync/blob/master/doc/schema.md

I believe that it is also possible to use graphql or Blockfrost (https://blockfrost.io) with cardano-db-synch, but I have not yet investigated this (info for graphql can be found at https://github.com/AskBid/cardano-notes/wiki/cardano-db-sync%2C-cardano-node%2C-cardano-graph-ql).

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

- [ ] Fix internal anchor points
- [ ] Test external links to open in a new page
- [ ] Add-in badges
- :heavy_check_mark: Item Four