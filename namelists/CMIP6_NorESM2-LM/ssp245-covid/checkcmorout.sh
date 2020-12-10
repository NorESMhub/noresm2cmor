#!/bin/bash

version=v20201001
expid=ssp245-covid
model=NorESM2-LM
years1=(2015 $(seq 2021 10 2041))
years2=(2020 $(seq 2030 10 2050))

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"
