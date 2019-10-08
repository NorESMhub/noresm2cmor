#!/bin/sh -e

MEM1=$1
MEMN=$2
PERIODS='1950-2014 2015-2018 2019-2030' 
NMLDIR=`dirname \`readlink -f $0\``
PREFIX=`basename $NMLDIR` 
RUNDIR=$NMLDIR/../../../bin


cd $RUNDIR
for PERIOD in `echo $PERIODS`
do 
  for MEM in `seq -w $MEM1 $MEMN`
  do 
    YEAR1=`echo $PERIOD | cut -d"-" -f1` 
    YEARN=`echo $PERIOD | cut -d"-" -f2` 
    LOGFILE=log_${PREFIX}_${MEM}_${PERIOD}.txt
    CASEPREFIX=`basename \`cat $NMLDIR/exp.nml | grep casename | cut -d"'" -f2\` 01`
    sed -e "s/${CASEPREFIX}01/${CASEPREFIX}$MEM/" -e "s/year1         = .*/year1         = ${YEAR1},/" -e "s/yearn         = .*/yearn         = ${YEARN},/" -e "s/realization   = 1,/realization   = ${MEM},/" $NMLDIR/exp.nml > exp_${PREFIX}_${MEM}.nml 
    ./noresm2cmor3 $NMLDIR/sys.nml $NMLDIR/mod.nml exp_${PREFIX}_${MEM}.nml $NMLDIR/var.nml >& $LOGFILE & 
  done
  wait 
done
