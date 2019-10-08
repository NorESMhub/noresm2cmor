#!/bin/sh -e

NMEM=10
SYEARS="`seq 1990 2018`"
NMLDIR=`dirname \`readlink -f $0\``
PREFIX=`basename $NMLDIR` 
RUNDIR=$NMLDIR/../../../bin

export I_MPI_WAIT_MODE=1

cd $RUNDIR
for SYEAR in $SYEARS
do 
  for MEM in `seq -w 01 $NMEM`
  do 
    YEAR1=`echo $PERIOD | cut -d"-" -f1` 
    YEARN=`echo $PERIOD | cut -d"-" -f2` 
    LOGFILE=log_${PREFIX}_${MEM}_${SYEAR}.txt
    $NMLDIR/exp.sh $SYEAR $MEM > exp_${PREFIX}_${MEM}.nml
    ./noresm2cmor3 $NMLDIR/sys.nml $NMLDIR/mod.nml exp_${PREFIX}_${MEM}.nml $NMLDIR/var.nml >& $LOGFILE & 
  done
  wait 
done
