#!/bin/sh 

CMOROUT=/scratch/$USER/cmorout
cd $CMOROUT

for TABLE in `ls *nc | cut -d_ -f2 | sort -u`
do 
  echo $TABLE 
  for FNAME in `ls *nc | grep "_${TABLE}_" `
  do 
    FLD=`echo $FNAME | cut -d_ -f1 | sort -u`  
    FLDORIG=`ncdump -h $FNAME | grep original_name | cut -d'"' -f2`
    echo " $FLD $FLDORIG" 
  done 
  echo 
done 
