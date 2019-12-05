#!/bin/sh

# Removes double quotes from enode
enode=`cat /boot-node-info/enode`
temp="${enode%\"}"
enode="${temp#\"}"
networkId=`cat /boot-node-info/network`

if [ ! -d "/datadir/geth" ]; then
    echo "Initializing /datadir for member node"
    geth --nousb --datadir /datadir init /genesis/genesis.json;
fi

echo "Attaching peer to ${enode}"
echo "with network ID ${networkId}"

geth --nousb --datadir /datadir --syncmode light \
    --bootnodes $enode --networkid ${networkId} \
    --rpc --rpcport "7545" --rpcaddr "0.0.0.0" --rpccorsdomain "*" \
    --rpcapi eth,net,web3,txpool \
    --ws --wsport "7546" --wsaddr "0.0.0.0"  --wsorigins "*" \
    --wsapi eth,net,web3,txpool
    
