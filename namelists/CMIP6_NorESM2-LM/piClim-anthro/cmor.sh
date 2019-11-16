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


expid=piClim-anthro
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
# piClim-anthro
#----------------
#ExpName=NF1850norbc_anthro2014_f19_20190811
#login0
years1=(0  11 21)
years2=(10 20 30)

runcmor -c=$CaseName -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI
#---
fi
#---

wait
echo "         "
echo "CMOR DONE"
echo "~~~~~~~~~"

# PrePARE QC check, create links and update sha256sum
../scripts/cmorPost.sh -m=${model} -e=${expid} -v=${version} --verbose=false
