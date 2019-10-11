#!/bin/sh -e

NINS=15 
NMLDIR=`dirname \`readlink -f $0\``
PREFIX=`basename $NMLDIR` 
RUNDIR=$NMLDIR/../../../bin

cd $RUNDIR
INS=1
for ITEM in `cat $NMLDIR/missing2.in | sort -u`
do 
  SYEAR=`echo $ITEM | cut -ds -f2 | cut -d- -f1` 
  MEM=`echo 0\`echo $ITEM | cut -dr -f2 | cut -di -f1\` | tail -3c`
  echo $SYEAR $MEM 
  YEAR1=`echo $PERIOD | cut -d"-" -f1` 
  YEARN=`echo $PERIOD | cut -d"-" -f2` 
  LOGFILE=log_${PREFIX}_${MEM}_${SYEAR}.txt
  $NMLDIR/exp.sh $SYEAR $MEM > exp_${PREFIX}_${SYEAR}_${MEM}.nml
 ./noresm2cmor3 $NMLDIR/sys.nml $NMLDIR/mod.nml exp_${PREFIX}_${SYEAR}_${MEM}.nml $NMLDIR/var_missing.nml >& $LOGFILE & 
  if [ $INS -eq 15 ] 
  then 
    INS=1
    wait 
  else 
    INS=`expr $INS + 1`
  fi 
done
wait 
