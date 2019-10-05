#!/bin/sh -e

NINS=12
NMEM=10
#SYEARS="`seq 2006 2009`"
SYEARS="`seq 2007 2007`"
NMLDIR=`dirname \`readlink -f $0\``
PREFIX=`basename $NMLDIR` 
RUNDIR=$NMLDIR/../../../bin

export I_MPI_WAIT_MODE=1

cd $RUNDIR
for SYEAR in $SYEARS
do 
  for MEM in `seq -w 01 $NMEM`
  do 
    if [ ! $MEM -eq 07 ] 
    then 
      continue 
    fi 
    YEAR1=`echo $PERIOD | cut -d"-" -f1` 
    YEARN=`echo $PERIOD | cut -d"-" -f2` 
    LOGFILE=log_${PREFIX}_${MEM}_${SYEAR}.txt
    $NMLDIR/exp.sh $SYEAR $MEM > exp_${PREFIX}_${YEAR1}-${YEARN}.nml
    mpirun -n $NINS ./noresm2cmor3_mpi $NMLDIR/sys.nml $NMLDIR/mod.nml exp_${PREFIX}_${YEAR1}-${YEARN}.nml $NMLDIR/var.nml >& $LOGFILE
  done
done
