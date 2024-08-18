#!/bin/bash
source ./route-env
GW=$1
gwMsg
echo;echo "!!! You have selected [$GW] as new Gateway !!! ";
gwDel
gwChange 
gwTest
echo " -----"
gwMsg
