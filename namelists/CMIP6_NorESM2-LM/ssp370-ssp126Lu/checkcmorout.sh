#!/bin/bash

version=v20200702
expid=ssp370-ssp126Lu
model=NorESM2-LM
years1=(2015 $(seq 2021 10 2091))
years2=(2020 $(seq 2030 10 2099))

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

