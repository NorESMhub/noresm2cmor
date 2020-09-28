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

expid=hist-aer
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
# hist-aer, ensemble 1, part1
#----------------
CaseName=N1850aeroxidonly_f19_tn14_20190805
real=1
#
years1=(1849 $(seq 1860 10 1940))
years2=(1859 $(seq 1869 10 1949))

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"
#----------------
# hist-aer, ensemble 1, part2
#----------------
CaseName=N1850aeroxidonly_f19_tn14_20190815
real=1
#
years1=($(seq 1950 10 2000) 2010)
years2=($(seq 1959 10 2009) 2014)

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"
#----------------
# hist-aer, ensemble 1, part3
#----------------
CaseName=NSSP245frc2aeroxidonly_f19_tn14_20191015
real=1
#
years1=(2015)
years2=(2020)

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"

#---
fi
#---

if $login1
then
#----------------
# hist-aer, ensemble 2, part1
#----------------
CaseName=N1850aeroxidonly_02_f19_tn14_20190909
real=2
#
years1=(1849 $(seq 1860 10 1940))
years2=(1859 $(seq 1869 10 1949))
#
years1+=($(seq 1950 10 2000) 2010)
years2+=($(seq 1959 10 2009) 2014)
runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -s=NS2345K
#----------------
# hist-aer, ensemble 2, part2
#----------------
CaseName=NSSP245frc2aeroxidonly_02_f19_tn14_20191015
real=2
#
years1=(2015)
years2=(2020)

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"

#---
fi
#---

if $login2
then
#----------------
# hist-aer, ensemble 3, part1
#----------------
CaseName=N1850aeroxidonly_03_f19_tn14_20190913
real=3
#
years1=(1849 $(seq 1860 10 1940))
years2=(1859 $(seq 1869 10 1949))
#
years1+=($(seq 1950 10 2000) 2010)
years2+=($(seq 1959 10 2009) 2014)
runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -s=NS2345K
#----------------
# hist-aer, ensemble 3, part2
#----------------
CaseName=NSSP245frc2aeroxidonly_03_f19_tn14_20191015
real=3
#
years1=(2015)
years2=(2020)

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
