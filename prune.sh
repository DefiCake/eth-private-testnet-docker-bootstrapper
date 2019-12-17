#!/bin/bash

# Prune the blockchain up from a block.
# This allows to troubleshoot sync failures
# between the master (mining) node and 
# the member node.

# Check docker logs poa-member-node to
# locate the conflicting node and prune it

if [ -z  $1 ]; then
    echo "Please run prune.sh <BLOCK TO PRUNE>, in hex format"
    exit 1
fi

BLOCK_NUMBER_HEX=$1

# First, shutdown node2
docker kill poa-member-node
echo "  Pruning from block > $BLOCK_NUMBER_HEX"
docker exec -i poa-master-node sh -c "geth attach /datadir/geth.ipc --exec 'debug.setHead(\"$BLOCK_NUMBER_HEX\")' &> /dev/null"

echo "  RESTARTING CONTAINERS"
docker-compose down
rm -rf ./member-node-datadir/*

docker-compose up -d
