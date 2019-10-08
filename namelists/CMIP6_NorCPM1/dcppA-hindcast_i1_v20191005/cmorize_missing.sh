#!/bin/sh -e

NMEM=10
NINS=15 
SYEARS="`seq $1 $2`"
NMLDIR=`dirname \`readlink -f $0\``
PREFIX=`basename $NMLDIR` 
RUNDIR=$NMLDIR/../../../bin

while [ `ps -u $USER | grep cmorize_missing | wc -l` -gt 1 ] 
do 
  sleep 60 
done

cd $RUNDIR
INS=1
for SYEAR in $SYEARS
do 
  for MEM in `seq -w 01 $NMEM`
  do 
    YEAR1=`echo $PERIOD | cut -d"-" -f1` 
    YEARN=`echo $PERIOD | cut -d"-" -f2` 
    LOGFILE=log_${PREFIX}_${MEM}_${SYEAR}.txt
    $NMLDIR/exp.sh $SYEAR $MEM > exp_${PREFIX}_${MEM}.nml
    ./noresm2cmor3 $NMLDIR/sys.nml $NMLDIR/mod.nml exp_${PREFIX}_${MEM}.nml $NMLDIR/var_missing.nml >& $LOGFILE & 
    if [ $INS -eq 15 ] 
    then 
      INS=1
      wait 
    else 
      INS=`expr $INS + 1`
    fi 
  done
done
wait 
