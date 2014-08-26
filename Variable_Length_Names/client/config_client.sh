#!/bin/bash
source ../hosts

PROTO="udp4"
if [ $# -eq 1 ]
then
  PROTO="$1"
fi

nfdc create ${PROTO}://${RTR_HOST}:6363
#nfdc add-nexthop -c 1 / 4 
nfdc add-nexthop -c 1 / ${PROTO}://${RTR_HOST}:6363

