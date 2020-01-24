#!/bin/bash

version=v20191108
expid=abrupt-4xCO2
model=NorESM2-MM
years1=(0 1  $(seq 11 10 111))
years2=(10 10 $(seq 20 10 120))
years1+=($(seq 121 10 141))
years2+=($(seq 130 10 150))

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

