#!/bin/bash

CMOR_ROOT=$(cd $(dirname $0) && cd ../../.. && pwd)
source ${CMOR_ROOT}/workflow/cmorRunNmemb.sh

# initialize
login0=false
login1=false
login2=false
login3=false
login4=false
login5=false
login6=false
login7=false

# set active
#login0=true
#login1=true
#login2=true
#login3=true
login4=true
login5=true
login6=true
login7=true

# initialize
#version=v20190920
#version=v20191009
#version=v20191018
#version=v20191108b
#version=v20200218
version=v20230616

expid=pdSST-pdSIC
model=NorESM2-LM

system=NS2345K
#system=NS2345K2

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
# pdSST-pdSIC part2
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
# pdSST-pdSIC part3
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
# pdSST-pdSIC part4
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

if $login4
then
#----------------
# pdSST-pdSIC part5
#----------------
CaseName=m101-125
years1=(2000)
years2=(2001)
month1=6
month2=5

reals=( 101  102  103  104  105  106  107  108  109  110  111  112)
membs=(0001 0002 0003 0004 0005 0006 0007 0008 0009 0010 0011 0012)
#
reals+=( 113  114  115  116  117  118  119  120  121  122  123  124  125)
membs+=(0013 0014 0015 0016 0017 0018 0019 0020 0021 0022 0023 0024 0025)

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -yrs1="${years1[*]}" -yrs2="${years2[*]}" \
    -mon1=$month1 -mon2=$month2 -r="${reals[*]}" -membs="${membs[*]}" -s=${system}
#---
fi
#---

if $login5
then
#----------------
# pdSST-pdSIC part6
#----------------
CaseName=m126-150
years1=(2000)
years2=(2001)
month1=6
month2=5

reals=( 126  127  128  129  130  131  132  133  134  135  136  137)
membs=(0001 0002 0003 0004 0005 0006 0007 0008 0009 0010 0011 0012)
#
reals+=( 138  139  140  141  142  143  144  145  146  147  148  149  150)
membs+=(0013 0014 0015 0016 0017 0018 0019 0020 0021 0022 0023 0024 0025)

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -yrs1="${years1[*]}" -yrs2="${years2[*]}" \
    -mon1=$month1 -mon2=$month2 -r="${reals[*]}" -membs="${membs[*]}" -s=${system}
#---
fi
#---

if $login6
then
#----------------
# pdSST-pdSIC part7
#----------------
CaseName=m151-175
years1=(2000)
years2=(2001)
month1=6
month2=5

reals=( 151  152  153  154  155  156  157  158  159  160  161  162)
membs=(0001 0002 0003 0004 0005 0006 0007 0008 0009 0010 0011 0012)
#
reals+=( 163  164  165  166  167  168  169  170  171  172  173  174  175)
membs+=(0013 0014 0015 0016 0017 0018 0019 0020 0021 0022 0023 0024 0025)

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -yrs1="${years1[*]}" -yrs2="${years2[*]}" \
    -mon1=$month1 -mon2=$month2 -r="${reals[*]}" -membs="${membs[*]}" -s=${system}
#---
fi
#---

if $login7
then
#----------------
# pdSST-pdSIC part8
#----------------
CaseName=m176-200
years1=(2000)
years2=(2001)
month1=6
month2=5

reals=( 176  177  178  179  180  181  182  183  184  185  186  187)
membs=(0001 0002 0003 0004 0005 0006 0007 0008 0009 0010 0011 0012)
#
reals+=( 188  189  190  191  192  193  194  195  196  197  198  199  200)
membs+=(0013 0014 0015 0016 0017 0018 0019 0020 0021 0022 0023 0024 0025)

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -yrs1="${years1[*]}" -yrs2="${years2[*]}" \
    -mon1=$month1 -mon2=$month2 -r="${reals[*]}" -membs="${membs[*]}" -s=${system}
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
