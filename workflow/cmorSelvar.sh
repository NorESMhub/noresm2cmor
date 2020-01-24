#!/bin/bash
set -e

if [ $# -eq 0 ] || [ $1 == "--help" ]
 then
     printf "Usage:\n"
     printf 'cmorSelvar.sh -m=[model] -e=[expid] -v=[version] -r=[realisation] \
                     -yr1=[year1] -yr2=[year2] -ryr1=[refer year1]  -ryr2=[refer year2] \n'
     printf 'e.g.,:\n'
     printf 'cmorSelvar.sh -m=NorESM2-LM -e=ssp370 -v=v20191108 -r=3 -yr1=2031 -yr2=2040 -ryr1=2051 -ryr2=2054 \n'
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
             -r=*)
                 real=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             -yr1=*)
                 year1=($(echo $1|sed -e 's/^[^=]*=//g'))
                 shift
                 ;;
             -yr2=*)
                 year2=($(echo $1|sed -e 's/^[^=]*=//g'))
                 shift
                 ;;
             -ryr1=*)
                 ryear1=($(echo $1|sed -e 's/^[^=]*=//g'))
                 shift
                 ;;
             -ryr2=*)
                 ryear2=($(echo $1|sed -e 's/^[^=]*=//g'))
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

cmorout=/tos-project1/NS9034K/CMIP6/.cmorout
pnml=${CMOR_ROOT}/namelists/CMIP6_${model}/${expid}/${version}
plog=${CMOR_ROOT}/logs/CMIP6_${model}/${expid}/${version}

ls ${cmorout}/${model}/${expid}/${version}/*_r${real}i1p1f1_*${year1}*-*${year2}*.nc |\
    awk -F"/" '{print $NF}'|cut -d"_" -f1-5 >/tmp/var_${year1}-${year2}.txt.$$
ls ${cmorout}/${model}/${expid}/${version}/*_r${real}i1p1f1_*${ryear1}*-*${ryear2}*.nc |\
    awk -F"/" '{print $NF}'|cut -d"_" -f1-5 >/tmp/var_${ryear1}-${ryear2}.txt.$$
comm -3 /tmp/var_${year1}-${year2}.txt.$$ /tmp/var_${ryear1}-${ryear2}.txt.$$ >/tmp/var_${year1}-${year2}_diff.txt.$$

cp ${pnml}/var.nml ${pnml}/vartmp.nml
sed -i "/^! * '/d" ${pnml}/vartmp.nml
sed -i "/^! *not/d" ${pnml}/vartmp.nml
sed -i "s/^                 '/!                '/g" ${pnml}/vartmp.nml

while read -r fname
do
 vname=$(echo ${fname} |cut -d"_" -f1) 
 #echo ${vname}
 sed -i "s/!                '${vname} /                 '${vname} /g" ${pnml}/vartmp.nml
 sed -i "s/!                '${vname}'/                 '${vname}'/g" ${pnml}/vartmp.nml
done </tmp/var_${year1}-${year2}_diff.txt.$$
mv ${pnml}/vartmp.nml ${pnml}/var_${year1}-${year2}r${real}.nml

rm -f ${pnml}/vartmp.nml
rm -f  /tmp/var_${year1}-${year2}.txt.$$ \
       /tmp/var_${ryear1}-${ryear2}.txt.$$
#rm -f  /tmp/var_${year1}-${year2}_diff.txt.$$

echo "Picked variable list in:"
echo "${pnml}/var_${year1}-${year2}r${real}.nml"
