#!/bin/sh -e

NENS=3
PREFIX=exp_CMIP6_NorCPM1_piControl

for ENS1 in `ls ${PREFIX}_01_*.nml`
do 
  for MEM in `seq -w 02 $NENS`
  do  
    ENS=`echo $ENS1 | sed "s/${PREFIX}_01/${PREFIX}_$MEM/"`
    CASEPREFIX=`basename \`cat $ENS1 | grep casename | cut -d"'" -f2\` 01`
    sed -e "s/${CASEPREFIX}01/${CASEPREFIX}$MEM/" -e "s/realization   = 1,/realization   = ${MEM},/" $ENS1 > $ENS
  done 
done 

