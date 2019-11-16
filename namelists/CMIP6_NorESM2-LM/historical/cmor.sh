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


expid=historical
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
# historical ensemble 1 part 1
#----------------
CaseName=NHIST_f19_tn14_20190625
real=1
#login0
years1=(1849 $(seq 1860 10 1940))
years2=(1859 $(seq 1869 10 1949))

runcmor -c=$CaseName -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"
#----------------
# historical ensemble 1 part 2
#----------------
CaseName=NHIST_f19_tn14_20190710
real=1
#login1
years1=($(seq 1950 10 2000) 2010)
years2=($(seq 1959 10 2009) 2014)

runcmor -c=$CaseName -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"
#---
fi
#---

if $login1
then
#----------------
# historical ensemble 2 part 1
#----------------
CaseName=NHIST_02_f19_tn14_20190801
real=2
#login0
years1=(1849 $(seq 1860 10 1940))
years2=(1859 $(seq 1869 10 1949))

runcmor -c=$CaseName -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"
#----------------
# historical ensemble 2 part 2
#----------------
CaseName=NHIST_02_f19_tn14_20190813
real=2
#login1
years1=($(seq 1950 10 2000) 2010)
years2=($(seq 1959 10 2009) 2014)

runcmor -c=$CaseName -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"
#---
fi
#---

if $login2
then
#----------------
# historical ensemble 3 part 1
#----------------
CaseName=NHIST_03_f19_tn14_20190801
real=3
#login2
years1=(1849 $(seq 1860 10 1940))
years2=(1859 $(seq 1869 10 1949))

runcmor -c=$CaseName -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"
#----------------
# historical ensemble 3 part 2
#----------------
CaseName=NHIST_03_f19_tn14_20190813
real=3
#login3
years1=($(seq 1950 10 2000) 2010)
years2=($(seq 1959 10 2009) 2014)

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
