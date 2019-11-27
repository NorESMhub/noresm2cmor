#!/bin/bash
# link cmorized files and calculate sha256sum

if [ $# -eq 0 ] || [ $1 == "--help" ] 
 then
     printf "Usage:\n"
     printf "cmorPost -m=[model] -e=[expid] -v=[version] --verbose=[true|false]"
     exit 1
 else
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
             --verbose=*)
                 verbose=$(echo $1|sed -e 's/^[^=]*=//g')
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

if [[ -z $model || -z $expid || -z $version ]]; then
    echo 'ERROR:One or more variables $model $expid $version are undefined'
    echo 'EXIT...'
    exit 1
fi
if [ -z $verbose ]; then
    verbose=false
fi

if [ $(hostname -f |grep 'ipcc') ]
then
    PATH=/scratch/NS9034K/noresm2cmor/workflow:$PATH
else
    PATH=~/noresm2cmor/workflow:$PATH
fi

# PrePARE QC check
source cmorQC.sh
cmorQC -m=$model -e=$expid -v=$version

# rsync from ipcc to nird node
cmorRsync.sh -m=$model -e=$expid -v=$version

# Create links
cmorLink.sh -m=$model -e=$expid -v=$version --verbose=${verbose}

# Calculate sha256sum
cmorSha256sum.sh -m=$model -e=$expid -v=$version --verbose=${verbose}

# zip log files
/usr/bin/gzip -f ${wfroot}/logs/CMIP6_${model}/${expid}/${version}/{*.log,*.err} 2>/dev/null
