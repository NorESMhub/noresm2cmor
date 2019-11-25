##!/bin/bash
#set -x

source ../scripts/runcmor_single.sh

#version=v20190920
#version=v20191108b
version=v20191108

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
#login1=true
#login2=true
#login3=true


expid=esm-pi-cdr-pulse
model=NorESM2-LM
echo "--------------------"
echo "EXPID: $expid       "
echo "--------------------"

echo "                    "
echo "START CMOR...       "
echo "$(date)             "
echo "                    "

if $login0
then
#----------------
# esm-pi-cdr-pulse
#----------------
CaseName=N1850_f19_tn14_CDRpulse_20191101esm
#real=1
years1=(1849 $(seq 1860 10 1940))
years2=(1859 $(seq 1869 10 1949))

runcmor -c=$CaseName -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI

#---
fi
#---

wait
echo "         "
echo "CMOR DONE"
echo "$(date)  "
echo "~~~~~~~~~"

# PrePARE QC check, create links and update sha256sum
../scripts/cmorPost.sh -m=${model} -e=${expid} -v=${version} --verbose=false
