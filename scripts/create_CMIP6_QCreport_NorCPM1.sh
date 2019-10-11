#!/bin/sh 

if [ ! $1 ] || ( [ ! -d $1 ] && [ ! "$1" == "--all-skip-existing" ] && [ ! "$1" == "--all-replace-existing" ] )
then 
  echo "Usage: $0 <path to folder with netcdf files>" 
  echo "                  or " 
  echo "       $0 --all-skip-existing" 
  echo "                  or " 
  echo "       $0 --all-replace-existing" 
  exit
fi 

export PATH=/opt/anaconda3/bin:${PATH}
source activate /projects/NS9560K/cmor/PrePARE
export CMIP6_CMOR_TABLES=/projects/NS9560K/cmor/noresm2cmor/tables

if [ -d $1 ] 
then 
  cd `dirname $1` 
  for RIP in `ls $1 | cut -d_ -f5 | sort -u` 
  do 
    REPORT=`dirname $1`/`basename $1`.QCreport_$RIP
    if [ -e $REPORT ] ; then continue ; fi
    echo "Writing QC report to $REPORT" 
    PrePARE --max-processes 14 --include-file "${RIP}" $1 > $REPORT
  done 
elif [ "$1" == "--all-skip-existing" ] || [ "$1" == "--all-replace-existing" ]
then
  BASEDIR=/projects/NS9034K/CMIP6/.cmorout
  for MOD in `ls $BASEDIR`
  do 
    if [ ! -d $BASEDIR/$MOD ] ; then continue ; fi 
    for EXP in `ls $BASEDIR/$MOD`
    do 
      if [ ! -d $BASEDIR/$MOD/$EXP ] ; then continue ; fi
      for VER in `ls $BASEDIR/$MOD/$EXP`
      do 
        if [ ! "`echo $VER | head -1c`" == "v" ] || [ ! -d $BASEDIR/$MOD/$EXP/$VER ] ; then continue ; fi
        REPORT=$BASEDIR/$MOD/$EXP/${VER}.QCreport 
        if [ -e $REPORT ] && [ "$1" == "--all-skip-existing" ] ; then continue ; fi 
        echo "Writing QC report to $REPORT"
        PrePARE $BASEDIR/$MOD/$EXP/${VER} > $REPORT 
      done 
    done
  done 
fi
echo COMPLETE 
