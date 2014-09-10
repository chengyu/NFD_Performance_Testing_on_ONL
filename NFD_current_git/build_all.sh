#!/bin/bash

DIRS0="ndn-cxx "
DIRS1="NFD "
DIRS2="ndn-traffic-generator "
CONFIGURE_FLAGS=""
BUILD_FLAGS=""
CLEAN="FALSE"

while [ $# -ge 1 ]
do
  if [ "$1" = "-v" ]
  then
    BUILD_FLAGS="$BUILD_FLAGS -v"
    shift
  else
    if [ "$1" = "--debug" ]
    then
      CONFIGURE_FLAGS="$CONFIGURE_FLAGS --debug"
      shift
    else
      if [ "$1" = "--clean" ]
      then
        CLEAN="TRUE"
        shift
      else
        if [ "$1" = "--profile" ]
        then
          export CXXFLAGS="$CXXFLAGS -O2 -pg -g"
          export LINKFLAGS="$LINKFLAGS -pg "
          shift
        fi
      fi
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
  ./waf $CONFIGURE_FLAGS --prefix ${CWD}/usr/local configure
  ./waf $BUILD_FLAGS --prefix ${CWD}/usr/local
  ./waf $BUILD_FLAGS --prefix ${CWD}/usr/local install
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
  ./waf --with-tests $CONFIGURE_FLAGS --without-websocket --prefix ${CWD}/usr/local configure
  ./waf $BUILD_FLAGS --prefix ${CWD}/usr/local
  ./waf $BUILD_FLAGS --prefix ${CWD}/usr/local install
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
