# Private PoA Testnet wrapper

Based on the following tutorials:

- [Link 1](https://medium.com/coinmonks/private-ethereum-by-example-b77063bb634f)
- [Link 2](https://geth.ethereum.org/docs/interface/private-network)

# Usage

Generate a `genesis.json` file and place it in `/genesis/genesis.json`.

To generate a `genesis.json`, use the following docker image and command:

`docker run -it ethereum/client-go:alltools-stable`

And then, inside, run the `puppeth` command. Follow the menus to create and export the `genesis.json` file. The process will also generate some other files which you can ignore. Be wary that puppeth will ask you about the protocl type (input `clique`) and the addresses that can generate new blocks.

Afterwards, it is needed to setup the `credentials` directory. Generate a `private_key.txt` containing a valid Ethereum private key and corresponds to the public address that was set in `puppeth` previously, along with a `password.txt` to encrypt the store. Additionally, write a `network.txt` file containing the network ID for your private testnet, and make sure it coincides with `chainID` field inside `genesis.jsonp`. Place these 3 files (`private_key.txt`, `password.txt`, `network.txt`) in the `credentials` folder.

Finally, run the containers:

```bash
docker-compose up -d
```

OR

```bash
./start.sh
```

If you need to stop the network, best way is to gracefully stop it with `stop.sh` script.

If you 'd like to completely reset the network, use `reset.sh` script (WARNING: it will permanently delete the blockchain generated)

Sometimes, specially during restart and if the network was not gracefully stopped with the `stop.sh` script, the master node and member node can fork the blockchain. The nodes won't be able to speak to each other then. It is necessary to check the logs for both docker containers and reset the blockchain to its status before the fork. Use the `prune.sh <BLOCK_TO_PRUNE>` script for this. Detect the conflicting block number and input it into the `prune` script.

# Paths

- `boot-node-info`: shared directory between the master node and member node. It helps sharing network information out of band automatically, such as the enode and final network ID.
- `commands`: used by the dockjer containers to bootstrap.
- `credentials`: geth configuration parameters
- `datadir`: directory for the master node to store its chain data.
- `genesis`: directory to store `genesis.json` file, generated with `puppeth`
- `member-node-datadir`: directory for the member node (RCP external endpoint) to store its chain data.

# Commands

## Master node

- `start.sh`:

Run by the master node to boot geth.

- Checks that all needed files to bootstrap exist.
- Initializes the blockchain if the `datadir` directory is empty
- Starts the geth Clique protocol and block generation.

Note: despite using the `--nousb` flag, geth still tries to fetch USB devices, thus some errors will be shown.

- `get-noot-node-info.sh`

Awaits geth bootstrap initiated by `start.sh` and fetches the information for the member node. Puts the obtained information in `/boot-node-info`.

## Member node

The mining (master) node has its private keys exposed by geth through RPC, so it must be isolated from the network except for the member node, which is trusted. The member node has its RCP exposed for external clients to connect, but does not have any private material in it, so it can be safely used as a transaction broadcast relay.

- `attach-peer.sh`

Uses the information in `boot-node-info` to attach the geth process to the master node, subscribe to new blocks and broadcast external RCP calls.

- `keep-alive.sh`

Sometimes, geth will lose connection and a potential fork in the blockchains stored by the master and member node becomes possible. This script helps the syncing process to keep up, but it is a patch to a bigger problem.
