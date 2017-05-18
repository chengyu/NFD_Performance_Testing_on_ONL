#!/bin/bash

DIRS0="ndn-cxx"
DIRS1="NFD"
DIRS2="ndn-traffic-generator"
BUILD_FLAGS=""
CLEAN="FALSE"


release="None"
verbose=0

while getopts "h?cr:" opt; do
    case "$opt" in
    h|\?)
        echo "[-h] Print help messages"
        echo "[-r] Release version"
        echo "[-c] Clean repo"
        exit 0
        ;;
    r)  release=$OPTARG
        ;;
    c)  CLEAN="TRUE"
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

#echo "verbose=$verbose, output_file='$output_file', Leftovers: $@"
#echo "release=$release, CONFIGURE_FLAGS=$CONFIGURE_FLAGS, CLEAN=$CLEAN, Leftovers: $@"

CWD=`pwd`

export PKG_CONFIG_PATH="${CWD}/usr/local/lib/pkgconfig/"
#export NFD=${CWD}/usr/local/bin/nfd

for d in $DIRS0 
do
  pushd $d
  if [ $release != "None" ]; then
    echo "Checkouting to $DIRS0-$release"
    git checkout $DIRS0-$release
  fi

  echo "building $d"

  if [ $CLEAN = "TRUE" ]; then
    ./waf uninstall
    ./waf clean
    ./waf distclean
  else
    ./waf --prefix ${CWD}/usr/local configure
    ./waf $BUILD_FLAGS --prefix ${CWD}/usr/local
    ./waf $BUILD_FLAGS --prefix ${CWD}/usr/local install
  fi
  popd
done 

for d in $DIRS1 
do
  pushd $d

  if [ $release != "None" ]; then
    echo "Checkouting to $DIRS1-$release"
    git checkout $DIRS1-$release
  fi

  echo "building $d"
  if [ $CLEAN = "TRUE" ]; then
    ./waf uninstall
    ./waf clean
    ./waf distclean
  else
    ./waf --without-websocket --prefix ${CWD}/usr/local configure
    ./waf $BUILD_FLAGS --prefix ${CWD}/usr/local
    ./waf $BUILD_FLAGS --prefix ${CWD}/usr/local install
  fi
  popd
done 

for d in $DIRS2 
do
  pushd $d

  echo "building $d"
  if [ $CLEAN = "TRUE" ]; then
    ./waf uninstall
    ./waf clean
    ./waf distclean
  else
    ./waf --prefix ${CWD}/usr/local configure
    ./waf --prefix ${CWD}/usr/local
    ./waf --prefix ${CWD}/usr/local install
  fi
  popd
done 
