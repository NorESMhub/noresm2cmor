#!/bin/bash
#set -ex
if [ $# -eq 0 ] || [ $1 == "--help" ]
 then
     printf "Usage:\n"
     printf "cmorTables.sh -m=[model] -e=[expid] -v=[version] -y=[start year]"
     exit
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
             -y=*)
                 tmp=$(echo $1|sed -e 's/^[^=]*=//g')
                 year=$(printf %04d $tmp)
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
echo "model: $model"
echo "expid: $expid"
echo "version: $version"
echo "year: $year"
echo ""

if [ $(hostname -f |grep 'ipcc') ]
then
    cmoroutroot=/scratch/NS9034K/CMIP6/.cmorout
else
    cmoroutroot=/projects/NS9034K/CMIP6/.cmorout
fi
for table in $(ls ${cmoroutroot}/${model}/${expid}/${version}/*${year}* |cut -d"_" -f2 |sort -u);
do
    nf=$(ls ${cmoroutroot}/${model}/${expid}/${version}/*_${table}_*${year}*-*.nc |wc -l);
    printf "$table \t $nf \n"
done
