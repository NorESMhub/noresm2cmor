#!/bin/bash

source ../scripts/runcmor_single.sh

#version=vyyyymmdd
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
#login1=true
#login2=true
#login3=true


expid=piControl
echo "--------------------"
echo "EXPID: $expid     "
echo "--------------------"

echo "                    "
echo "START CMOR..."
echo "                    "

if $login0
then
#----------------
# piControl
#----------------
#CaseName=NBF1850OC_f19_tn11_02
expid=piControl

years1=($(seq 1501 10 1591))
years2=($(seq 1510 10 1600))

years1+=($(seq 1601 10 1691))
years2+=($(seq 1610 10 1700))

runcmor -c=$CaseName -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"
#---
fi
#---

wait
echo "         "
echo "CMOR DONE"
echo "~~~~~~~~~"

# PrePARE QC check
source ../scripts/cmorQC.sh
cmorQC -e=$expid -v=$version

# Create links and sha256sum
../../../scripts/create_CMIP6_links_sha256sum.sh $version ".cmorout/NorESM1-F/${expid}/${version}" false

# zip log files
gzip -f ../../../logs/CMIP6_NorESM1-F/${expid}/${version}/{*.log,*.err}
