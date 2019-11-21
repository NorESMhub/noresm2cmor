#!/bin/bash

version=v20191108b
expid=piClim-histghg
model=NorESM2-LM
years1=(1849 $(seq 1860 10 1940))
years2=(1859 $(seq 1869 10 1949))
years1+=($(seq 1950 10 2000) 2010)
years2+=($(seq 1959 10 2009) 2014)

../../../scripts/cmoroutcheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

