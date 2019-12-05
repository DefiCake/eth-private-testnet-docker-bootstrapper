#!/bin/bash
geth --nousb --datadir /datadir account import /credentials/private_key.txt \
    --password /credentials/password.txt;
geth --nousb --datadir /datadir init /genesis/genesis.json;

account=`geth account list --keystore /datadir/keystore | tail -n 1 | sed 's/^[^{]*{\([^{}]*\)}.*/\1/'`
account="0x${account}"

networkId=`cat /credentials/network.txt`

geth --nousb --datadir /datadir --nat extip:`hostname -i` --verbosity 4 \
    --unlock ${account} \
    --password /credentials/password.txt \
    --mine --minerthreads=1 --miner.gasprice 0  \
    --miner.gastarget 15000000 --miner.noverify \
    --networkid ${networkId};
