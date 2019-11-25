#!/bin/bash

version=v20191108
expid=esm-pi-CO2pulse
model=NorESM2-LM
years1=(1849 $(seq 1850 10 1940))
years2=(1859 $(seq 1859 10 1949))

../../../scripts/cmoroutcheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

