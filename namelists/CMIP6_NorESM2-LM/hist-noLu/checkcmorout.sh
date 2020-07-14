#!/bin/bash

version=v20200702
expid=hist-noLu
model=NorESM2-LM
years1=(1849 $(seq 1850 10 2000) 2010)
years2=(1859 $(seq 1859 10 2009) 2014)

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

