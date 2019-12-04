#!/bin/bash

version=v20191108b
expid=piClim-2xDMS
model=NorESM2-LM
years1=(0  1  11 21)
years2=(10 10 20 30)

if [ $(hostname -f |grep 'ipcc') ]
then
    wfroot=/scratch/NS9034K/noresm2cmor/workflow
else
    wfroot=~/noresm2cmor/workflow
fi
${wfroot}/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

