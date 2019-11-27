#!/bin/bash
sleep 5
echo "OBTAINING NODE INFO..."
# geth attach /datadir/geth.ipc --exec admin.nodeInfo.enode > /boot-node-info/info.txt;
geth attach /datadir/geth.ipc --exec admin.nodeInfo.enr > /boot-node-info/info.txt;
