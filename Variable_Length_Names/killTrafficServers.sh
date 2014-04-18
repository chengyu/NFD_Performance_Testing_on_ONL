#!/bin/bash

source ~/.topology
source hosts

echo "Kill Traffic Servers"
# Kill Servers
for s in $SERVER_HOSTS
do
  ssh ${!s} "killall ndn-traffic-server"
done

