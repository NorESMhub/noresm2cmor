#!/bin/bash

# parse input parameters
source $CMOR_ROOT/workflow/cmorParse.sh

years1=(1  11 21)
years2=(10 20 30)

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

