#!/bin/bash
set -x

year1=2021
year2=2030

ryear1=2015
ryear2=2020

model=NorESM2-MM
expid=ssp245
version=v20191108
real=r1
project=NS9034K

pnml=${CMOR_ROOT}/namelists/CMIP6_${model}/${expid}/${version}
plog=${CMOR_ROOT}/logs/CMIP6_${model}/${expid}/${version}

cmorSelvar.sh -m=${model} -e=${expid} -v=${version} -r=1 -yr1=${year1} -yr2=${year2} -ryr1=${ryear1} -ryr2=${ryear2}

# keep maximumn 8 jobs
flag=true
while $flag ; do
    sleep 30s
    np=$(ps x |grep -c 'noresm2cmor3')
    if [ $np -lt 8 ]; then
        flag=false
    fi
done

cd ${CMOR_ROOT}/bin
nohup mpirun -n 8 ./noresm2cmor3_mpi \
      ${pnml}/sys${project}.nml \
      ${pnml}/mod.nml \
      ${pnml}/exp_${year1}-${year2}${real}.nml \
      ${pnml}/var_${year1}-${year2}${real}.nml \
      1>${plog}/${year1}-${year2}${real}.log \
      2>${plog}/${year1}-${year2}${real}.err &
