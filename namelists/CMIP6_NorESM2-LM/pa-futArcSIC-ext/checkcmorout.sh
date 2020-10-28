#!/bin/bash

version=v20200702
expid=pa-futArcSIC-ext
model=NorESM2-LM

years1=(2000 $(seq 2010 10 2080) 2090 2090)
years2=(2009 $(seq 2019 10 2089) 2099 2100)

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

