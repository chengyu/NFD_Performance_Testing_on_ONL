#!/bin/bash

FAILURES=`~onl/bin/pingAllHosts.pl | grep FAIL`

if [ -n "$FAILURES" ]
then
   echo "FAILURES non-zero"
else
   echo "FAILURES zero"
fi
