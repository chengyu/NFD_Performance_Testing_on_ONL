#!/bin/bash

nfd --config nfd.conf >& /tmp/nfd.log &
sleep 5
nrd >& /tmp/nrd.log &



