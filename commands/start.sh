#!/bin/bash

if [ ! -s "/credentials/private_key.txt" ]; then
    >&2 echo "private_key.txt file not provided"
    exit 1
fi

if [ ! -s "/credentials/password.txt" ]; then
    >&2 echo "password.txt file not provided"
    exit 1
fi

if [ ! -s "/credentials/network.txt" ]; then
    >&2 echo "network.txt file not provided"
    exit 1
fi

if [ ! -s "/genesis/genesis.json" ]; then
    >&2 echo "genesis.json file not provided"
    exit 1
fi

if [ ! -d "/datadir/geth" ]; then
    echo "Initializing /datadir for master node"
    geth --nousb --datadir /datadir account import /credentials/private_key.txt \
    --password /credentials/password.txt;
    geth --nousb --datadir /datadir init /genesis/genesis.json;
fi

account=`geth account list --keystore /datadir/keystore | tail -n 1 | sed 's/^[^{]*{\([^{}]*\)}.*/\1/'`
account="0x${account}"

networkId=`cat /credentials/network.txt`

geth --nousb --datadir /datadir --nat extip:`hostname -i` --netrestrict 172.0.254.0/24 \
    --unlock ${account} \
    --password /credentials/password.txt \
    --mine --minerthreads=1 --miner.gasprice 0  \
    --miner.gastarget 15000000 --miner.noverify \
    --networkid ${networkId};
