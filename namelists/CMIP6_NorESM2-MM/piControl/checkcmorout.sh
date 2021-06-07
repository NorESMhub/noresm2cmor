#!/bin/bash

CMOR_ROOT=$(cd $(dirname $0) && cd ../../.. && pwd)
# parse input parameters
source $CMOR_ROOT/workflow/cmorParse.sh

years1=($(seq 1200 10 1290))
years2=($(seq 1209 10 1299))
years1+=($(seq 1300 10 1440) 1450 )
years2+=($(seq 1309 10 1449) 1450 )
years1+=($(seq 1450 10 1690))
years2+=($(seq 1459 10 1699))

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

