#!/bin/bash

source ../scripts/runcmor_single.sh

#version=v20190920
version=v20191108b

if [ $# -eq 1 ]
then
    version=$1
fi

# initialize
login0=false
login1=false
login2=false
login3=false

# set active
login0=true
login1=true
login2=true
login3=true


expid=esm-hist
model=NorESM2-LM
echo "--------------------"
echo "EXPID: $expid       "
echo "--------------------"

echo "                    "
echo "START CMOR..."
echo "                    "

if $login0
then
#----------------
# esm-hist
#----------------
#CaseName=NHIST_f19_tn14_20190909esm
#login1
years1=($(seq 1850 10 2000) 2010)
years2=($(seq 1859 10 2009) 2014)

runcmor -c=$CaseName -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"
#---
fi
#---

wait
echo "         "
echo "CMOR DONE"
echo "~~~~~~~~~"

# PrePARE QC check, create links and update sha256sum
../scripts/cmorPost.sh -m=${model} -e=${expid} -v=${version} --verbose=false
