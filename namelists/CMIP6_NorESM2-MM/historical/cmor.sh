#!/bin/bash

CMOR_ROOT=$(cd $(dirname $0) && cd ../../.. && pwd)
source ${CMOR_ROOT}/workflow/cmorRun1memb.sh

# initialize
login0=false
login1=false
login2=false
login3=false
login4=false
login5=false

# set active
login0=true
login1=true
login2=true
login3=true
login4=true
login5=true

# initialize
#version=v20191108
#version=v20200218
version=v20200702

expid=historical
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
# historical, part 1
#----------------
CaseName=NHISTfrc2_f09_tn14_20191001
years1=(1849 $(seq 1860 10 1940))
years2=(1859 $(seq 1869 10 1949))

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI
#---
fi
#---

if $login1
then
#----------------
# historical, part 2
#----------------
CaseName=NHISTfrc2_f09_tn14_20191025
years1=($(seq 1950 10 2000) 2010 )
years2=($(seq 1959 10 2009) 2014 )

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI
#---
fi
#---

if $login2
then
#----------------
# historical, r2i1p1f1, part 1
#----------------
CaseName=NHISTfrc2_02_f09_tn14_20200427
years1=(1849 $(seq 1860 10 1940))
years2=(1859 $(seq 1869 10 1949))

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI
#---
fi
#---

if $login3
then
#----------------
# historical, r2i1p1f1, part 2
#----------------
CaseName=NHISTfrc2_02_f09_tn14_20200519
years1=($(seq 1950 10 2000) 2010 )
years2=($(seq 1959 10 2009) 2014 )

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI
#---
fi
#---

if $login4
then
#----------------
# historical, r3i1p1f1, part 1
#----------------
CaseName=NHISTfrc2_03_f09_tn14_20200519
real=3
physics=1
years1=(1849 $(seq 1860 10 1930) 1940)
years2=(1859 $(seq 1869 10 1939) 1949)

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI
#---
fi
#---

if $login5
then
#----------------
# historical, r3i1p1f1, part 2
#----------------
CaseName=NHISTfrc2_03_f09_tn14_20200619
real=3
physics=1
years1=(1950 $(seq 1960 10 2000) 2010)
years2=(1959 $(seq 1969 10 2009) 2014)

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI
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
