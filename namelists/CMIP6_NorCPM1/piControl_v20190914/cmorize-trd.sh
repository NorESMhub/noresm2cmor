#!/bin/sh -e

NMEM=1
NINS=1
PERIODS='0001-0001' 
NMLDIR=`dirname \`readlink -f $0\``
PREFIX=`basename $NMLDIR` 
RUNDIR=$NMLDIR/../../../bin

export I_MPI_WAIT_MODE=1

cd $RUNDIR
for MEM in `seq -w 01 $NMEM`
do 
  for PERIOD in `echo $PERIODS`
  do 
    YEAR1=`echo $PERIOD | cut -d"-" -f1` 
    YEARN=`echo $PERIOD | cut -d"-" -f2` 
    LOGFILE=log_${PREFIX}_${MEM}_${PERIOD}.txt
    CASEPREFIX=`basename \`cat $NMLDIR/exp.nml | grep casename | cut -d"'" -f2\` 01`
    sed -e "s/${CASEPREFIX}01/${CASEPREFIX}$MEM/" -e "s/year1         = .*/year1         = ${YEAR1},/" -e "s/yearn         = .*/yearn         = ${YEARN},/" -e "s/realization   = 1,/realization   = ${MEM},/" $NMLDIR/exp.nml > exp_${PREFIX}.nml 
     ./noresm2cmor3 $NMLDIR/sys-trd.nml $NMLDIR/mod.nml exp_${PREFIX}.nml $NMLDIR/var.nml 
  done
done
