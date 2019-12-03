#!/bin/bash

version=v20191108
expid=ssp370
model=NorESM2-LM
years1=(2015 $(seq 2021 10 2091))
years2=(2020 $(seq 2030 10 2100))


if [ $(hostname -f |grep 'ipcc') ]
then
    wfroot=/scratch/NS9034K/noresm2cmor/workflow
else
    wfroot=~/noresm2cmor/workflow
fi
${wfroot}/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

