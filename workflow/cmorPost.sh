#!/bin/bash
# link cmorized files and calculate sha256sum

if [ $# -eq 0 ] || [ $1 == "--help" ] 
 then
     printf "Usage:\n"
     printf "cmorPost -m=[model] -e=[expid] -v=[version] \n"
     printf "         --verbose=[true|false]                :set verbose information output. default false\n"
     printf "         --errexit=[true|false]                :set exit with error. default true\n"
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
             --errexit=*)
                 errexit=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             * )
                 echo "ERROR: option $1 not allowed."

                 #echo "*** EXITING THE SCRIPT"
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
# set default values
[ -z $verbose ] && verbose=false
[ -z $errexit ] && errexit=true

#if [ $(hostname -f |grep 'ipcc') ]
#then
    #echo "                       "
    #echo "On IPCC node!!!        "
    #echo "SKIP cmorPOST.sh...    "
    #echo "~~~~~~~~~~~~~~~~~~~~~~~"
    #exit 1
#fi

# PrePARE QC check
CMOR_ROOT=$(cd $(dirname $0) && cd .. && pwd)
${CMOR_ROOT}/workflow/cmorQC.sh -m=$model -e=$expid -v=$version --errexit=$errexit
[ $? -ne 0 ] && echo -e "\e[1;31;47m **ERROR** \e[0m occurs within cmorQC.sh. EXIT..." && exit 1

# rsync from ipcc.nird to login.nird node
#${CMOR_ROOT}/workflow/cmorRsync.sh -m=$model -e=$expid -v=$version &>/dev/null &

# Create links
${CMOR_ROOT}/workflow/cmorLink.sh -m=$model -e=$expid -v=$version --verbose=${verbose}
[ $? -ne 0 ] && echo -e "\e[1;31;47m **ERROR** \e[0m occurs within cmorLink.sh. EXIT..." && exit 1

# Calculate sha256sum
${CMOR_ROOT}/workflow/cmorSha256sum.sh -m=$model -e=$expid -v=$version --verbose=${verbose}
[ $? -ne 0 ] && echo -e "\e[1;31;47m **ERROR** \e[0m occurs within cmorSha256sum.sh. EXIT..." && exit 1

# zip log files
gzip -f ${CMOR_ROOT}/logs/CMIP6_${model}/${expid}/${version}/{*.log,*.err} 2>/dev/null
