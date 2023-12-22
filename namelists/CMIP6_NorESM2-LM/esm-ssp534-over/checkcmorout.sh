#!/bin/bash

CMOR_ROOT=$(cd $(dirname $0) && cd ../../.. && pwd)
# parse input parameters
source $CMOR_ROOT/workflow/cmorParse.sh

years1=(2015 $(seq 2020 10 2090) 2100)
years2=(2019 $(seq 2029 10 2099) 2100)
years1+=(2101 $(seq 2110 10 2280) 2290)
years2+=(2109 $(seq 2119 10 2289) 2299)

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -o=$cmorout -yrs1="${years1[*]}" -yrs2="${years2[*]}"

