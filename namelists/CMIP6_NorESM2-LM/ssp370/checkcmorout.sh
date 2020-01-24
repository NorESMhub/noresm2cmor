#!/bin/bash

version=v20191108
expid=ssp370
model=NorESM2-LM
years1=(2015 $(seq 2021 10 2041))
years2=(2020 $(seq 2030 10 2050))
years1+=(2051 $(seq 2051 10 2091))
years2+=(2054 $(seq 2060 10 2100))

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

