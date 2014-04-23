#!/bin/bash
source ../hosts

PROTO="udp4"
if [ $# -eq 1 ]
then
  PROTO="$1"
fi


nfdc create ${PROTO}://${RTR_HOST}:6363
#nfdc add-nexthop /example 8 1
#nfdc add-nexthop /example 6 1
#nfdc add-nexthop /example 4 1
nfdc add-nexthop / 4 1

