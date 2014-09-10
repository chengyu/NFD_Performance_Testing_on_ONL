#!/bin/bash

#CS_SIZE="1K 2K 4K 8K 16K 32K 64K"
#CS_SIZE="8K 16K 32K 64K"
CS_SIZE="64K"
LENGTHS="4"
NUM_COMPONENTS="5"
#INTERVALS="25 22 20 18"
INTERVALS="7 "
SLEEPTIME=30
NUM_CLIENT_SERVER_PAIRS="64"
for c in $CS_SIZE
do
  cp nfd.conf.$c nfd.conf
  for n in $NUM_COMPONENTS
  do
    for l in $LENGTHS
    do
      for i in $INTERVALS
      do
        for p in $NUM_CLIENT_SERVER_PAIRS
        do
          ./mkAll.sh $p udp4 $i $n $l
          ./runAll.sh
          sleep $SLEEPTIME
          ./killAll.sh
          ./cleanAll.sh
        done
      done
    done
  done
done
