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
login1=true
login2=true
login3=true


expid=lig127k
echo "--------------------"
echo "EXPID: $expid     "
echo "--------------------"

echo "                    "
echo "START CMOR..."
echo "                    "

if $login0
then
#----------------
# midPliocene-eoi400
#----------------
#CaseName=PlioMIP2_03
expid=midPliocene-eoi400

years1=($(seq 2301 10 2391))
years2=($(seq 2310 10 2400))

years1+=($(seq 2401 10 2491))
years2+=($(seq 2410 10 2500))

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
gzip ../../../logs/CMIP6_NorESM1-F/${expid}/${version}/{*.log,*.err}
