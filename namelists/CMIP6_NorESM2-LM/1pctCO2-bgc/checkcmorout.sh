#!/bin/bash

version=v20200702
version=v20201001
expid=1pctCO2-bgc
model=NorESM2-LM

years1=(0 $(seq 1 10 131))
years2=(10 $(seq 10 10 140))

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

