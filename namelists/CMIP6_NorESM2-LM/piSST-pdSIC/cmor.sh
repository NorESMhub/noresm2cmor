#!/bin/bash

source ${CMOR_ROOT}/workflow/cmorRunNmemb.sh

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
#version=v20191009
#version=v20191018
version=v20191108b

expid=piSST-pdSIC
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
# pdSST-pdSIC part1
#----------------
CaseName=m1-25
years1=(2000)
years2=(2001)
month1=6
month2=5

reals=(   1    2    3    4    5    6    7    8    9   10   11   12   13)
membs=(0001 0002 0003 0004 0005 0006 0007 0008 0009 0010 0011 0012 0013)

reals+=(  14   15   16   17   18   19   20   21   22   23   24   25)
membs+=(0014 0015 0016 0017 0018 0019 0020 0021 0022 0023 0024 0025)

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -yrs1="${years1[*]}" -yrs2="${years2[*]}" \
    -mon1=$month1 -mon2=$month2 -r="${reals[*]}" -membs="${membs[*]}"
#---
fi
#---

if $login1
then
#----------------
# piSST-pdSIC part2
#----------------
CaseName=m26-50
years1=(2000)
years2=(2001)
month1=6
month2=5

reals=(  26   27   28   29   30   31   32   33   34   35   36   37)
membs=(0001 0002 0003 0004 0005 0006 0007 0008 0009 0010 0011 0012)

reals+=(  38   39   40   41   42   43   44   45   46   47   48   49   50)
membs+=(0013 0014 0015 0016 0017 0018 0019 0020 0021 0022 0023 0024 0025)

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -yrs1="${years1[*]}" -yrs2="${years2[*]}" \
    -mon1=$month1 -mon2=$month2 -r="${reals[*]}" -membs="${membs[*]}"
#---
fi
#---

if $login2
then
#----------------
# piSST-pdSIC part3
#----------------
CaseName=m51-75
years1=(2000)
ears2=(2001)
month1=6
month2=5

reals=(  51   52   53   54   55   56   57   58   59   60   61   62)
membs=(0001 0002 0003 0004 0005 0006 0007 0008 0009 0010 0011 0012)

reals+=(  63   64   65   66   67   68   69   70   71   72   73   74   75)
membs+=(0013 0014 0015 0016 0017 0018 0019 0020 0021 0022 0023 0024 0025)

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -yrs1="${years1[*]}" -yrs2="${years2[*]}" \
    -mon1=$month1 -mon2=$month2 -r="${reals[*]}" -membs="${membs[*]}"
#---
fi
#---

if $login3
then
#----------------
# piSST-pdSIC part4
#----------------
CaseName=m76-100
years1=(2000)
years2=(2001)
month1=6
month2=5

reals=(  76   77   78   79   80   81   82   83   84   85   86   87)
membs=(0001 0002 0003 0004 0005 0006 0007 0008 0009 0010 0011 0012)

reals+=(  88   89   90   91   92   93   94   95   96   97   98   99  100)
membs+=(0013 0014 0015 0016 0017 0018 0019 0020 0021 0022 0023 0024 0025)

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -yrs1="${years1[*]}" -yrs2="${years2[*]}" \
    -mon1=$month1 -mon2=$month2 -r="${reals[*]}" -membs="${membs[*]}"
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
