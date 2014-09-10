#!/bin/bash

DIRS0="ndn-cxx "
DIRS1="NFD "
DIRS2="ndn-traffic-generator "
FLAGS=""
CLEAN="FALSE"

while [ $# -ge 1 ]
do
  if [ "$1" = "--debug" ]
  then
    FLAGS="--debug"
    shift
  else
    if [ "$1" = "--clean" ]
    then
      CLEAN="TRUE"
      shift
    fi
  fi
done

CWD=`pwd`

export PKG_CONFIG_PATH="${CWD}/usr/local/lib/pkgconfig/"
export NFD=${CWD}/usr/local/bin/nfd

for d in $DIRS0 
do
  pushd $d
  echo "building $d"
  if [ $CLEAN = "TRUE" ]
  then
    ./waf clean
  fi
  ./waf --prefix ${CWD}/usr/local configure
  ./waf --prefix ${CWD}/usr/local
  ./waf --prefix ${CWD}/usr/local install
  popd
done 
for d in $DIRS1 
do
  pushd $d
  echo "building $d"
  if [ $CLEAN = "TRUE" ]
  then
    ./waf clean
  fi
  ./waf --with-tests $FLAGS --without-websocket --prefix ${CWD}/usr/local configure
  ./waf $FLAGS --prefix ${CWD}/usr/local
  ./waf $FLAGS --prefix ${CWD}/usr/local install
  popd
done 

for d in $DIRS2 
do
  pushd $d
  echo "building $d"
  if [ $CLEAN = "TRUE" ]
  then
    ./waf clean
  fi
  ./waf --prefix ${CWD}/usr/local configure
  ./waf --prefix ${CWD}/usr/local
  ./waf --prefix ${CWD}/usr/local install
  popd
done 
