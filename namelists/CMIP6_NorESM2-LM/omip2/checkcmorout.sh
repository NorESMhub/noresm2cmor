#!/bin/bash

version=v20191108b
expid=omip2
model=NorESM2-LM
years1=(1653 $(seq 1660 10 1750))
years2=(1659 $(seq 1669 10 1759))
years1+=($(seq 1760 10 1850))
years2+=($(seq 1769 10 1859))
years1+=($(seq 1860 10 1950))
years2+=($(seq 1869 10 1959))
years1+=($(seq 1960 10 2000) 2010)
years2+=($(seq 1969 10 2009) 2018)

../../../scripts/cmoroutcheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

