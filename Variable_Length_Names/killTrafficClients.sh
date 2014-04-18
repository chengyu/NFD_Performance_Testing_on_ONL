#!/bin/bash

source ~/.topology
source hosts

CWD=`pwd`

echo "Kill Traffic Clients"
# Kill Clients
for s in $CLIENT_HOSTS
do
  ssh ${!s} "killall ndn-traffic"
done
