#!/bin/bash

CWD=`pwd`

source ~/.topology
source hosts
# Start Servers
echo "start nfd on all servers"
for s in $SERVER_HOSTS 
do
  ssh ${!s} "cd $CWD ; ./start_nfd.sh" 
done

echo "start nfd on all clients"
for s in $CLIENT_HOSTS 
do
  ssh ${!s} "cd $CWD ; ./start_nfd.sh" 
done

echo "start nrd on all servers"
for s in $SERVER_HOSTS 
do
  ssh ${!s} "cd $CWD ; ./start_nrd.sh" 
done

echo "start nrd on all clients"
for s in $CLIENT_HOSTS 
do
  ssh ${!s} "cd $CWD ; ./start_nrd.sh" 
done

# Start Rtr
ssh ${!RTR_HOST} "cd $CWD/rtr; ./start_nfd.sh"


