#!/bin/bash

CMOR_ROOT=$(cd $(dirname $0) && cd ../../.. && pwd)
# parse input parameters
source $CMOR_ROOT/workflow/cmorParse.sh

years1=($(seq 1501 10 1591))
years2=($(seq 1510 10 1600))

years1+=($(seq 1601 10 1691))
years2+=($(seq 1610 10 1700))

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"
