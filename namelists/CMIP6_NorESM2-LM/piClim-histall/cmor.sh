#!/bin/bash

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
#version=v20190920
#version=v20191108b
#version=v20200218
version=v20200702

expid=piClim-histall
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
# piClim-histall, esemble 1
#----------------
CaseName=NFHISTnorpibc_f19_20190810
real=1
years1=(1849 $(seq 1860 10 1940))
years2=(1859 $(seq 1869 10 1949))
years1+=($(seq 1950 10 2000) 2010)
years2+=($(seq 1959 10 2009) 2014)

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI -s=NS9560K
#---
fi
#---
if $login1
then
#----------------
# piClim-histall, esemble 2
#----------------
CaseName=NFHISTnorpibc_02_f19_20190909
real=2
years1=(1849 $(seq 1860 10 1940))
years2=(1859 $(seq 1869 10 1949))
years1+=($(seq 1950 10 2000) 2010)
years2+=($(seq 1959 10 2009) 2014)

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI -s=NS9560K
#---
fi
#---

if $login2
then
#----------------
# piClim-histall, esemble 3
#----------------
CaseName=NFHISTnorpibc_03_f19_20190923
real=3
years1=(1849 $(seq 1860 10 1940))
years2=(1859 $(seq 1869 10 1949))
years1+=($(seq 1950 10 2000) 2010)
years2+=($(seq 1959 10 2009) 2014)

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI -s=NS9560K
#---
fi
#---

if $login3
then
#----------------
# piClim-histall, real 1, physics 2
#----------------
CaseName=NFHISTnorpibc_f19_20191208
real=1
physics=2
years1=(1849 $(seq 1860 10 2000) 2010)
years2=(1859 $(seq 1869 10 2009) 2014)

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -p=$physics -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI -s=NS9560K

CaseName=NFSSP245frc2norpibc_f19_20200520
real=1
physics=2
years1=(2015 $(seq 2021 10 2091))
years2=(2020 $(seq 2030 10 2100))

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -p=$physics -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI -s=NS2345K
#---
fi
#---

if $login4
then
#----------------
# piClim-histall, real 2, physics 2
#----------------
CaseName=NFHISTnorpibc_02_f19_20200118
real=2
physics=2
years1=(1849 $(seq 1860 10 2000) 2010)
years2=(1859 $(seq 1869 10 2009) 2014)

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -p=$physics -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI -s=NS9560K

CaseName=NFSSP245frc2norpibc_02_f19_20200703
real=2
physics=2
years1=(2015 $(seq 2021 10 2091))
years2=(2020 $(seq 2030 10 2100))

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -p=$physics -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI -s=NS9560K
#---
fi
#---

if $login5
then
#----------------
# piClim-histall, real 3, physics 2
#----------------
CaseName=NFHISTnorpibc_03_f19_20200118
real=3
physics=2
years1=(1849 $(seq 1860 10 2000) 2010)
years2=(1859 $(seq 1869 10 2009) 2014)

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -p=$physics -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI -s=NS9560K

CaseName=NFSSP245frc2norpibc_03_f19_20200703
real=3
physics=2
years1=(2015 $(seq 2021 10 2091))
years2=(2020 $(seq 2030 10 2100))

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -p=$physics -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI -s=NS9560K
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
