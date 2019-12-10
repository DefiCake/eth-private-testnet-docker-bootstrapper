#!/bin/bash
rm /boot-node-info/enode
rm /boot-node-info/network
count=0

geth attach /datadir/geth.ipc --exec 'admin.nodeInfo.enode' > /boot-node-info/enode && \
geth attach /datadir/geth.ipc --exec 'admin.nodeInfo.protocols.eth.network' > /boot-node-info/network

while [ "$?" -ne "0" ]; do
    if [ "$count" -eq "10" ]; then
        exit 1
    fi
    count=$((count+1))
    sleep 10
    geth attach /datadir/geth.ipc --exec 'admin.nodeInfo.enode' > /boot-node-info/enode && \
    geth attach /datadir/geth.ipc --exec 'admin.nodeInfo.protocols.eth.network' > /boot-node-info/network
done

echo "Node info succesfully generated"
