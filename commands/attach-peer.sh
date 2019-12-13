#!/bin/sh
# Removes double quotes from enode
enode=`cat /boot-node-info/enode`
temp="${enode%\"}"
enode="${temp#\"}"
networkId=`cat /boot-node-info/network`

# echo "Manually syncing blockchain database"
# rm -rf /datadir/geth
# cp /bootstrap/geth /datadir/geth -R

if [ ! -d "/datadir/geth" ]; then
    echo "Initializing /datadir for member node"
    geth --nousb --datadir /datadir init /genesis/genesis.json;
fi

echo "Attaching peer to ${enode}"
echo "with network ID ${networkId}"

geth --nousb \
    --gcmode archive \
    --datadir /datadir \
    --netrestrict 172.0.254.0/24 \
    --syncmode full \
    --verbosity 4 \
    --vmodule eth/*=6 \
    --bootnodes $enode \
    --networkid ${networkId} \
    --rpc \
    --rpcport "7545" \
    --rpcaddr "0.0.0.0" \
    --rpccorsdomain "*" \
    --rpcapi eth,net,web3,txpool,debug \
    --ws \
    --wsport "7546" \
    --wsaddr "0.0.0.0"  \
    --wsorigins "*" \
    --wsapi eth,net,web3,txpool,debug
    
