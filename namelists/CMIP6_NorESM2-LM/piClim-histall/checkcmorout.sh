#!/bin/bash

#version=v20191108b
#version=v20200218
version=v20200702
version=v20201001
expid=piClim-histall
model=NorESM2-LM
years1=(1849 $(seq 1850 10 1940))
years2=(1859 $(seq 1859 10 1949))
years1+=($(seq 1950 10 2000) 2010)
years2+=($(seq 1959 10 2009) 2014)
years1+=(2015 $(seq 2021 10 2091))
years2+=(2020 $(seq 2030 10 2100))

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

