#!/bin/bash

CWD=`pwd`

source ~/.topology
source hosts
# Start Servers
echo "start nfd on all servers"
for s in $SERVER_HOSTS 
do
  echo 'ssh' ${!s} '"cd' $CWD '; ./start_nfd.sh"' 
  ssh ${!s} "cd $CWD ; ./start_nfd.sh" 
done

echo "start nfd on all clients"
for s in $CLIENT_HOSTS 
do
  echo "ssh" ${!s}
  ssh ${!s} "cd $CWD ; ./start_nfd.sh" 
done

# Start Rtr
echo "start nfd on router"
ssh ${!RTR_HOST} "cd $CWD; ./start_nfd.sh"

#echo "start nrd on all servers"
#for s in $SERVER_HOSTS 
#do
#  ssh ${!s} "cd $CWD ; ./start_nrd.sh" 
#done

#echo "start nrd on all clients"
#for s in $CLIENT_HOSTS 
#do
#  ssh ${!s} "cd $CWD ; ./start_nrd.sh" 
#done

# Start Rtr
#echo "start nrd on router"
#ssh ${!RTR_HOST} "cd $CWD; ./start_nrd.sh"


