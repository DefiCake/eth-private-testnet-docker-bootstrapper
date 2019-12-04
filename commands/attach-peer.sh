#!/bin/sh

# Removes double quotes from enr
enr=`cat /boot-node-info/enr`
temp="${enr%\"}"
enode="${temp#\"}"

geth --nousb --datadir ./datadir init /genesis/genesis.json
geth --nousb --datadir /datadir \
    --rpc --rpcport "7545" --rpcaddr "0.0.0.0" --rpccorsdomain "*" \
    --rpcapi eth,net,web3,txpool \
    --ws --wsport "7546" --wsaddr "0.0.0.0"  --wsorigins "*" \
    --wsapi eth,net,web3,txpool \
    --bootnodes $enode --networkid 19080880
