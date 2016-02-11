#!/bin/bash

source ~/.topology
source hosts 

PROTO="udp4"
if [ $# -eq 1 ]
then
  PROTO="$1"
fi

CWD=`pwd`

echo ""
echo "-----CONFIG SERVERS-----"
echo ""
./configServers.sh ${PROTO}
echo ""
echo "-----CONFIG CLIENTS-----"
echo ""
./configClients.sh ${PROTO}

echo ""
echo "-----CONFIG ROUTER-----"
echo ""
##echo "ssh ${!RTR_HOST} \"cd $CWD/rtr; ./configRtr $PROTO\""
#ssh ${!RTR_HOST} "cd $CWD; source PATH.env; cd rtr; ./configRtr.sh $PROTO"
ssh ${!RTR_HOST} "cd $CWD; cd rtr; ./configRtr.sh $PROTO"
