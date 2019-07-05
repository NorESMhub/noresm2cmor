#!/bin/bash
#set -x

# yanchun.he@nersc.no, 20190307

if [ $# -lt 1 ] || [ $1 == "--help" ]
then
    printf "Usage:\t./report_modelout.sh [FULL_PATH/]CASE_NAME\n"
    printf "\tFULL_PATH to the CASE is optional;\n"
    printf "\tIf not provide, will use current path, or /projects/NS2345Ktmp/noresm/cases,...\n"
    printf "\tor /projects/NS2345K/.snapshots/Tuesday-15-Jan-2019/noresm/cases/\n"
    exit 1
fi

#datetag=20190531
#datetag=20190703
datetag=20190704
noresm2cmorpath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
if [ $(command -v cdo) ]
then
    CDO=$(which cdo)
else
    if [ -x /opt/cdo197/bin/cdo ]
    then
        CDO=/opt/cdo197/bin/cdo
    fi
fi
if [ $(command -v ncdump) ]
then
    NCDUMP=$(which ncdump)
else
    if [ -x /opt/netcdf-4.6.1-intel/bin/ncdump ]
    then
        NCDUMP=/opt/netcdf-4.6.1-intel/bin/ncdump
    fi
fi
if [ -z $CDO ] && [ -z $NCDUMP ]
then
    echo "ERROR: neither cdo nor ncdump not found, EXIT..."
    exit 1
fi
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
elif [ -d /projects/NS2345Ktmp/FRAM/noresm/cases/$expid ]
then
    casepath=/projects/NS2345Ktmp/FRAM/noresm/cases/$expid
elif [ -d /projects/NS2345K/.snapshots/Tuesday-15-Jan-2019/noresm/cases/$expid ]
then
    casepath=/projects/NS2345K/.snapshots/Tuesday-15-Jan-2019/noresm/cases/$expid
else
    echo "CAN NOT FIND $expid !!!"
    echo "EIXT..."
    exit 1
fi
expid=$(basename $casepath)


# Create temperary folder if not exists
if [ ! -d /tmp/$USER ]; then mkdir -p /tmp/$USER; fi
if [ ! -d ${noresm2cmor}/tmp ]; then mkdir -p ${noresm2cmor}/tmp; fi

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "  Download CMIP6 data request sheet" 
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
if [ -f ${noresm2cmorpath}/tmp/CMIP6_data_request_v1.00.30beta1.v${datetag}.tsv ]
then
    ln -sf ${noresm2cmorpath}/tmp/CMIP6_data_request_v1.00.30beta1.v${datetag}.tsv ${noresm2cmorpath}/tmp/CMIP6_data_request_v1.00.30beta1.tsv
else
    wget -q 'https://docs.google.com/spreadsheets/d/e/2PACX-1vTjTYfkkjySo2KHEtbeWD0dBavZFS_joYaLPyscN8LvpGzNojrKHxaKf7WcpNZi8oVQhLlwTNHjy4xi/pub?gid=251590531&single=true&output=tsv' -O ${noresm2cmorpath}/tmp/CMIP6_data_request_v1.00.30beta1.tsv
    printf "\n" >>${noresm2cmorpath}/tmp/CMIP6_data_request_v1.00.30beta1.tsv
    # use cat to avoid getting exit status as 1
    count=$(head -5 ${noresm2cmorpath}/tmp/CMIP6_data_request_v1.00.30beta1.tsv |grep -c 'DOCTYPE html' |cat )
    if [ $count -eq 0  ]
    then
        sed -i '1d' ${noresm2cmorpath}/tmp/CMIP6_data_request_v1.00.30beta1.tsv
        mv ${noresm2cmorpath}/tmp/CMIP6_data_request_v1.00.30beta1.tsv ${noresm2cmorpath}/tmp/CMIP6_data_request_v1.00.30beta1.v$(date +%Y%m%d).tsv
        ln -sf ${noresm2cmorpath}/tmp/CMIP6_data_request_v1.00.30beta1.v$(date +%Y%m%d).tsv ${noresm2cmorpath}/tmp/CMIP6_data_request_v1.00.30beta1.tsv
    else
        echo 'WRONG CMIP6 DATA REQUEST SHEET, SHOULD REPULBISH THE FILE "FILE->Publish to web"'
        exit 1
    fi
fi

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "  Download file tag information for different tables,freqency and realm"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
if [ -f ${noresm2cmorpath}/tmp/FileTag.v${datetag}.tsv ]; then
    ln -sf ${noresm2cmorpath}/tmp/FileTag.v${datetag}.tsv ${noresm2cmorpath}/tmp/FileTag.tsv
else
    cat /dev/null > ${noresm2cmorpath}/tmp/FileTag.tsv
    wget -q 'https://docs.google.com/spreadsheets/d/e/2PACX-1vTjTYfkkjySo2KHEtbeWD0dBavZFS_joYaLPyscN8LvpGzNojrKHxaKf7WcpNZi8oVQhLlwTNHjy4xi/pub?gid=812322378&single=true&output=tsv' -O ${noresm2cmorpath}/tmp/FileTag.tsv
    printf "\n" >> ${noresm2cmorpath}/tmp/FileTag.tsv
    count=$(head -5 ${noresm2cmorpath}/tmp/FileTag.tsv |grep -c 'DOCTYPE html' |cat )
    if [ $count -eq 0  ]
    then
        sed -i '1d' ${noresm2cmorpath}/tmp/FileTag.tsv
        mv ${noresm2cmorpath}/tmp/FileTag.tsv ${noresm2cmorpath}/tmp/FileTag.v$(date +%Y%m%d).tsv
        ln -sf ${noresm2cmorpath}/tmp/FileTag.v$(date +%Y%m%d).tsv ${noresm2cmorpath}/tmp/FileTag.tsv
    else
        echo 'WRONG FileTag GOOGLE SHEET, SHOULD REPULBISH THE FILE "FILE->Publish to web"'
        exit 1
    fi
fi
#
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "  Find Variables in model output"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

cat /dev/null >/tmp/$USER/FileTag2.tsv
while read -r Entry
do
    #printf "$(echo $Entry |tr -d [[:cntrl:]])\n"
    Table1=$( echo -n "${Entry}"  |cut -f1 | tr -d [[:cntrl:]] )
    Freq1=$(  echo -n "${Entry}"  |cut -f2 | tr -d [[:cntrl:]] )
    Realm1=$( echo -n "${Entry}"  |cut -f3 | tr -d [[:cntrl:]] )
    FileTag=$(echo -n "${Entry}"  |cut -f4 | tr -d [[:cntrl:]] )
    if [ $FileTag != "-" ]
    then
        sample_file=$(find ${casepath}/*/hist/ -name "*.${FileTag}.*.nc" -print -quit)
        if [ ! -z $sample_file ]
        then
            #echo $FileTag
            command $CDO -V &>/dev/null
            if [ $? -eq 0 ]
            then
                VARs=($($CDO -s showname ${sample_file} 2>/dev/null))
            else
                VARs=($($NCDUMP -h ${sample_file} |grep '('|grep -e 'double\|float\|short' |cut -d" " -f2 |cut -d"(" -f1))
            fi
            VARs=($(echo ${VARs[*]} | sed 's/ /\n/g' |sort -u ))
            #echo ${VARs[*]}
            #sleep 1
        else
            VARs=()
        fi
    else
        VARs=()
    fi
    printf "%s\t%s\t%s\t%s\t" $Table1 $Freq1 $Realm1 $FileTag >>/tmp/$USER/FileTag2.tsv
    printf "%s " ${VARs[*]} >>/tmp/$USER/FileTag2.tsv
    printf "\n" >>/tmp/$USER/FileTag2.tsv
done <${noresm2cmorpath}/tmp/FileTag.tsv

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "  Get model output vars for each row of google sheet"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

cat /dev/null >/tmp/$USER/ExpVARs.txt
k=1
while read -r dreqEntry
do
    echo $k
    Table2=$(echo      "$dreqEntry" |cut -f1)
    Freq2=$(echo       "$dreqEntry" |cut -f2)
    Realm2=$(echo      "$dreqEntry" |cut -f3)
    CMIPname=$(echo    "$dreqEntry" |cut -f4)
    NorESMnames=$(echo  "$dreqEntry" |cut -f5)
    NorESMnames=$(echo  "$NorESMnames"  | \
        sed 's/.e-//g'    | sed 's/[^a-zA-Z0-9_]/ /g' | sed 's/\s[0-9]*/ /g' |\
        sed 's/^n a//g'   | sed 's/ integrated//g'    | sed 's/ derived//g'  |\
        sed 's/ planned//g'| sed 's/ sjekk//g'         |sed 's/\s */ /g'      |\
        sed 's/ where//g'  | sed 's/ from//g' |\
        sed 's/ /\n/g'    | sort -u)
    ModelVARs=$(grep -n "^$(printf "%s\t%s\t%s\t" ${Table2} ${Freq2} ${Realm2})" /tmp/$USER/FileTag2.tsv | cut -f5 )
    if [ ! -z "${ModelVARs// /}" ]
    then
        ExpVARs=()
        for NorName in $(echo $NorESMnames)
            do
            if [ ! -z "$(echo $ModelVARs | grep -w "$NorName")" ]
            then
                ExpVARs+=($NorName)
            fi
        done
        if [ ! -z "$ExpVARs" ]
        then
            ExpVARs2=$(echo ${ExpVARs[*]} | sed 's/ /,/g')
            printf "%s\t%s\t%s\t" ${Table2} ${Freq2} ${Realm2} >>/tmp/$USER/ExpVARs.txt
            printf "%s" $ExpVARs2 >>/tmp/$USER/ExpVARs.txt
        fi
    fi
    printf "\n" >>/tmp/$USER/ExpVARs.txt
    let k=$k+1
done <${noresm2cmorpath}/tmp/CMIP6_data_request_v1.00.30beta1.tsv
cp /tmp/$USER/ExpVARs.txt /tmp/$USER/ExpVARs2.txt
sed -i '/^$/d' /tmp/$USER/ExpVARs2.txt
cat /tmp/$USER/ExpVARs.txt |cut -f4 > ${noresm2cmorpath}/tmp/${expid}_UsedVars.txt

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "  Get model output unused vars for file tag"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
Files=()
#get filetags
FileTags=$(cat /tmp/$USER/FileTag2.tsv | cut -f4 |sort -u |command grep -v '-')
for Tag in $(echo $FileTags)
    do
    FileVars=$(cat /tmp/$USER/FileTag2.tsv |grep -m 1 $Tag |cut -f5)
    if [ ! -z ${FileVars// /} ]
    then
        UsedVars=()
        echo ${Tag}
        # TFR: Table, Freq. and Realm
        cat /tmp/$USER/FileTag2.tsv | grep -w ${Tag} |cut -f1-3 >/tmp/$USER/TFR.tsv
        while read -r TFR
        do
            UsedVars+=($(cat /tmp/$USER/ExpVARs2.txt | grep -w "${TFR}" | cut -f4))
        done </tmp/$USER/TFR.tsv
        UsedVars=$(echo ${UsedVars[*]} |sed 's/,/ /g'| sed 's/ /\n/g' | sort -u )
        UnUsedVars=" ${FileVars} "  # add two space to accurately match patterns
        for UsedVar in $(echo $UsedVars)
        do
            UnUsedVars=${UnUsedVars//" ${UsedVar} "/ }
        done
        #echo $FileVars |wc -w
        #echo $UsedVars |wc -w
        #echo $UnUsedVars |wc -w
        #echo $FileVars |sed 's/ /\n/g'  |LC_ALL=C sort -u >FileVars.txt
        #echo $UsedVars |sed 's/ /\n/g'  |LC_ALL=C sort -u >UsedVars.txt
        #echo $UnUsedVars|sed 's/ /\n/g' |LC_ALL=C sort -u >UnUsedVars.txt

        # create a unused var list for each tag
        echo $Tag > /tmp/$USER/UnUsedVars.${Tag}.txt
        echo $UnUsedVars|sed 's/ /\n/g' |LC_ALL=C sort -u >> /tmp/$USER/UnUsedVars.${Tag}.txt
        Files+=(/tmp/$USER/UnUsedVars.${Tag}.txt)
    fi
done
# Paste all unused vars for differetn tag files together
paste ${Files[*]} > ${noresm2cmorpath}/tmp/${expid}_UnUsedVars.txt

echo "----------------------------------------------------------------"
echo "SUCCESSFULLY GENERATE A TAB-SEPERATED VARIABLE LIST FILES"
echo "1, ${noresm2cmorpath}/tmp/${expid}_UsedVars.txt FOR USED VARS FOR CMIP6"
echo "2, ${noresm2cmorpath}/tmp/${expid}_UnUsedVars.txt FOR UNUSED VARS FOR CMIP6"
echo "YOU CAN IMPORT THE FILE TO EXCEL/NUMBERS AND DOUBLE CHECK."
echo "AND FINALLY APPEND THE FIRST COLUMN TO THE END OF GOOGLE SHEET"
echo "----------------------------------------------------------------"
