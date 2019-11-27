#!/bin/bash

version=v20191108
expid=esm-pi-cdr-pulse
model=NorESM2-LM
years1=(1849 $(seq 1850 10 1940))
years2=(1859 $(seq 1859 10 1949))


if [ $(hostname -f |grep 'ipcc') ]
then
    wfroot=/scratch/NS9034K/noresm2cmor/workflow
else
    wfroot=~/noresm2cmor/workflow
fi
${wfroot}/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

