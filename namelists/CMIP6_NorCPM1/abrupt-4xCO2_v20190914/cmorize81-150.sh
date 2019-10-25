#!/bin/sh -e

NINS=4
NMLDIR=`dirname \`readlink -f $0\``
PREFIX=`basename $NMLDIR` 
RUNDIR=$NMLDIR/../../../bin

export I_MPI_WAIT_MODE=1

cd $RUNDIR
mpirun -n $NINS ./noresm2cmor3_mpi $NMLDIR/sys.nml $NMLDIR/mod.nml  $NMLDIR/exp81-150.nml $NMLDIR/var.nml 
echo COMPLETE
