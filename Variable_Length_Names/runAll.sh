#!/bin/bash

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


echo "Checking for basic connectivity. This could take a couple minutes..."
FAILURES=`~onl/bin/pingAllHosts.pl | grep FAIL`

if [ -n "$FAILURES" ]
then
   echo "There were some FAILURES "
   echo "$FAILURES"
   echo "try running $0 again and if it still fails, investigate..."
   exit 0
else
   echo "zero FAILURES "
fi

echo "startAll.sh"
./startAll.sh $PROFILING
echo "configAll.sh"
./configAll.sh 
echo "runTrafficServers.sh"
./runTrafficServers.sh 
echo "runTrafficClients.sh"

if [ $# -eq 1 ]
then
  INTERVAL=$1
  ./runTrafficClients.sh $INTERVAL 
else
  ./runTrafficClients.sh 
fi

