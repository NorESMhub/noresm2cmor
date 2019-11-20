##!/bin/bash
set -x

source ../scripts/runcmor_single.sh

version=v20190920
#version=v20191108b

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
#login3=true


expid=hist-GHG
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
# hist-GHG emsemble 1, part 1
#----------------
CaseName=N1850ghgonly_f19_tn14_20190712
real=1
years1=(1849 $(seq 1860 10 2000) 2010)
years2=(1859 $(seq 1869 10 2009) 2014)

runcmor -c=$CaseName -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"

#----------------
# hist-GHG emsemble 1, part 2
#----------------
CaseName=NSSP245frc2ghgonly_f19_tn14_20191015
real=1
years1=(2015)
years2=(2020)

runcmor -c=$CaseName -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"
#---
fi
#---

if $login1
then
#----------------
# hist-GHG emsemble 2, part 1
#----------------
CaseName=N1850ghgonly_02_f19_tn14_20190909
real=2
years1=(1849 $(seq 1860 10 2000) 2010)
years2=(1859 $(seq 1869 10 2009) 2014)

runcmor -c=$CaseName -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"

#----------------
# hist-GHG emsemble 2, part 2
#----------------
CaseName=NSSP245frc2ghgonly_02_f19_tn14_20191015
real=2
years1=(2015)
years2=(2020)

runcmor -c=$CaseName -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"
#---
fi
#---

if $login2
then
#----------------
# hist-GHG emsemble 3, part 1
#----------------
CaseName=N1850ghgonly_03_f19_tn14_20190913
real=3
years1=(1849 $(seq 1860 10 2000) 2010)
years2=(1859 $(seq 1869 10 2009) 2014)

runcmor -c=$CaseName -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"

#----------------
# hist-GHG emsemble 3, part 2
#----------------
CaseName=NSSP245frc2ghgonly_03_f19_tn14_20191015
real=3
years1=(2015)
years2=(2020)

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
