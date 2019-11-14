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
login3=true


expid=omip2
echo "--------------------"
echo "EXPID: $expid     "
echo "--------------------"

if $login0
then
#----------------
# omip2
#----------------
#CaseName=NOIIAJRAOC20TR_TL319_tn14_20190710
expid=omip2
#login0
years1=(1653 $(seq 1660 10 1750))
years2=(1659 $(seq 1609 10 1759))
#login1
years1+=($(seq 1760 10 1850))
years2+=($(seq 1769 10 1859))
#login2
years1+=($(seq 1860 10 1950))
years2+=($(seq 1869 10 1959))
#login3
years1+=($(seq 1960 10 2000) 2010)
years2+=($(seq 1969 10 2009) 2018)

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
