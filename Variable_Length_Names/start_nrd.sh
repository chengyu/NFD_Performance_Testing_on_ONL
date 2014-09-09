#!/bin/bash

nrd_ready()
{
  RIB_INFO=`nfd-status -r 2> /dev/null`
  if [ $? -eq 0 ]
  then
    RETURN=0
  else
    RETURN=1
  fi

  RIB=`echo $RIB_INFO | cut -d':' -f 1`
  if [ "$RIB" = "Rib" ]
  then
      echo "READY"
  else
      echo "NOT READY"
  fi
}


count=0
nrd --config nfd.conf >& /tmp/nrd.log &

while true
do
  ready=$(nrd_ready)
  if [  "$ready" = "READY" ]
  then
    #echo "NRD is ready"
    exit 0
  else
    #echo "NRD is NOT ready count = $count"
    count=$(($count+1))
  fi

done



