#!/bin/bash

#version=v20191108b
version=v20191108
expid=abrupt-4xCO2
model=NorESM2-LM
years1=(0  $(seq 1  10 111))
years2=(10 $(seq 10 10 120))
years1+=($(seq 121 10 141))
years2+=($(seq 130 10 150))
years1+=($(seq 151 10 291))
years2+=($(seq 160 10 300))
years1+=($(seq 301 10 491))
years2+=($(seq 310 10 500))

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

