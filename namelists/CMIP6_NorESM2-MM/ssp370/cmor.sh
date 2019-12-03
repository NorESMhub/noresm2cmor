##!/bin/bash

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
version=v20191108

expid=ssp370
model=NorESM2-MM

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
# ssp370
#----------------
CaseName=NSSP370frc2_f09_tn14_20191105
real=1
years1=(2015 $(seq 2021 10 2091))
years2=(2020 $(seq 2030 10 2100))

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -p=NS9560KFRAM -mpi=DMPI

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
