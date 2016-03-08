#!/bin/bash

# default is to run installed nfd and nrd
cp -p start_nfd.sh.INSTALLED start_nfd.sh
#cp -p start_nrd.sh.INSTALLED start_nrd.sh

while [ $# -gt 6 ]
do
  # to run the local nfd and nrd use --local
  if [ "$1" = "--local" ]
  then
    cp -p start_nfd.sh.LOCAL start_nfd.sh
    #cp -p start_nrd.sh.LOCAL start_nrd.sh
    shift
  else
    if [ "$1" = "--installed" ]
    then
      cp -p start_nfd.sh.INSTALLED start_nfd.sh
      #cp -p start_nrd.sh.INSTALLED start_nrd.sh
      shift
    else
      INTEREST_NUM=$1
      shift
    fi
  fi
done

if [ $# -eq 6 ]
then
  COUNT=$1
  PROTO=$2
  INTERVAL=$3
  NUM_COMPONENTS=$4
  COMPONENT_LEN=$5
  CONTENT_PAYLOAD=$6
else
  echo "Usage: $0 [options] [interest num] <count> <proto> <interval> <num name components> <component length> <content payload size>"
  echo "Options:"
  echo "  [--local]     - use start scripts to run local (../NFD_current_git_optimized/usr/local/bin/) versions of nfd and nrd"
  echo "  [--installed] - use start scripts to run the installed (based on PATH) versions of nfd and nrd"
  exit 0
fi

pushd rtr
echo "mkRtr.sh"
./mkRtr.sh $COUNT $PROTO $NUM_COMPONENTS $COMPONENT_LEN
popd

pushd client
echo "mkClients.sh"
./mkClients.sh $COUNT $PROTO $INTERVAL $NUM_COMPONENTS $COMPONENT_LEN $INTEREST_NUM 
popd

pushd server
echo "mkServers.sh"
./mkServers.sh $COUNT $PROTO $NUM_COMPONENTS $COMPONENT_LEN $CONTENT_PAYLOAD
popd 
