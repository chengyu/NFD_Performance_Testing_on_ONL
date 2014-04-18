#!/bin/bash

source ~/.topology

CWD=`pwd`

./killTrafficClients.sh
./killTrafficServers.sh

