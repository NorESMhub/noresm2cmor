#!/bin/bash

source ${CMOR_ROOT}/workflow/cmorRun1memb.sh

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

# initialize
#version=v20190920
version=v20191108b

expid=omip2
model=NorESM2-LM

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

if $login0
then
#----------------
# omip2
#----------------
#CaseName=NOIIAJRAOC20TR_TL319_tn14_20190710
#login0
years1=(1653 $(seq 1660 10 1750))
years2=(1659 $(seq 1669 10 1759))
#login1
years1+=($(seq 1760 10 1850))
years2+=($(seq 1769 10 1859))
#login2
years1+=($(seq 1860 10 1950))
years2+=($(seq 1869 10 1959))
#login3
years1+=($(seq 1960 10 2000) 2010)
years2+=($(seq 1969 10 2009) 2018)

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
${CMOR_ROOT}/workflow/cmorPost.sh -m=${model} -e=${expid} -v=${version} --verbose=false
