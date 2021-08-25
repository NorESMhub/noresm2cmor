#!/bin/bash

CMOR_ROOT=$(cd $(dirname $0) && cd ../../.. && pwd)
source ${CMOR_ROOT}/workflow/cmorRun1memb.sh

# initialize
login0=false
login1=false

# set active
#login0=true
login1=true

# initialize
#version=v20190920
version=v20191108b

expid=hist-spAer-all
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
# hist-spAer-all, ensemble 1
#----------------
#CaseName=NHIST_spAer_f19_tn14_20190925
real=1
years1=(1849 $(seq 1860 10 1940))
years2=(1859 $(seq 1869 10 1949))
years1+=($(seq 1950 10 2000) 2010)
years2+=($(seq 1959 10 2009) 2014)

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI
#---
fi
#---

if $login1
then
#----------------
# hist-spAer-all, ensemble 2
#----------------
CaseName=NHIST_spAer_f19_tn14_20210523
real=2
physics=1
forcing=1
init=1
#years1=(1849 $(seq 1860 10 2000) 2010)
#years2=(1859 $(seq 1869 10 2009) 2014)
years1=(1860 1890 1900 1910 1930)
years2=(1869 1899 1909 1919 1939)

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
