#!/bin/bash

docker exec -i poa-member-node sh -c 'kill -INT `pidof geth`'
docker exec -i poa-master-node sh -c 'kill -INT `pidof geth`'
docker-compose down
