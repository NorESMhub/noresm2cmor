#!/bin/bash

version=v20191108b
expid=pdSST-piArcSIC
model=NorESM2-LM

years1+=(2000)
years2+=(2001)

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

