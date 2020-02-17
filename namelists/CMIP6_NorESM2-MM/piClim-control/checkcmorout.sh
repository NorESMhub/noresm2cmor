#!/bin/bash

version=v20200206
expid=piClim-control
model=NorESM2-MM
years1=(1  11 21)
years2=(10 20 30)

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

