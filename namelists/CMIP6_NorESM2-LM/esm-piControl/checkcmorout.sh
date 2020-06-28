#!/bin/bash

version=v20191108b
expid=esm-piControl
model=NorESM2-LM
years1=($(seq 1851 10 2091))
years2=($(seq 1860 10 2100))

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

