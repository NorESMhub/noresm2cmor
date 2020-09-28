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
#login2=true
#login3=true

# initialize
version=v20200702

expid=ssp126-ssp370Lu
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
# ssp126-ssp370Lu, common variables
#----------------
#CaseName=b.e21.NSSP126frc2.f19_tn14.CMIP6-SSP1-2.6-SSP3-7.0Lu.001
years1=(2015 $(seq 2021 10 2091))
years2=(2020 $(seq 2030 10 2100))

rm -f $CMOR_ROOT/bin/filelist_b.e21.NSSP126frc2.f19_tn14.CMIP6-SSP1-2.6-SSP3-7.0Lu.001
runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"  -mpi=DMPI
#---
fi
#---

if $login1
then

#----------------
# ssp126-ssp370Lu, LUMIP variables
#----------------
#CaseName=b.e21.NSSP126frc2.f19_tn14.CMIP6-SSP1-2.6-SSP3-7.0Lu.001
years1=(2015 $(seq 2021 10 2091))
years2=(2020 $(seq 2030 10 2100))

rm -f $CMOR_ROOT/bin/filelist_b.e21.NSSP126frc2.f19_tn14.CMIP6-SSP1-2.6-SSP3-7.0Lu.001
runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI -s=LUMIP
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
