#!/bin/bash

LOCAL="FALSE"
PROTO="udp4"
INTERVAL=10
NUM_COMPONENTS=1
COMPONENT_LEN=1
COUNT=1
PKTSIZE=800

# ./mkAll.sh [optional] <proto> <interval> <num name segments> <segment length>
# ./mkAll.sh -L -c 1 -p udp4 -i 8 -n 5 -l 5 -s 100
while getopts "h?Lp:c:i:n:l:s:" opt; do
    case "$opt" in
    h|\?)
        echo "[-h] Print help messages"
        echo "[-L] Indicate using local installed nfd"
        echo "<-p> Protocol (udp4 or tcp4)"
        echo "<-c> Number of server-client pairs"
        echo "<-i> Interval (in ms)"
        echo "<-n> Number of name segments"
        echo "<-l> Length of segments"
        echo "<-s> Size of content payload"
        exit 0
        ;;
    L)  LOCAL="True"
        ;;
    p)  PROTO=$OPTARG
        ;;
    c)  COUNT=$OPTARG
        ;;
    i)  INTERVAL=$OPTARG
        ;;
    n)  NUM_COMPONENTS=$OPTARG
        ;;
    l)  COMPONENT_LEN=$OPTARG
        ;;
    s)  PKTSIZE=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift
#echo $LOCAL,$SEGLEN,Leftovers: $@

if [ $LOCAL = "FALSE" ]; then
    # default is to run installed nfd and nrd
    cp -p start_nfd.sh.INSTALLED start_nfd.sh
    #cp -p start_nrd.sh.INSTALLED start_nrd.sh
else
    cp -p start_nfd.sh.LOCAL start_nfd.sh
fi

#while [ $# -gt 5 ]
#do
#  # to run the local nfd and nrd use --local
#  if [ "$1" = "--local" ]
#  then
#    cp -p start_nfd.sh.LOCAL start_nfd.sh
#    #cp -p start_nrd.sh.LOCAL start_nrd.sh
#    shift
#  else
#    if [ "$1" = "--installed" ]
#    then
#      cp -p start_nfd.sh.INSTALLED start_nfd.sh
#      #cp -p start_nrd.sh.INSTALLED start_nrd.sh
#      shift
#    fi
#  fi
#done
#
#if [ $# -eq 5 ]
#then
#  COUNT=$1
#  PROTO=$2
#  INTERVAL=$3
#  NUM_COMPONENTS=$4
#  COMPONENT_LEN=$5
#else
#  echo "Usage: $0 [options] <count> <proto> <interval> <num name components> <component length>"
#  echo "Options:"
#  echo "  [--local]     - use start scripts to run local (../NFD_current_git_optimized/usr/local/bin/) versions of nfd and nrd"
#  echo "  [--installed] - use start scripts to run the installed (based on PATH) versions of nfd and nrd"
#  exit 0
#fi

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
./mkServers.sh $COUNT $PROTO $NUM_COMPONENTS $COMPONENT_LEN $PKTSIZE
popd 
