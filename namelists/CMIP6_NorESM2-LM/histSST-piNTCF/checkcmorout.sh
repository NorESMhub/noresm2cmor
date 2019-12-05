#!/bin/bash

version=v20191108b
expid=histSST-piNTCF
model=NorESM2-LM
years1=(1849 $(seq 1850 10 1940))
years2=(1859 $(seq 1859 10 1949))
years1+=($(seq 1950 10 2000) 2010)
years2+=($(seq 1959 10 2009) 2014)

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

