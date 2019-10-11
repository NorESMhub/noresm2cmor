#!/bin/sh -e

NINS=10
NMLDIR=`dirname \`readlink -f $0\``
PREFIX=`basename $NMLDIR` 
RUNDIR=$NMLDIR/../../../bin

#while [ `ps -u $USER | grep cmorize | wc -l` -gt 1 ] 
#do 
#  sleep 60 
#done

cd $RUNDIR
INS=1
for MEM in `seq -w $1 $2`
do 
  LOGFILE=log_${PREFIX}_${MEM}.txt
  CASEPREFIX=`basename \`cat $NMLDIR/exp.nml | grep casename | cut -d"'" -f2\` 01`
  sed -e "s/${CASEPREFIX}01/${CASEPREFIX}$MEM/" -e "s/realization   = 1,/realization   = ${MEM},/" $NMLDIR/exp.nml > exp_${PREFIX}_${MEM}.nml 
  ./noresm2cmor3 $NMLDIR/sys.nml $NMLDIR/mod.nml exp_${PREFIX}_${MEM}.nml $NMLDIR/var_daily2.nml >& $LOGFILE & 
  if [ $INS -eq 15 ] 
  then 
    INS=1
    wait 
  else 
    INS=`expr $INS + 1`
  fi 
done
wait
