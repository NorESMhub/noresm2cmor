#!/bin/bash

# parse input parameters
source $CMOR_ROOT/workflow/cmorParse.sh

years1=(2000)
years2=(2001)
years1+=(2000)
years2+=(2000)

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -o=/projects/NS9015K/oddho/BlueAction/cmorout \
    -yrs1="${years1[*]}" -yrs2="${years2[*]}"

