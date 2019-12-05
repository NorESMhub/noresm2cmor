#!/bin/bash

version=v20191108
expid=ssp126
model=NorESM2-MM
years1=(2015 $(seq 2021 10 2091))
years2=(2020 $(seq 2030 10 2100))

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

