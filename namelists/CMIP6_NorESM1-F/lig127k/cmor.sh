#!/bin/bash

# load ENV
if [ $(hostname -f |grep 'ipcc') ]
then
    wfroot=/scratch/NS9034K/noresm2cmor/workflow
else
    wfroot=~/noresm2cmor/workflow
fi
source ${wfroot}/cmorRun1memb.sh

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

# initialize
#version=v20190920
version=v20191108b

expid=lig127k
model=NorESM1-F

# --- Use input arguments if exits
if [ $# -ge 1 ] 
then
     while test $# -gt 0; do
         case "$1" in
             -m=*)
                 model=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             -e=*)
                 expid=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             -v=*)
                 version=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             * )
                 echo "ERROR: option $1 not allowed."
                 echo "*** EXITING THE SCRIPT"
                 exit 1
                 ;;
         esac
    done
fi
# --- 

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
# lig127k
#----------------
#CaseName=NBF1850OC_f19_tn11_01_127ka
expid=lig127k

years1=($(seq 1501 10 1591))
years2=($(seq 1510 10 1600))

years1+=($(seq 1601 10 1691))
years2+=($(seq 1610 10 1700))

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"
#---
fi
#---

wait
echo "         "
echo "CMOR DONE"
echo "$(date)  "
echo "~~~~~~~~~"

# PrePARE QC check, create links and update sha256sum
${wfroot}/cmorPost.sh -m=${model} -e=${expid} -v=${version} --verbose=false
