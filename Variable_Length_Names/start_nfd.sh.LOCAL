#!/bin/bash

nfd_ready()
{
  FIB_INFO=`../NFD_current_git/usr/local/bin/nfdc fib list 2> /dev/null`
  if [ $? -eq 0 ]
  then
    RETURN=0
  else
    RETURN=1
  fi
  
  FIB=`echo $FIB_INFO | cut -d':' -f 1`
  if [ "$FIB" = "FIB" ]
  then
      echo "READY"
  else
      echo "NOT READY"
  fi
}


count=0
CWD=`pwd`
export LD_LIBRARY_PATH="$CWD/../NFD_current_git/usr/local/lib:$LD_LIBRARY_PATH"
../NFD_current_git/usr/local/bin/nfd --config nfd.conf >& /tmp/nfd.log &

while true
do
  ready=$(nfd_ready)
  if [  "$ready" = "READY" ]
  then
    echo "NFD is ready"
    exit 0
  else
    count=$(($count+1))
  fi

done


