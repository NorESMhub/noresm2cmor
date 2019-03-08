#!/bin/bash
set -e

# yanchun.he@nersc.no, 20190307

if [ $# -lt 1 ] || [ $1 == "--help" ]
then
    printf "Usage:\t./match_expvars.sh [FULL_PATH/]CASE_NAME\n"
    printf "\tFULL_PATH to the CASE is optional;\n"
    printf "\tIf not provide, will use current path, or /projects/NS2345K/noresm/cases,...\n"
    printf "\tor /projects/NS2345K/.snapshots/Tuesday-15-Jan-2019/noresm/cases/\n"
    exit 1
fi

pid=$$
expid=$1
if [ -d $expid ]
then
    casepath=$expid
elif [ -d ./$expid ]
then
    casepath=./$expid
elif [ -d /projects/NS2345K/noresm/cases/$expid ]
then
    casepath=/projects/NS2345K/noresm/cases/$expid
elif [ -d /projects/NS2345K/.snapshots/Tuesday-15-Jan-2019/noresm/cases/$expid ]
then
    casepath=/projects/NS2345K/.snapshots/Tuesday-15-Jan-2019/noresm/cases/$expid
else
    echo "CAN NOT FIND $expid !!!"
    echo "EIXT..."
    exit 1
fi

# Dump all variable names of model ouput
echo "GET VARIABLE LIST OF MODEL OUTPUT ..."
if [ ! -d /tmp/$USER ]; then mkdir -p /tmp/$USER; fi
find ${casepath}/*/hist/ -type f  -name '*.nc' -print | \
    awk -F/ '{print $NF }' |cut -d"." -f2,3 |sort -u |command grep -v 'cpl.' >/tmp/$USER/ftaglist.txt
while read -r ftag
do
    sample_file=$(find ${casepath}/*/hist/ -type f  -name "*${ftag}*.nc" -print -quit)
    ExpVARs+=($(cdo -s showname ${sample_file} 2>/dev/null))
done </tmp/$USER/ftaglist.txt
# echo ${ExpVARs[*]} >/tmp/$USER/ExpVARs.txt

# Remove duplicated variables
ExpVARs=($(echo ${ExpVARs[*]} | sed 's/ /\n/g' |sort -u ))

echo "DOWNLOAD GOOGLE SHEET AND EXTRACT DATA IN COLUMN E ..."
# Download CMIP6 google sheet
wget -q 'https://docs.google.com/spreadsheets/d/e/2PACX-1vTjTYfkkjySo2KHEtbeWD0dBavZFS_joYaLPyscN8LvpGzNojrKHxaKf7WcpNZi8oVQhLlwTNHjy4xi/pub?gid=251590531&single=true&output=tsv' -O /tmp/$USER/CMIP6_data_request_v1.00.30beta1.tsv
printf "\n" >>/tmp/$USER/CMIP6_data_request_v1.00.30beta1.tsv

# Extract "NorESMvars" (column E)
rm -f /tmp/$USER/NorESMvars.txt
k=0
while read -r ENTRY
do
    NorESMvars0[k]=$(echo "$ENTRY" |cut -f5)
    NorESMvars[k]=$(echo "${NorESMvars0[k]}"  |sed 's/[^a-zA-Z0-9_]/ /g' |sed 's/\s[0-9]\+/ /g' | \
        sed 's/^n a//' |sed 's/ integrated//' | sed 's/ derived//')
    #echo ${NorESMvars[k]} >>/tmp/$USER/NorESMvars.txt
    let k=$k+1
done </tmp/$USER/CMIP6_data_request_v1.00.30beta1.tsv

echo "GENERATE A NEW VARIABLE LIST OF THE EXPERIMENT UNDER TEST ..."
rm -f ./ExpVARs.tsv
FLAG=FALSE
for (( k = 1; k < ${#NorESMvars[*]}; k++ )); do
    VARs=(${NorESMvars[k]})
    if [ ! -z $VARs ]; then FLAG=TRUE; fi
    for (( i = 0; i < ${#VARs[*]}; i++ )); do
        if [[ ${ExpVARs[*]} == ${ExpVARs[*]//${VARs[i]}/} ]]
        then
            FLAG=FALSE
        fi
    done
    printf "$FLAG\t${NorESMvars0[k]}\n" >>./ExpVARs.tsv
    FLAG=FALSE
done
echo "----------------------------------------------------------------"
echo "SUCCESSFULLY GENERATE A TAB-SEPERATED VARLIST FILE ./ExpVARs.tsv"
echo "YOU CAN IMPORT THE FILE TO EXCEL/NUMBERS AND DOUBLE CHECK."
echo "AND FINALLY APPEND THE FIRST COLUMN TO THE END OF GOOGLE SHEET"
echo "----------------------------------------------------------------"
