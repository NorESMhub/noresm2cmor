#!/bin/bash

version=v20191108b
expid=omip1
model=NorESM2-LM
years1=($(seq 1700 10 1790))
years2=($(seq 1709 10 1799))
years1+=($(seq 1800 10 1890))
years2+=($(seq 1809 10 1899))
years1+=($(seq 1900 10 1990))
years2+=($(seq 1909 10 1999))
years1+=($(seq 2010 10 2060) 2070)
years2+=($(seq 2019 10 2069) 2071)


if [ $(hostname -f |grep 'ipcc') ]
then
    wfroot=/scratch/NS9034K/noresm2cmor/workflow
else
    wfroot=~/noresm2cmor/workflow
fi
${wfroot}/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"

