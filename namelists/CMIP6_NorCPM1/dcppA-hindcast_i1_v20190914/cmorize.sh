#!/bin/sh -e

NINS=12
NMEM=10
SYEARS="`seq 1960 2018`"
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
    LOGFILE=log_${PREFIX}_${MEM}_${PERIOD}.txt
    CASEPREFIX=`basename \`cat $NMLDIR/exp.nml | grep casename | cut -d"'" -f2\` 01`
    sed -e "s/${CASEPREFIX}01/${CASEPREFIX}$MEM/" -e "s/year1         = .*/year1         = ${YEAR1},/" -e "s/yearn         = .*/yearn         = ${YEARN},/" -e "s/realization   = 1,/realization   = ${MEM},/" $NMLDIR/exp.nml > exp_${PREFIX}.nml 
    mpirun -n $NINS ./noresm2cmor3_mpi $NMLDIR/sys.nml $NMLDIR/mod.nml exp_${PREFIX}.nml $NMLDIR/var.nml >& $LOGFILE
  done
done
