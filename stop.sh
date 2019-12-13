#!/bin/bash

docker exec -i node2.testnet.geodb.com sh -c 'kill -INT `pidof geth`'
docker exec -i node1.testnet.geodb.com sh -c 'kill -INT `pidof geth`'
docker-compose down