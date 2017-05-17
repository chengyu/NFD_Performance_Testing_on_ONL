#!/bin/bash
source ../hosts

PROTO="udp4"
if [ $# -eq 1 ]
then
  PROTO="$1"
fi

export LD_LIBRARY_PATH="$CWD/../NFD_current_git/usr/local/lib:$LD_LIBRARY_PATH"
export LOCAL_PATH="../../NFD_current_git/usr/local/bin"
$LOCAL_PATH/nfdc create ${PROTO}://${RTR_HOST}:6363
#nfdc add-nexthop -c 1 / 4 
$LOCAL_PATH/nfdc add-nexthop -c 1 / ${PROTO}://${RTR_HOST}:6363

