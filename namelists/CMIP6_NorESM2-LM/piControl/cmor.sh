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


expid=piControl
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
# piControl 1
#----------------
CaseName=N1850_f19_tn14_20190621
years1=($(seq 1600 10 1790) 1800)
years2=($(seq 1609 10 1799) 1800)

runcmor -c=$CaseName -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"
#---
fi
#---

if $login1
then
#----------------
# piControl 2
#----------------
CaseName=N1850_f19_tn14_20190722
years1=($(seq 1801 10 1891))
years2=($(seq 1810 10 1900))

runcmor -c=$CaseName -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"
#---
fi
#---

if $login2
then
#----------------
# piControl 3
#----------------
CaseName=N1850_f19_tn14_20190802
years1=($(seq 1901 10 1991))
years2=($(seq 1910 10 2000))
years1+=($(seq 2001 10 2091))
years2+=($(seq 2010 10 2100))

runcmor -c=$CaseName -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"
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
