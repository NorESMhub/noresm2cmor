#!/bin/bash

# rsync form ipcc to nird node
#
if [ $# -eq 0 ] || [ $1 == "--help" ] 
 then
     printf "Usage:\n"
     printf "cmorRsync.sh -m=[model] -e=[expid] -v=[version]"
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
             * )
                 echo "ERROR: option $1 not allowed."

                 echo "*** EXITING THE SCRIPT"
                 exit 1
                 ;;
         esac
    done
fi
if [ ! $(hostname -f |grep 'ipcc') ]
then
    echo "ON IPCC.NIRD          "
    echo "SKIP cmorRsync,EXIT..."
    exit 1
else
    echo "~~~~~~~~~~~~~~~~~~~~"
    echo "rsync from          "
    echo "  ipcc:/scratch/NS9034K/CMIP6/.cmorout/${model}/${expid}/${version}"
    echo "to                  "
    echo "  nird:/projects/NS9034K/CMIP6/.cmorout/${model}/${expid}/${version}"
fi

if [ ! -d logs ]; then
    mkdir logs
fi
/usr/bin/rsync --verbose --progress --recursive --compress --remove-source-files --perms --times --group --owner \
    /scratch/NS9034K/CMIP6/.cmorout/${model}/${expid}/${version}/ \
    $USER@login.nird.sigma2.no:/projects/NS9034K/CMIP6/.cmorout/${model}/${expid}/${version}/ \
    &>./logs/cmorRysnc.log.$expid &
wait

/usr/bin/scp /scratch/NS9034K/CMIP6/.cmorout/${model}/${expid}/${version}.QCreport* \
    $USER@login.nird.sigma2.no:/projects/NS9034K/CMIP6/.cmorout/${model}/${expid}/ &
wait

echo "rsync done          "
echo "~~~~~~~~~~~~~~~~~~~~"
