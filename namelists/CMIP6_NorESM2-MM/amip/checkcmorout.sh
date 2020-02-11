#!/bin/bash

version=v20191108
expid=amip
model=NorESM2-MM
years1=($(seq 1980 10 2000) 2010)
years2=($(seq 1989 10 2009) 2012)

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

