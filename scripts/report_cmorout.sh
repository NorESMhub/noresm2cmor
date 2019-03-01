#!/bin/sh 

CMOROUT=/scratch/$USER/cmorout
cd $CMOROUT

rm -f ~/noresm2cmor/tmp/cmorized_vars.txt
for FNAME in $(ls *nc)
do 
    echo $FNAME
    TABLE=$(ncdump -h $FNAME |grep 'table_id' |cut -d'"' -f2)
    FREQUENCY=$(ncdump -h $FNAME |grep 'frequency' |cut -d'"' -f2)
    REALM=$(ncdump -h $FNAME |grep 'realm' |cut -d'"' -f2)
    CMIPname=$(echo $FNAME | cut -d_ -f1 | sort -u)
    NorESMname=$(ncdump -h $FNAME | grep original_name | cut -d'"' -f2)
    echo -e "$TABLE\t$FREQUENCY\t$REALM\t$CMIPname\t$NorESMname" >>  ~/noresm2cmor/tmp/cmorized_vars_piControl_v1_unsort.txt
    #echo -e "$TABLE\t$FREQUENCY\t$REALM\t$CMIPname" >>  ~/noresm2cmor/tmp/cmorized_vars_piControl_v1_unsort.txt
done 
cat  ~/noresm2cmor/tmp/cmorized_vars_piControl_v1_unsort.txt |sort -u -k1,1 -k2,2 -k3,3 -k4,4 >  ~/noresm2cmor/tmp/cmorized_vars_piControl_v2_sort.txt
#rm -f  ~/noresm2cmor/tmp/cmorized_vars_piControl_v1_unsort.txt


#--------------------------------------------#
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

