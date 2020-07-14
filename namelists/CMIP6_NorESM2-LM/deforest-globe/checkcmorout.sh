#!/bin/bash

version=v20200702
expid=deforest-globe
model=NorESM2-LM
years1=($(seq 1850 10 1920) 1930)
years2=($(seq 1859 10 1929) 1930)

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

