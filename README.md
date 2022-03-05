[![License](https://img.shields.io/github/license/house-of-cardano/cardano-millions-testnet)](https://github.com/House-of-Cardano/cardano-millions-testnet)

# cardano-millions-testnet
Testing scripts for a cardano lottery. Powered by Plutus smart contracts on the Cardano blockchain (testnet)

**WORK IN PROGRESS** (thanks for your patience)

&nbsp;
## Contents
### [Introduction](#introduction-1)
### [How to play the Cardano-Millions lottery](#how-to-play-the-cardano-millions-lottery-1)
### [How the Cardano-Millions lottery works](#how-the-cardano-millions-lottery-works-1)
### [Run the code](#run-the-code-1)
### [To Do](#to-do-1)

&nbsp;
## Introduction

This repo details the code base for the :raised_hands: Cardano Millions :raised_hands: lottery, a simple lotto game running on the **Cardano blockchain** and running **Plutus Smart Contracts**. The code detailed here runs on the Cardano testnet and uses test ADA (tADA) as its currency.

The game can be played from the [HouseOfCardano](https://house-of-cardano.io/cardano-millions) website which will also supprt a mainnet version of this game in the future.

**10% of all money collected at each iteration of the lottery will go to charities that support children #Peace #Love and #Cardano #forall**

To set-up your own version of Cardano Millions, follow the instructions below. Happy coding :sunglasses:

## How to play the Cardano-Millions lottery
WORK IN PROGRESS
&nbsp;

## How the Cardano-Millions lottery works
WORK IN PROGRESS
&nbsp;
### Wait, I need to pay how much?
You'll see - but it won't be expensive and it will be fun and part of the proceeds will always go to charity
&nbsp;

<!-- ### Info to include in this section? Proposal for notes ->

- The absolute amount, as of March 4, 2022, is 1,725,000 lovelace or 1.725 ADA
- It will not be possible to syphone game fees in real time as the minimum amount for a valid transaction is 1 ADA, but 5% (for example) of a ticket price of 4 ADA is 0.2 ADA, so any transaction with a 5% game fee does not get validated. A news process will have to be made in which the script address is periodically queried, and especially before the end of the lotto, to mass transfer ADA accumulated at the script address to the bank (for game fees), to charity and to cagnotte
- Game fees cannot be syphoned in real time as the fee is below the minimum amount required to validate a transaction.  This means that the game fee will have to be transferred to bank en masse and periodically. This will require periodic querying of the script address
        - Through cardano-db-sync?
        - Through cardano-cli?  -->

## Run the code

### Set-up a cardano-node
Building, synchronising and running the cardano-node is a very straightforward process, thanks entirely to the hugely awesome :heart_eyes: instructions that the great people at [CoinCashew](https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node#14-configure-your-topology-files) have provided to us mere mortals. Follow this guide, it **will** change your life.

The only items to watch our for in these instructions are:

- Make sure you are installing and building the latest version of cardano-node. The latest releases can be found [here](https://github.com/input-output-hk/cardano-node), on the right under "Releases". The latest cardano-node version at time of writing is 1.34.0
- Make sure that you change `mainnet` to `testnet`

I believe that by following these instructions, you will automatically build the most recent release, but its always worth checking. As part the installation process you will have the opportunity to check the version that you have installed.

If building a node just to have a node, and if you have no intention of running a Cardano Stake Pool, then just follow the instructions to build a Relay, you can ignore the instructions for building a Block Producer node and everything concerning the air-gap machine (which is necessary for security of the Block Producer).

And another **GREAT** feature of these instructions is that you will also download a number of incredibly important tools for your journey in Cardano

- the incredibly useful `cardano-cli`, the command line interface from which you can run many transactions to the Cardano blockchain (and which is used extensively here)
- libsodium (for encryption purposes I believe)
- cabal and ghc (the Glasgow Haskell Complier) -> I am so thankful for this :pray: (and you will be too :blush:)

From time to time, the engineers working on the Cardano blockchain make new releases. I believe it is important to keep you nodes updated. To update your cardano-node to the latest release, follow the instructions below (copied from [here](https://forum.cardano.org/t/update-cardano-node-to-1-30-1-for-coincashew-users/77213))

```markdown
sudo apt-get update && sudo apt-get upgrade -y
```
```markdown
cd $HOME/git
git clone https://github.com/input-output-hk/cardano-node.git cardano-node2
cd cardano-node2/
git fetch --all --recurse-submodules --tags`
```

**Find the latest release from [here](https://github.com/input-output-hk/cardano-node)**
```markdown
git checkout tags/1.34.0
```
```markdown
ghcup upgrade
ghcup install ghc 8.10.4
ghcup set ghc 8.10.4
ghcup install cabal 3.4.0.0
ghcup set cabal 3.4.0.0
cabal update
ghc --version
cabal --version
```
```markdown
cd $HOME/git/cardano-node2
cabal configure -O0 -w ghc-8.10.4
echo -e "package cardano-crypto-praos\n flags: -external-libsodium-vrf" > cabal.project.local
cabal build cardano-node cardano-cli
```
```markdown
$(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-cli") version
$(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-node") version
```
```markdown
sudo systemctl stop cardano-node
```

```markdown
sudo cp $(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-cli") /usr/local/bin/cardano-cli
sudo cp $(find $HOME/git/cardano-node2/dist-newstyle/build -type f -name "cardano-node") /usr/local/bin/cardano-node
```

```markdown
cardano-node version
cardano-cli version
```

```markdown
sudo systemctl start cardano-node
```

```markdown
cd $HOME/git/
rm -rf cardano-node-old
mv cardano-node cardano-node-old
mv cardano-node2 cardano-node
```

A ton of useful and great information on Cardano items, issues, troubleshooting and be found at the [Cardano Forum](https://forum.cardano.org/) and at the [Cardano Stack Exchange](https://cardano.stackexchange.com/)

### Install and run a cardano-db-sync to query the blockchain

From https://github.com/input-output-hk/cardano-db-sync ->

>The purpose of Cardano DB Sync is to follow the Cardano chain and take information from the chain and an internally maintained copy of ledger state. Data is then extracted from the chain and inserted into a PostgreSQL database. SQL queries can then be written directly against the database schema or as queries embedded in any language with libraries for interacting with an SQL database.

>Examples of what someone would be able to do via an SQL query against a Cardano DB Sync instance fully synced to a specific network is:

>Look up any block, transaction, address, stake pool etc on that network, usually by the hash that identifies that item or the index into another table.
Look up the balance of any stake address for any Shelley or later epoch.
Look up the amount of ADA delegated to each pool for any Shelley or later epoch.

>---------------------------------------------------------------------------------

Installing and running the cardano-db-sync is not at all obvious. I had it working fine, but then, after some node updates, it was no longer connecting to the testnet. I found that following the instructions at https://github.com/input-output-hk/cardano-db-sync/blob/master/doc/building-running.md works fine. It is important to follow these instructions, and especially to checkout the latest release and not to build from main. Also, cardano-db-sync requires a running and synchronised cardano-node (see [Set-up a cardano-node](#set-up-a-cardano-node) for installation instructions for cardano-node).

Instructions to install and run cardano-db-sync can be found [here](https://docs.cardano.org/explore-cardano/cardano-architecture/working-with-db-sync). Once postgres has been installed, start the service with `sudo service postgresql start` and then create a database named `testnet` from within the `cardano-db-sync` folder:

```markdown
sudo createdb -U root testnet
```
Check that the testnet database has been created by running

```markdown
sudo -u postgres psql
\l
```
This database can subsequently be accessed by running `sudo -u postgres psql testnet`

To build cardano-db-sync, I followed the instructions using nix. After cloning the cardano-db-sync repo (from https://github.com/input-output-hk/cardano-db-sync), go to the instructions at https://github.com/input-output-hk/cardano-db-sync/blob/master/doc/building-running.md and scroll down to the section "Set up and run the db-sync node // with nix". After "cd'ing" into the cloned repo, checkout the latest release using the command

```markdown
git checkout <latest-official-tag> -b tag-<latest-official-tag>
```

At the time of writing, the current release was `12.0.2`, so I used the command `git checkout 12.0.2 -b tag-12.0.2`

Build the node by running the command `nix-build -A cardano-db-sync -o db-sync-node`

Once the build is complete, make a copy the file `config/mainnet-config.yaml` to `config/testnet-config.yaml` and edit the following line in this file:

`NodeConfigFile: ../../cardano-my-node/testnet-config.json`

The `testnet-config.json` file is one of the files that are created when you build the cardano-node - so build and synchronise your cardano node (testnet) before setting up cardano-db-synch. The path for the `NodeConfigFile` is the path to the node config file, relative to the config file located in the `cardano-db-sync` folder. Once the file has been copied and modified, run:

```markdown
PGPASSFILE=config/pgpass-testnet scripts/postgresql-setup.sh --createdb
```

and then

```markdown
PGPASSFILE=config/pgpass-testnet db-sync-node/bin/cardano-db-sync \
    --config config/testnet-config.yaml \
    --socket-path ../cardano-my-node/db/socket \
    --state-dir ledger-state/testnet \
    --schema-dir schema/
```

This last command will start the synchronisation between the cardano-node and cardano-db-sync. Before running the command, make sure that you replace `mainnet` with `testnet` and replace the `--socket-path` tag with the path to your cardano-node `node.socket` file in your cardano-node folder (my folder is called `cardano-my-node`).

Once synchronisation has started, querying teh testnet database will show that the tables begin to get populated:

```markdown
sudo -u postgres psql testnet
\dt
```

I ran this second synchronising command detached, in a tmux session. To fully synchronise the db to the node took approximately 08:51 **XXX NEED TO COMPLETE XXX**

Once up and running, there are a number of "ready made" queries that you can run, which can be found at https://github.com/input-output-hk/cardano-db-sync/blob/master/doc/interesting-queries.md, and details on the various tables can be found at https://github.com/input-output-hk/cardano-db-sync/blob/master/doc/schema.md

I believe that it is also possible to use graphql or [Blockfrost](https://blockfrost.io) with cardano-db-synch, but I have not yet investigated this (info for using graphql with the Cardano blockchain can be found [here](https://github.com/AskBid/cardano-notes/wiki/cardano-db-sync%2C-cardano-node%2C-cardano-graph-ql)).

### Install nix
WORK IN PROGRESS

### Install and run Cardano-Millions
&nbsp;
WORK IN PROGRESS

## To Do

- [ ] Add-in badges
- [ ] Description on how to install and run the cardano-millions repository
<!-- - :heavy_check_mark: Item Four -->