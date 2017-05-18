#!/bin/bash

source ~/.topology
source hosts

PROFILING="FALSE"
while getopts "h?P" opt; do
    case "$opt" in
    h|\?)
        echo "[-h] Print help messages"
        echo "[-P] Profiling mode"
        exit 0
        ;;
    P)  PROFILING="TRUE"
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift
#echo $LOCAL,$SEGLEN,Leftovers: $@


CWD=`pwd`

echo "Kill Traffic"
./killTraffic.sh

echo "Kill nfd processes on Servers"
# Start Servers
for s in $SERVER_HOSTS
do
  #ssh ${!s} "killall nrd"
  ssh ${!s} "killall nfd"
done

echo "Kill nfd processes on Clients"
# Start Clients
for s in $CLIENT_HOSTS
do
  #ssh ${!s} "killall nrd"
  ssh ${!s} "killall nfd"
done

#echo "sleep 10 to give nfd from clients and servers to dump gmon.out if they are. Then rtr can be the last"

#sleep 10

# when using callgrind, ssh ${!RTR_HOST} "pkill -f callgrind"

# Start Rtr
if [ $PROFILING = "FALSE" ]; then
    echo "Kill nfd processes on Rtr"
    #ssh ${!RTR_HOST} "killall nrd"
    ssh ${!RTR_HOST} "killall nfd"
else
    echo "Kill callgrind nfd processes on Rtr"
    #ssh ${!RTR_HOST} "killall nrd"
    ssh ${!RTR_HOST} "pkill -f callgrind"
fi


