##!/bin/bash

CMOR_ROOT=$(cd $(dirname $0) && cd ../../.. && pwd)
source ${CMOR_ROOT}/workflow/cmorRun1memb.sh

# initialize
login0=false
login1=false
login2=false

# set active
login0=true
login1=true
login2=true

# initialize
#version=v20191108
version=v20200206

expid=ssp370-lowNTCF
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

echo "                    "
echo "START CMOR...       "
echo "$(date)             "
echo "                    "

if $login0
then
#----------------
# ssp370-lowNTCF, r1
#----------------
#CaseName=NSSP370LOWNTCFfrc2_f19_tn14_20191118
CaseName=NSSP370REFGHGLOWNTCFfrc2_f19_tn14_20191220
real=1
years1=(2015 $(seq 2021 10 2041) 2051)
years2=(2020 $(seq 2030 10 2050) 2054)

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI

#---
:
fi
#---

if $login1
then
#----------------
# ssp370-lowNTCF, r2
#----------------
#CaseName=NSSP370LOWNTCFfrc2_02_f19_tn14_20191118
CaseName=NSSP370REFGHGLOWNTCFfrc2_02_f19_tn14_20191220
real=2
years1=(2015 2021 2031 2041 2051)
years2=(2020 2030 2040 2050 2054)

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI

#---
:
fi
#---

if $login2
then
#----------------
# ssp370-lowNTCF, r3
#----------------
#CaseName=NSSP370LOWNTCFfrc2_03_f19_tn14_20191118
CaseName=NSSP370REFGHGLOWNTCFfrc2_03_f19_tn14_20191220
real=3
years1=(2015 2021 2031 2041 2051)
years2=(2020 2030 2040 2050 2054)

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI

#---
:
fi
#---

wait
echo "         "
echo "CMOR DONE"
echo "$(date)  "
echo "~~~~~~~~~"

# PrePARE QC check, create links and update sha256sum
${CMOR_ROOT}/workflow/cmorPost.sh -m=${model} -e=${expid} -v=${version} --verbose=false
