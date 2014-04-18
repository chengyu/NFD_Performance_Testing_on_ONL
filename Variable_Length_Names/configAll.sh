#!/bin/bash

source ~/.topology
source hosts 

PROTO="udp4"
if [ $# -eq 1 ]
then
  PROTO="$1"
fi

CWD=`pwd`

./configServers.sh ${PROTO}
./configClients.sh ${PROTO}

#echo "ssh ${!RTR_HOST} \"cd $CWD/rtr; ./configRtr $PROTO\""
ssh ${!RTR_HOST} "cd $CWD/rtr; ./configRtr.sh $PROTO"
