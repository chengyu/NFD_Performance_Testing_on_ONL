#!/bin/bash

DIRS="ndn-cxx NFD ndn-traffic-generator"

CWD=`pwd`


for d in $DIRS 
do
  pushd $d
  echo "git'ing $d"
  git pull 
  popd
done 
