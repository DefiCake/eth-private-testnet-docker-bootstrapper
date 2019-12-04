#!/bin/sh

# Removes double quotes from enode
enode=`cat /boot-node-info/enode`
temp="${enode%\"}"
enode="${temp#\"}"
networkId=`cat /boot-node-info/network`

geth --nousb --datadir ./datadir init /genesis/genesis.json

echo "Attaching peer to enode ${enode}"
echo "with network ID ${networkId}"

geth --nousb --datadir /datadir --bootnodes $enode --networkid ${networkId} \
    --rpc --rpcport "7545" --rpcaddr "0.0.0.0" --rpccorsdomain "*" \
    --rpcapi eth,net,web3,txpool \
    --ws --wsport "7546" --wsaddr "0.0.0.0"  --wsorigins "*" \
    --wsapi eth,net,web3,txpool
    
