#!/bin/bash

version=v20191108b
expid=1pctCO2-cdr
model=NorESM2-LM

years1=(141 $(seq 150 10 270))
years2=(149 $(seq 159 10 279))

years1+=($(seq 280 10 300))
years2+=($(seq 289 10 309))

years1+=($(seq 310 10 390))
years2+=($(seq 319 10 399))


if [ $(hostname -f |grep 'ipcc') ]
then
    wfroot=/scratch/NS9034K/noresm2cmor/workflow
else
    wfroot=~/noresm2cmor/workflow
fi
${wfroot}/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

