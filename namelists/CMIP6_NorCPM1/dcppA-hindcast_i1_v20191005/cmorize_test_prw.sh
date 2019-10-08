#!/bin/sh -e

NINS=1
NMEM=1
SYEARS="`seq 1960 1960`"
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
    ./noresm2cmor3 $NMLDIR/sys.nml $NMLDIR/mod.nml $NMLDIR/exp_test.nml $NMLDIR/var_prw.nml 
  done
done
