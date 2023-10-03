#!/bin/bash

CMOR_ROOT=$(cd $(dirname $0) && cd ../../.. && pwd)
# parse input parameters
source $CMOR_ROOT/workflow/cmorParse.sh

years1=(2015 $(seq 2021 10 2091))
years2=(2020 $(seq 2030 10 2100))

years1+=(2015 $(seq 2021 10 2091))
years2+=(2021 $(seq 2031 10 2101))

years1+=(2101 $(seq 2110 10 2280) 2290)
years2+=(2109 $(seq 2119 10 2289) 2298)

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -o=$cmorout -yrs1="${years1[*]}" -yrs2="${years2[*]}"

