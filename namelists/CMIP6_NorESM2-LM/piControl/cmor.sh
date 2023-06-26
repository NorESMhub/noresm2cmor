#!/bin/bash

CMOR_ROOT=$(cd $(dirname $0) && cd ../../.. && pwd)
source ${CMOR_ROOT}/workflow/cmorRun1memb.sh

# initialize
login0=false
login1=false
login2=false
login3=false

# set active
#login0=true
#login1=true
#login2=true
login3=true

# initialize
#version=v20190920
#version=v20191108b
version=v20200217
version=v20230616

expid=piControl
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
# piControl 1
#----------------
CaseName=N1850_f19_tn14_20190621
years1=($(seq 1600 10 1790) 1800)
years2=($(seq 1609 10 1799) 1800)

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI
#---
fi
#---

if $login1
then
#----------------
# piControl 2
#----------------
CaseName=N1850_f19_tn14_20190722
years1=($(seq 1801 10 1891))
years2=($(seq 1810 10 1900))

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI
#---
fi
#---

if $login2
then
#----------------
# piControl 3
#----------------
CaseName=N1850_f19_tn14_20190802
years1=($(seq 1901 10 1991))
years2=($(seq 1910 10 2000))
years1+=($(seq 2001 10 2091))
years2+=($(seq 2010 10 2100))

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI
#---
fi
#---

if $login3
then
#----------------
# piControl, physics 4
#----------------
CaseName=N1850_f19_tn14_Forces_230512
real=1
physics=4
forcing=1
init=1
#years1=(1601 $(seq 1610 10 1890) 1900)
#years2=(1609 $(seq 1619 10 1899) 1901)
#years1=($(seq 1690 10 1700))
#years2=($(seq 1699 10 1709))
#years1+=($(seq 1750 10 1820))
#years2+=($(seq 1759 10 1829))
years1+=($(seq 1840 10 1890))
years2+=($(seq 1849 10 1899))
years1+=(1900)
years2+=(1901)

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
