#!/bin/sh
sleep 10

# Removes double quotes from info.txt
fileInfo=`cat /boot-node-info/info.txt`
temp="${fileInfo%\"}"
enode="${temp#\"}"

geth --datadir ./datadir init /genesis/genesis.json
geth --datadir /datadir \
    --rpc --rpcport "7545" --rpcaddr "0.0.0.0" --rpccorsdomain "*" \
    --bootnodes $enode --networkid 19080880
