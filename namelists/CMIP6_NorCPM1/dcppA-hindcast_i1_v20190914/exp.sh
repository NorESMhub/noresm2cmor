#!/bin/sh -e 

SYR=$1 
MEM=$2

NMLDIR=`dirname \`readlink -f $0\``

# determine branch time
TIMEOLD=`cat $NMLDIR/exp.nml | grep branch_time_in_child | cut -d"=" -f2 | cut -d. -f1` 
TIMENEW=`expr $TIMEOLD + 365 \* \( $SYR - 1960 \)`. 
#echo $TIMENEW

# determine new case name 
MM=`echo 0$MEM | tail -3c`
CASEOLD=`cat $NMLDIR/exp.nml | grep casename | cut -d"'" -f2` 
CASENEW=`echo $CASEOLD | sed -e "s/_19601015/_${SYR}1015/" -e "s/_mem01/_mem${MM}/"`
#echo $CASENEW 

# determine file path 
PATHOLD=`cat $NMLDIR/exp.nml | grep isubdir | cut -d"'" -f2`
PATHNEW=`echo $PATHOLD | sed "s/_19601015/_${SYR}1015/"`
#echo $PATHNEW

# sub experiment 
SEXPOLD=`cat $NMLDIR/exp.nml | grep " sub_experiment" | cut -d"'" -f2`
SEXPNEW=`echo $SEXPOLD | sed "s/s1960/s${SYR}/"`
#echo $SEXPNEW

# parent rip and variant label 
R=`expr $MEM + 0`
PRIPOLD=`cat $NMLDIR/exp.nml | grep parent_experiment_rip | cut -d"'" -f2`
PRIPNEW=`echo $PRIPOLD | sed "s/r1/r${R}/"` 
#echo $PRIPNEW 
PVAROLD=`cat $NMLDIR/exp.nml | grep parent_variant_label | cut -d"'" -f2`
PVARNEW=`echo $PVAROLD | sed "s/r1/r${R}/"`
#echo $PVARNEW

sed \
 -e "s%casename      = .*%casename      = '${CASENEW}',%" \
 -e "s%isubdir       = .*%isubdir       = '${PATHNEW}',%" \
 -e "s%parent_experiment_rip = .*%parent_experiment_rip = '${PRIPNEW}',%" \
 -e "s%parent_variant_label = .*%parent_variant_label = '${PVARNEW}',%" \
 -e "s%realization   = .*%realization   = ${R},%" \
 -e "s%branch_time   = .*%branch_time   = ${TIMENEW},%" \
 -e "s%branch_time_in_child   = .*%branch_time_in_child   = ${TIMENEW},%" \
 -e "s%branch_time_in_parent  = .*%branch_time_in_parent  = ${TIMENEW},%" \
 -e "s% sub_experiment = .*% sub_experiment = '${SEXPNEW}',%"\
 $NMLDIR/exp.nml 
