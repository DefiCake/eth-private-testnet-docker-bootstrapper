#!/bin/bash
# Sometimes geth seems to stall. With this, we can force trigger the sync
while true; do
    sleep 60s
    enode=`cat /boot-node-info/enode`
    temp="${enode%\"}"
    enode="${temp#\"}"
    if [ "$?" -eq "0" ]; then
        echo "Running keep alive script"
        geth attach /datadir/geth.ipc --exec \
            "if(admin.peers.length===0){admin.addPeer(\"${enode}\")}" &> /dev/null
    fi
done
