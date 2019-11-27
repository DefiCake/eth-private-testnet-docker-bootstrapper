#!/bin/bash
geth --datadir /datadir account import /credentials/private_key.txt \
    --password /credentials/password.txt;
geth --datadir /datadir init /genesis/genesis.json;
geth --datadir /datadir --nat extip:`hostname -i` \
    --unlock 0xDCF7bAECE1802D21a8226C013f7be99dB5941bEa \
    --password /credentials/password.txt \
    --mine --minerthreads=1 --miner.gasprice 0 --miner.gastarget 15000000 --miner.noverify \
    --networkid 19080880;
