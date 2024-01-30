#!/bin/bash

CMOR_ROOT=$(cd $(dirname $0) && cd ../../.. && pwd)
source ${CMOR_ROOT}/workflow/cmorRun1memb.sh

# initialize
login0=false

# set active
login0=true

# initialize
version=v20230616
expid=piClim-control
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
# part 1
#----------------
CaseName=NF1850norbc_f19_f19_Forces_fsst_20231130
real=1
physics=4
forcing=1
init=1
years1=(1  $(seq 11 10 21))
years2=(10 $(seq 20 10 30))
years1=(21)
years2=(30)

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -p=$physics -f=$forcing -i=$init -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI
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
