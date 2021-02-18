#!/bin/bash

# parse input parameters
source $CMOR_ROOT/workflow/cmorParse.sh

years1=(1979 $(seq 1980 10 2000) 2010)
years2=(1979 $(seq 1989 10 2009) 2014)

#years1+=(1979 $(seq 1980 10 2000) 2010)
#years2+=(1980 $(seq 1990 10 2010) 2015)


${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

