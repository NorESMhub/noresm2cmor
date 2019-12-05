#!/bin/bash

version=v20191108
expid=lig127k
model=NorESM2-LM

years1=($(seq 2101 10 2191))
years2=($(seq 2110 10 2200))

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

