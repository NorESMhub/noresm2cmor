#!/bin/bash

version=v20191108
expid=lig127k
model=NorESM2-LM

years1=($(seq 2101 10 2191))
years2=($(seq 2110 10 2200))


if [ $(hostname -f |grep 'ipcc') ]
then
    wfroot=/scratch/NS9034K/noresm2cmor/workflow
else
    wfroot=~/noresm2cmor/workflow
fi
${wfroot}/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

