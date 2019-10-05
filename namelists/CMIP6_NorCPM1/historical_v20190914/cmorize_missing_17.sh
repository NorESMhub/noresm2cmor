#!/bin/sh -e

MEM1=17
MEMN=17
VNAM=hfsifrazil
PERIODS='2019-2030' 
NMLDIR=`dirname \`readlink -f $0\``
PREFIX=`basename $NMLDIR` 
RUNDIR=$NMLDIR/../../../bin

cd $RUNDIR
for MEM in `seq -w $MEM1 $MEMN`
do 
  for PERIOD in `echo $PERIODS`
  do 
    YEAR1=`echo $PERIOD | cut -d"-" -f1` 
    YEARN=`echo $PERIOD | cut -d"-" -f2` 
    LOGFILE=log_${PREFIX}_${MEM}_${PERIOD}.txt
    CASEPREFIX=`basename \`cat $NMLDIR/exp.nml | grep casename | cut -d"'" -f2\` 01`
    sed -e "s/${CASEPREFIX}01/${CASEPREFIX}$MEM/" -e "s/year1         = .*/year1         = ${YEAR1},/" -e "s/yearn         = .*/yearn         = ${YEARN},/" -e "s/realization   = 1,/realization   = ${MEM},/" $NMLDIR/exp.nml > exp_${PREFIX}.nml 
    ./noresm2cmor3 $NMLDIR/sys.nml $NMLDIR/mod.nml exp_${PREFIX}.nml $NMLDIR/var_ice.nml $VNAM 
  done
done
