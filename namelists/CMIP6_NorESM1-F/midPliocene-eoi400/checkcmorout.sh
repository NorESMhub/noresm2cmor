#!/bin/bash

# parse input parameters
source $CMOR_ROOT/workflow/cmorParse.sh

years1=($(seq 2301 10 2391))
years2=($(seq 2310 10 2400))

years1+=($(seq 2401 10 2491))
years2+=($(seq 2410 10 2500))

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"
