#!/bin/bash

version=v20191108
expid=ssp370-lowNTCF
model=NorESM2-LM
years1=(2015 2021 2031 2041 2051)
years2=(2020 2030 2040 2050 2054)

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

