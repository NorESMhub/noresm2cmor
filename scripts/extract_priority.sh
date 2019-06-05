#!/bin/bash
set -e

# yanchun.he@nersc.no, 20190513

# make tmp dir
if [ ! -d /tmp/$USER ]; then mkdir -p /tmp/$USER; fi
if [ ! -d ../tmp ]; then mkdir -p ../tmp; fi

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "      Download CMIP6 data request sheet"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
datetag=20190531
if [ -f ../tmp/CMIP6_data_request_v1.00.30beta1.v${datetag}.tsv ]
then
    ln -sf ../tmp/CMIP6_data_request_v1.00.30beta1.v${datetag}.tsv ../tmp/CMIP6_data_request_v1.00.30beta1.tsv
else
    wget -q 'https://docs.google.com/spreadsheets/d/e/2PACX-1vTjTYfkkjySo2KHEtbeWD0dBavZFS_joYaLPyscN8LvpGzNojrKHxaKf7WcpNZi8oVQhLlwTNHjy4xi/pub?gid=251590531&single=true&output=tsv' -O ../tmp/CMIP6_data_request_v1.00.30beta1.tsv
    printf "\n" >>../tmp/CMIP6_data_request_v1.00.30beta1.tsv
    # use cat to avoid getting exit status as 1
    count=$(head -5 ../tmp/CMIP6_data_request_v1.00.30beta1.tsv |grep -c 'DOCTYPE html' |cat )
    if [ $count -eq 0  ]
    then
        sed -i '1d' ../tmp/CMIP6_data_request_v1.00.30beta1.tsv
        mv ../tmp/CMIP6_data_request_v1.00.30beta1.tsv ../tmp/CMIP6_data_request_v1.00.30beta1.v$(date +%Y%m%d).tsv
        ln -sf ../tmp/CMIP6_data_request_v1.00.30beta1.v$(date +%Y%m%d).tsv ../tmp/CMIP6_data_request_v1.00.30beta1.tsv
    else
        echo 'WRONG CMIP6 DATA REQUEST SHEET, SHOULD REPULBISH THE FILE "FILE->Publish to web"'
        exit 1
    fi
fi

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "      Check if the correct column"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
# set column numbers
idxCMIPname=4
idxMIPs1=13
idxMIPs2=35
# check if the right column number
tmp=$(head -1 ../tmp/CMIP6_data_request_v1.00.30beta1.tsv | cut -f$idxCMIPname |tr -d [:space:])
echo COLUMN $idxCMIPname IS: $tmp
if [ "$tmp" != "CMIPname" ]
then
    echo COLUMN $idxCMIPname $tmp IS NOT THE RIGHT COLUMN FOR '"CMIP name"'
    echo "EXIT ..."
    exit 1
fi
tmp=$(head -1 ../tmp/CMIP6_data_request_v1.00.30beta1.tsv | cut -f$idxMIPs1)
echo COLUMN $idxMIPs1 IS: $tmp
if [ "$tmp" != "CMIP" ]
then
    echo COLUMN $idxMIPs1 $tmp IS NOT THE RIGHT COLUMN FOR '"CMIP"'
    echo "EXIT ..."
    exit 1
fi
tmp=$(head -1 ../tmp/CMIP6_data_request_v1.00.30beta1.tsv | cut -f$idxMIPs2)
echo COLUMN $idxMIPs2 IS: $tmp
if [ "$tmp" != "VolMIP" ]
then
    echo COLUMN $idxMIPs2 $tmp IS NOT THE RIGHT COLUMN FOR '"VoMIP"'
    echo "EXIT ..."
    exit 1
fi

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "      Extract priority from the MIPs columns"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
# extract priority
cat /dev/null >./MIP_priority.tsv
k=0
while read -r ENTRY
do
    echo $k
    CMIPname=$(echo "$ENTRY" |cut -f$idxCMIPname)
    MIPs=$(echo "$ENTRY" |cut -f${idxMIPs1}-${idxMIPs2})
    if [ "${MIPs// 1 /}" != "${MIPs}" ]; then
        Ptag=1
    elif [ "${MIPs// 2 /}" != "${MIPs}" ]; then
        Ptag=2
    elif [ "${MIPs// 3 /}" != "${MIPs}" ]; then
        Ptag=3
    else
        Ptag=-
    fi
    printf "%s\t%s\t" "$Ptag" "${CMIPname}" >> ./MIP_priority.tsv

    for (( i = ${idxMIPs1}; i <= ${idxMIPs2}; i++ )); do
        MIP=$(echo "$ENTRY" |cut -f$i)
        if [ "${MIP// 1 /}" != "${MIP}" ]; then
            MIPnew=$(echo $MIP |sed 's/Y/1/1')
        elif [ "${MIP// 2 /}" != "${MIP}" ]; then
            MIPnew=$(echo $MIP |sed 's/Y/2/1')
        elif [ "${MIP// 3 /}" != "${MIP}" ]; then
            MIPnew=$(echo $MIP |sed 's/Y/3/1')
        else
            MIPnew=$(echo $MIP |sed 's/Y/?/1')
        fi
        printf "%s\t" "${MIPnew}" >> ./MIP_priority.tsv
    done
    printf "\n" >>./MIP_priority.tsv
    let k=$k+1
done <../tmp/CMIP6_data_request_v1.00.30beta1.tsv

