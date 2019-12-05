#!/bin/bash

version=v20191108b
expid=piClim-lu
model=NorESM2-LM
years1=(1  11 21)
years2=(10 20 30)

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

