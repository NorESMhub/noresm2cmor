#!/bin/bash

# parse input parameters
source $CMOR_ROOT/workflow/cmorParse.sh

years1=(2015 $(seq 2021 10 2091))
years2=(2020 $(seq 2030 10 2100))

years1+=(2015 $(seq 2021 10 2091))
years2+=(2021 $(seq 2031 10 2101))

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

