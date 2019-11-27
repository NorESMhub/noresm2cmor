#!/bin/bash

version=v20191108b
expid=pdSST-futArcSIC
model=NorESM2-LM

years1+=(2000)
years2+=(2001)


if [ $(hostname -f |grep 'ipcc') ]
then
    wfroot=/scratch/NS9034K/noresm2cmor/workflow
else
    wfroot=~/noresm2cmor/workflow
fi
${wfroot}/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

