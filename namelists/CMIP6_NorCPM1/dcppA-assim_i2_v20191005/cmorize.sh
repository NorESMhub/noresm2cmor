#!/bin/sh -e

NMEM=30
NINS=10
NMLDIR=`dirname \`readlink -f $0\``
PREFIX=`basename $NMLDIR` 
RUNDIR=$NMLDIR/../../../bin

export I_MPI_WAIT_MODE=1

cd $RUNDIR
for MEM in `seq -w 01 $NMEM`
do 
  LOGFILE=log_${PREFIX}_${MEM}.txt
  CASEPREFIX=`basename \`cat $NMLDIR/exp.nml | grep casename | cut -d"'" -f2\` 01`
  sed -e "s/${CASEPREFIX}01/${CASEPREFIX}$MEM/" -e "s/realization   = 1,/realization   = ${MEM},/" $NMLDIR/exp.nml > exp_${PREFIX}.nml 
  mpirun -n $NINS ./noresm2cmor3_mpi $NMLDIR/sys.nml $NMLDIR/mod.nml exp_${PREFIX}.nml $NMLDIR/var.nml >& $LOGFILE
done
