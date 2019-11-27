#!/bin/bash

version=v20191108b
expid=1pctCO2
model=NorESM2-LM
years1=(0  $(seq 11 10 111))
years2=(10 $(seq 20 10 120))
years1+=($(seq 121 10 141))
years2+=($(seq 130 10 150))


if [ $(hostname -f |grep 'ipcc') ]
then
    wfroot=/scratch/NS9034K/noresm2cmor/workflow
else
    wfroot=~/noresm2cmor/workflow
fi
${wfroot}/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

