#!/bin/bash

if [ $# -eq 5 ]
then
  COUNT=$1
  PROTO=$2
  INTERVAL=$3
  NUM_COMPONENTS=$4
  COMPONENT_LEN=$5
else
  echo "Usage: $0 <count> <proto> <interval> <num name components> <component length>"
  exit 0
fi

pushd rtr
echo "mkRtr.sh"
./mkRtr.sh $COUNT $PROTO $NUM_COMPONENTS $COMPONENT_LEN
popd

pushd client
echo "mkClients.sh"
./mkClients.sh $COUNT $PROTO $INTERVAL $NUM_COMPONENTS $COMPONENT_LEN
popd

pushd server
echo "mkServers.sh"
./mkServers.sh $COUNT $PROTO $NUM_COMPONENTS $COMPONENT_LEN
popd 
