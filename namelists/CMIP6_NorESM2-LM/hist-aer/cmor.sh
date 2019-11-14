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


expid=hist-aer
echo "--------------------"
echo "EXPID: $expid     "
echo "--------------------"

echo "                    "
echo "START CMOR..."
echo "                    "

if $login0
then
#----------------
# hist-aer, ensemble 1, part1
#----------------
CaseName=N1850aeroxidonly_f19_tn14_20190805
expid=hist-aer
real=1
#
years1=(1849 $(seq 1860 10 1940))
years2=(1859 $(seq 1869 10 1949))

runcmor -c=$CaseName -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"
#----------------
# hist-aer, ensemble 1, part2
#----------------
CaseName=N1850aeroxidonly_f19_tn14_20190815
expid=hist-aer
real=1
#
years1=($(seq 1950 10 2000) 2010)
years2=($(seq 1959 10 2009) 2014)

runcmor -c=$CaseName -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"
#----------------
# hist-aer, ensemble 1, part3
#----------------
CaseName=NSSP245frc2aeroxidonly_f19_tn14_20191015
expid=hist-aer
real=1
#
years1=(2015)
years2=(2020)

runcmor -c=$CaseName -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"

#---
fi
#---

if $login1
then
#----------------
# hist-aer, ensemble 2, part1
#----------------
CaseName=N1850aeroxidonly_02_f19_tn14_20190909
expid=hist-aer
real=2
#
years1=(1849 $(seq 1860 10 1940))
years2=(1859 $(seq 1869 10 1949))
#
years1+=($(seq 1950 10 2000) 2010)
years2+=($(seq 1959 10 2009) 2014)
runcmor -c=$CaseName -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -p=NS2345K
#----------------
# hist-aer, ensemble 2, part2
#----------------
CaseName=NSSP245frc2aeroxidonly_02_f19_tn14_20191015
expid=hist-aer
real=2
#
years1=(2015)
years2=(2020)

runcmor -c=$CaseName -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"

#---
fi
#---

if $login2
then
#----------------
# hist-aer, ensemble 3, part1
#----------------
CaseName=N1850aeroxidonly_03_f19_tn14_20190913
expid=hist-aer
real=3
#
years1=(1849 $(seq 1860 10 1940))
years2=(1859 $(seq 1869 10 1949))
#
years1+=($(seq 1950 10 2000) 2010)
years2+=($(seq 1959 10 2009) 2014)
runcmor -c=$CaseName -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -p=NS2345K
#----------------
# hist-aer, ensemble 3, part2
#----------------
CaseName=NSSP245frc2aeroxidonly_03_f19_tn14_20191015
expid=hist-aer
real=3
#
years1=(2015)
years2=(2020)

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
