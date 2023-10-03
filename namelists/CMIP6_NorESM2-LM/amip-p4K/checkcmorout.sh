#!/bin/bash

CMOR_ROOT=$(cd $(dirname $0) && cd ../../.. && pwd)
# parse input parameters
source $CMOR_ROOT/workflow/cmorParse.sh

years1=(1975)
years2=(1979)
years1+=(1979 $(seq 1980 10 2000) 2010)
years2+=(1979 $(seq 1989 10 2009) 2014)
years1+=(2015)
years2+=(2020)

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -o=$cmorout -yrs1="${years1[*]}" -yrs2="${years2[*]}"

