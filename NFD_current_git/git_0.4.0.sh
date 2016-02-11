#!/bin/bash

DIRS="ndn-cxx NFD ndn-traffic-generator"

CWD=`pwd`

pushd NFD
git checkout NFD-0.4.0
popd

pushd ndn-cxx
git checkout ndn-cxx-0.4.0


