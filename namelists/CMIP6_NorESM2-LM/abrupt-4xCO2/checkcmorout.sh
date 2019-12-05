#!/bin/bash

version=v20191108b
expid=abrupt-4xCO2
model=NorESM2-LM
years1=(0  $(seq 11 10 111))
years2=(10 $(seq 20 10 120))
years1+=($(seq 121 10 141))
years2+=($(seq 130 10 150))
years1+=($(seq 151 10 291))
years2+=($(seq 160 10 300))

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

