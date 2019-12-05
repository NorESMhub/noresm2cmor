#!/bin/bash

version=v20190920
version=v20191108b
expid=piControl
model=NorESM2-LM

years1+=($(seq 1600 10 1790) 1701 1800)
years2+=($(seq 1609 10 1799) 1709 1800)
years1+=($(seq 1801 10 1891))
years2+=($(seq 1810 10 1900))
years1+=($(seq 1901 10 1991))
years2+=($(seq 1910 10 2000))
years1+=($(seq 2001 10 2091))
years2+=($(seq 2010 10 2100))


if [ $(hostname -f |grep 'ipcc') ]
then
    wfroot=/scratch/NS9034K/noresm2cmor/workflow
else
    wfroot=~/noresm2cmor/workflow
fi
${wfroot}/cmorCheck.sh -v=$version -e=$expid -m=$model -yrs1="${years1[*]}" -yrs2="${years2[*]}"
