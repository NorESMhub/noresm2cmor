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
version=v20191108

expid=piControl
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
# piControl, part 1
#----------------
CaseName=N1850frc2_f09_tn14_20191001
years1=($(seq 1200 10 1290))
years2=($(seq 1209 10 1299))

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -s=NS9560K -mpi=DMPI
#---
fi
#---

if $login1
then
#----------------
# piControl, part 2
#----------------
CaseName=N1850frc2_f09_tn14_20191012
years1=($(seq 1300 10 1440) 1450 )
years2=($(seq 1309 10 1449) 1450 )

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -s=NS9560KFRAM -mpi=DMPI
#---
fi
#---

if $login2
then
#----------------
# piControl, part 2
#----------------
CaseName=N1850frc2_f09_tn14_20191113
years1=($(seq 1450 10 1690))
years2=($(seq 1459 10 1699))

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -s=NS9560KFRAM -mpi=DMPI
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
