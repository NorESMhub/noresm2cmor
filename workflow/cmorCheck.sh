#!/bin/bash

if [ $# -eq 0 ] || [ $1 == "--help" ] 
 then
     printf "Usage:\n"
     printf 'cmorCheck -e=[expid] -v=[version] -m=[model]\
                       -o=[cmorout] \
                       -yrs1=[(${years1[*]})] -yrs2=[(${years2[*]})]'
     exit
 else
     while test $# -gt 0; do
         case "$1" in
             -e=*)
                 expid=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             -v=*)
                 version=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             -m=*)
                 model=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             -o=*)
                 cmoroutroot=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             -yrs1=*)
                 years1=($(echo $1|sed -e 's/^[^=]*=//g'))
                 shift
                 ;;
             -yrs2=*)
                 years2=($(echo $1|sed -e 's/^[^=]*=//g'))
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

if [ -z $cmoroutroot ]
then
    cmoroutroot=/projects/NS9034K/CMIP6/.cmorout
fi
variants=($(find ${cmoroutroot}/${model}/${expid}/${version} -type f -name '*.nc' -print | \
    awk -F"/" '{print $NF}' |cut -d"_" -f5 |sort -u --version-sort))
for (( r = 0; r < ${#variants[*]}; r++ )); do
    variant=${variants[r]}
    printf "variant: $variant\n"
    nfs=$(ls ${cmoroutroot}/${model}/${expid}/${version}/*_{Ofx,fx}_*_${variant}_*.nc 2>/dev/null |wc -l)
    printf "Ofx, fx, etc\t$nfs\n"
    printf "yyyy1\tyyyy2\tnf\n"
    for (( i = 0; i < ${#years1[*]}; i++ )); do
        yyyy1=$(printf %04d ${years1[i]})
        yyyy2=$(printf %04d ${years2[i]})
        nf=$(ls ${cmoroutroot}/${model}/${expid}/${version}/*_${variant}_*_${yyyy1}*-${yyyy2}*.nc 2>/dev/null |wc -l)
        printf "${yyyy1}\t${yyyy2}\t$nf\n"
        let nfs+=$nf
    done
    printf "Total:\t\t$nfs\n"

    find ${cmoroutroot}/${model}/${expid}/${version} -name "*_${variant}_*.nc" -print | \
        grep -e '_g[nmr][a-zA-Z0-9][^_]' >/tmp/wrongfiles.txt.$$
    nf=$(cat /tmp/wrongfiles.txt.$$ |wc -l)
    if [ $nf -ge 1 ]
    then
        printf "Unfinished files:\n"
        while read -r fname
        do
            ls -gGh $fname |cut -d" " -f3-8
        done </tmp/wrongfiles.txt.$$
        read -p "Remove unfinished files [Y/N] "
    else
        REPLY="N"
    fi
    if [ ! -z $REPLY ] && [ $REPLY == "Y" ]
    then
        while read -r fname
        do
            rm -f $fname
        done </tmp/wrongfiles.txt.$$
        echo "ALL wrong files removed!"
    fi
    rm -f /tmp/wrongfiles.txt.$$
done
