#!/bin/bash

model=NorESM2-MM
expid=hist-cloud
#version=v20211028a
version=v20220114a
cmorout=/projects/NS9252K/cmorout/

CMOR_ROOT=$(cd $(dirname $0) && cd ../../.. && pwd)
# parse input parameters
source $CMOR_ROOT/workflow/cmorParse.sh -m=$model -e=$expid -v=$version -o=$cmorout

years1=(1850 $(seq 1860 10 2000) 2010)
years2=(1859 $(seq 1869 10 2009) 2015)

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -o=$cmorout -yrs1="${years1[*]}" -yrs2="${years2[*]}"

