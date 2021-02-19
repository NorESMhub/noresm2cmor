#!/bin/env bash
# PrePARE QC check

if [ $# -eq 0 ] || [ $1 == "--help" ] 
 then
     printf "Usage:\n"
     printf "cmorQC -m=[model] -e=[expid] -v=[version]\n"
     printf "       --errexit=[true|false]              :exit with error. default as true\n"
     exit 0
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
             --errexit=*)
                 errexit=$(echo $1|sed -e 's/^[^=]*=//g')
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

[ -z $errexit ] && errexit=true

# ENV for PrePARE
export PATH=/opt/anaconda3/bin:${PATH}
export CMIP6_CMOR_TABLES=/projects/NS9560K/cmor/noresm2cmor/tables

##if [ $(hostname -f |grep 'ipcc') ]
#then
    #cmoroutroot=/scratch/NS9034K/CMIP6
    #source activate /scratch/NS9034K/cmorlib/PrePARE
#else
    cmoroutroot=/projects/NS9034K/CMIP6
    source activate /projects/NS9560K/cmor/PrePARE
#fi

echo "~~~~~~~~~~~~~~~~~~~~"
echo "PrePARE QC CHECK... "
#cdw=$(pwd)
cd ${cmoroutroot}/.cmorout/${model}/${expid}
rm -f ${version}.QCreport ${version}.QCreportlong
files=($(find ./${version} -name '*.nc' -print))
nf=${#files[*]}
echo "$nf files           "
echo "                    "
rls=$(echo ${files[*]} |tr ' ' '\n' |cut -d"_" -f5 |sort -u --version-sort)
for rls in $(echo ${rls[*]})
do
    files=($(find ./${version} -name "*${rls}*.nc" -print))
    tbs=$(echo ${files[*]} |tr ' ' '\n' |cut -d"_" -f2 |sort -u)
    nf=${#files[*]}
    echo ${rls}: $nf files >>${version}.QCreport
    for table in $(echo ${tbs[*]})
    do
        nf2=$(ls ${version}/*_${table}_*_${rls}_*.nc |wc -l)
        if [ $nf2 -gt 0 ]; then
            echo ${table} >>${version}.QCreport
            PrePARE --max-processes 8 \
                ${version}/*_${table}_*_${rls}_*.nc &>>./${version}.QCreportlong
            wait
            tail -2 ./${version}.QCreportlong >>${version}.QCreport
            printf %n >>${version}.QCreport
        fi
    done
    echo ""
done

wait

# check if error in QC report
nerr=0
while read -r line
do
    ne=$(echo $line | command grep 'error(s)' |sed 's/\[0m//g' |sed 's/[^0-9]//g')
    if [ ! -z $ne ]
    then
        let nerr+=$ne
    fi
done <${version}.QCreport

if [ $nerr -gt 0 ]
then
    echo -e "\e[1;31;47m **ERROR** \e[0m in ${version}.QCreport"
    if $errexit; then
        echo "** EXIT **" && exit 1
    else
        echo "But continue with error..."
    fi
else
    echo "         "
    echo "QC DONE  "
    echo "~~~~~~~~~"
    echo "         "
fi
