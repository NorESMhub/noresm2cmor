#!/bin/bash

CMOR_ROOT=$(cd $(dirname $0) && cd ../../.. && pwd)
# parse input parameters
source $CMOR_ROOT/workflow/cmorParse.sh

years1+=(2000)
years2+=(2001)

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

