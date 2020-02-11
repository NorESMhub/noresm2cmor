#!/bin/bash

version=v20200206
expid=1pctCO2-rad
model=NorESM2-LM
years1=($(seq 1  10 131))
years2=($(seq 10 10 140))

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

