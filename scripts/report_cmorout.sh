#!/bin/sh 
set -e

if [ $# -lt 1 ] || [ $1 == "--help" ]
then
    printf "Usage:\t./report_cmorout.sh [FULL_PATH/]CASE_NAME\n"
    printf "\tFULL_PATH to the CASE is optional;\n"
    printf "\tIf not provide, will use current path, or /scratch/$USER/cmorout/\n"
    exit 1
fi

#datetag=20190531
#datetag=20190703
#datetag=20190704
datetag=20190811
noresm2cmorpath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"

FullName=$1
DirName=$(dirname $1)
ExpID=$(basename $1)

if [ $(command -v cdo) ]
then
    CDO=$(which cdo)
else
    if [ -x /opt/cdo197/bin/cdo ]
    then
        CDO=/opt/cdo197/bin/cdo
    else
        echo "ERROR: no cdo found!"
        exit 1
    fi
fi

if [ -d $FullName ]
then
    CasePath=$FullName
elif [ -d ./$FullName ]
then
    CasePath=./$FullName
elif [ -d /scratch/$USER/cmorout/$FullName ]
then
    CasePath=/scratch/$USER/cmorout/$FullName
else
    echo "CAN NOT FIND $FullName !!!"
    echo "EIXT..."
    exit 1
fi

if [ ! -d /tmp/$USER ]; then mkdir -p /tmp/$USER; fi
if [ ! -d $noresm2cmorpath/tmp ]; then mkdir -p $noresm2cmorpath/tmp; fi

# method 1, extract info from file metadata
rm -f /tmp/$USER/cmorized_var_${ExpID}_v1.txt
for FNAME in $(find ${CasePath} -name "*.nc" -print)
do 
    echo $FNAME
#   Use ncdump, not accurate
    #TABLE=$(ncdump -h $FNAME |grep 'table_id' |cut -d'"' -f2)
    #FREQUENCY=$(ncdump -h $FNAME |grep 'frequency' |cut -d'"' -f2)
    #REALM=$(ncdump -h $FNAME |grep 'realm' |cut -d'"' -f2)
    #CMIPname=$(basename $FNAME | cut -d_ -f1 | sort -u)
    #NorESMname=$(ncdump -h $FNAME | grep original_name | cut -d'"' -f2)

#   Use cdo
    TABLE=$($CDO -s showattribute,table_id $FNAME | tail -1 | cut -d'"' -f2)
    FREQUENCY=$($CDO -s showattribute,frequency $FNAME | tail -1 | cut -d'"' -f2)
    REALM=$($CDO -s showattribute,realm $FNAME | tail -1 | cut -d'"' -f2)
    CMIPname=$($CDO -s showattribute,variable_id $FNAME | tail -1 | cut -d'"' -f2)
    CMIPname2=$(basename $FNAME | cut -d_ -f1 | sort -u)
    if [ "$CMIPname" != "$CMIPname2" ]
    then
        echo "ERROR: different CMIPname"
        echo "CMIPname (variable_id) : $CMIPname"
        echo "CMIPname (in file name): $CMIPname2"
        echo "EXIT..."
        exit 1
    fi
    #NorESMname=$($CDO -s showattribute,${CMIPname}@original_name $FNAME | tail -1 | cut -d'"' -f2)

    #echo -e "$TABLE\t$FREQUENCY\t$REALM\t$CMIPname\t$NorESMname" >> /tmp/$USER/cmorized_var_${ExpID}_v1.txt
    echo -e "$TABLE\t$FREQUENCY\t$REALM\t$CMIPname" >>/tmp/$USER/cmorized_var_${ExpID}_v1.txt
done 
# use LC_ALL to sort as C/posix standard using ASCII order
#cat  /tmp/$USER/cmorized_var_${ExpID}_v1.txt | LC_ALL=C sort -u -k1,1 -k2,2 -k3,3 -k4,4 -k5,5 >/tmp/$USER/cmorized_var_${ExpID}_v2.txt
cat  /tmp/$USER/cmorized_var_${ExpID}_v1.txt | LC_ALL=C sort -u -k1,1 -k2,2 -k3,3 -k4,4 >/tmp/$USER/cmorized_var_${ExpID}_v2.txt

# method 2, extract info from file names
#for TABLE in `ls *nc | cut -d_ -f2 | sort -u`
#do 
  #echo $TABLE 
  #for FNAME in `ls *nc | grep "_${TABLE}_" `
  #do 
    #FLD=`echo $FNAME | cut -d_ -f1 | sort -u`  
    #FLDORIG=`ncdump -h $FNAME | grep original_name | cut -d'"' -f2`
    #echo " $FLD $FLDORIG" 
  #done 
  #echo 
#done 

# Download CMIP6 google sheet
if [ -f $noresm2cmorpath/tmp/CMIP6_data_request_v1.00.30beta1.v${datetag}.tsv ]
then
        ln -sf $noresm2cmorpath/tmp/CMIP6_data_request_v1.00.30beta1.v${datetag}.tsv $noresm2cmorpath/tmp/CMIP6_data_request_v1.00.30beta1.tsv
else
        wget -q "https://docs.google.com/spreadsheets/d/e/2PACX-1vTjTYfkkjySo2KHEtbeWD0dBavZFS_joYaLPyscN8LvpGzNojrKHxaKf7WcpNZi8oVQhLlwTNHjy4xi/pub?gid=251590531&single=true&output=tsv" -O $noresm2cmorpath/tmp/CMIP6_data_request_v1.00.30beta1.tsv
    printf "\n" >>$noresm2cmorpath/tmp/CMIP6_data_request_v1.00.30beta1.tsv
    count=$(head -5 $noresm2cmorpath/tmp/CMIP6_data_request_v1.00.30beta1.tsv |grep -c 'DOCTYPE html' |cat )
    if [ $count -eq 0  ]
    then
        sed -i '1d' $noresm2cmorpath/tmp/CMIP6_data_request_v1.00.30beta1.tsv
        mv $noresm2cmorpath/tmp/CMIP6_data_request_v1.00.30beta1.tsv $noresm2cmorpath/tmp/CMIP6_data_request_v1.00.30beta1.v$(date +%Y%m%d).tsv
        ln -sf $noresm2cmorpath/tmp/CMIP6_data_request_v1.00.30beta1.v$(date +%Y%m%d).tsv $noresm2cmorpath/tmp/CMIP6_data_request_v1.00.30beta1.tsv
    else
        echo 'WRONG CMIP6 DATA REQUEST SHEET, SHOULD REPULBISH THE FILE "FILE->Publish to web"'
        exit 1
    fi
fi

rm -f $noresm2cmorpath/tmp/cmorized_var_${ExpID}_v3.txt
k=0
while read -r LINEcmip6
do
      LINEcmip6c1to4=$(echo "$LINEcmip6" |cut -f1-4)
      COUNT=$(grep -c -w "$LINEcmip6c1to4"  /tmp/$USER/cmorized_var_${ExpID}_v2.txt |cat)
      if [ $COUNT -eq 1  ]
      then
          echo "TRUE">>$noresm2cmorpath/tmp/cmorized_var_${ExpID}_v3.txt
      else
          echo "FALSE">>$noresm2cmorpath/tmp/cmorized_var_${ExpID}_v3.txt
      fi
done <$noresm2cmorpath/tmp/CMIP6_data_request_v1.00.30beta1.tsv
#sed -i '1d' $noresm2cmorpath/tmp/cmorized_var_${ExpID}_v3.txt
echo "----------------------------------------------------------------"
echo "SUCCESSFULLY GENERATE A TAB-SEPERATED VARIABLE LIST FILES"
echo "$noresm2cmorpath/tmp/cmorized_var_${ExpID}_v3.txt"
echo "YOU CAN IMPORT THE FILE TO EXCEL/NUMBERS AND DOUBLE CHECK."
echo "AND FINALLY APPEND THE FIRST COLUMN TO THE END OF GOOGLE SHEET"
echo "----------------------------------------------------------------"

