#!/bin/bash

CMOR_ROOT=$(cd $(dirname $0) && cd ../../.. && pwd)
# parse input parameters
source $CMOR_ROOT/workflow/cmorParse.sh

years1=(2020 $(seq 2030 10 2090) 2100)
years2=(2029 $(seq 2039 10 2099) 2100)

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -o=$cmoroutroot -yrs1="${years1[*]}" -yrs2="${years2[*]}"

