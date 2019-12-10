#!/bin/bash
rm -f /boot-node-info/enode
rm -f /boot-node-info/network
count=0
maxRetries=10

enode=`geth attach /datadir/geth.ipc --exec 'admin.nodeInfo.enode' 2> /dev/null`
enodeSuccess=$?

network=`geth attach /datadir/geth.ipc --exec 'admin.nodeInfo.protocols.eth.network' 2> /dev/null`
networkSuccess=$?

while [ "$enodeSuccess" -ne "0" ] || [ "$networkSuccess" -ne "0" ]; do
    if [ "$count" -eq "$maxRetries" ]; then
        echo "ERROR: Could not generate node info: max retries ($maxRetries) reached"
        exit 1
    fi
    count=$((count+1))
    echo "Could not get boot node info. Retrying... $count"
    sleep 10s
    enode=`geth attach /datadir/geth.ipc --exec 'admin.nodeInfo.enode'`
    enodeSuccess=$?

    network=`geth attach /datadir/geth.ipc --exec 'admin.nodeInfo.protocols.eth.network'`
    networkSuccess=$?
done

echo $enode > /boot-node-info/enode
echo $network > /boot-node-info/network
echo "Node info succesfully generated"
