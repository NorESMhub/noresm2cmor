#!/bin/bash

source ../scripts/runcmor_single.sh

#version=v20190920
version=v20191108b

if [ $# -eq 1 ]
then
    echo $#
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
#login3=true


expid=abrupt-4xCO2
echo "--------------------"
echo "EXPID: $expid     "
echo "--------------------"

echo "                    "
echo "START CMOR..."
echo "                    "

if $login0
then
#----------------
# abrupt-4xCO2 1
#----------------
CaseName=NCO2x4_f19_tn14_20190624
expid=abrupt-4xCO2
years1=(0  $(seq 11 10 111))
years2=(10 $(seq 20 10 120))

runcmor -c=$CaseName -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"
#---
fi
#---

if $login1
then
#----------------
# abrupt-4xCO2 2
#----------------
CaseName=NCO2x4_f19_tn14_20190705
expid=abrupt-4xCO2
years1=($(seq 121 10 141))
years2=($(seq 130 10 150))

runcmor -c=$CaseName -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"
#---
fi
#---

if $login2
then
#----------------
# abrupt-4xCO2 3
#----------------
CaseName=NCO2x4_f19_tn14_20190724
expid=abrupt-4xCO2
#login0
years1=($(seq 151 10 291))
years2=($(seq 160 10 300))
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
../../../scripts/create_CMIP6_links_sha256sum.sh $version ".cmorout/NorESM2-LM/${expid}/${version}" false

# zip log files
gzip ../../../logs/CMIP6_NorESM2-LM/${expid}/${version}/{*.log,*.err}
