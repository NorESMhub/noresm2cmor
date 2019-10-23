#!/bin/bash
set -e

#version=v20190920
version=v20191022

#----------------
# omip1
#----------------
ExpName=NOIIAJRAOC20TR_TL319_tn14_20190710
expid=omip2
#login0
#years1=(1653 $(seq 1660 10 1790))
#years2=(1659 $(seq 1669 10 1799))

#login1
#years1=($(seq 1800 10 1950))
#years2=($(seq 1809 10 1959))

#login2
years1=($(seq 1960 10 1990) 2010)
years2=($(seq 1969 10 1999) 2018)

# ==========================================================
if [ ! -d ~/noresm2cmor/namelists/CMIP6_NorESM2-LM/${expid}/${version} ]
then
    mkdir -p ~/noresm2cmor/namelists/CMIP6_NorESM2-LM/${expid}/${version}
fi
if [ ! -d ~/noresm2cmor/logs/CMIP6_NorESM2-LM/${expid}/${version} ]
then
    mkdir -p ~/noresm2cmor/logs/CMIP6_NorESM2-LM/${expid}/${version}
fi
# check if sys mod var namelist exist
if [ ! -e ~/noresm2cmor/namelists/CMIP6_NorESM2-LM/${expid}/${version}/sys.nml ]
then
    echo "ERROR: ../namelists/CMIP6_NorESM2-LM/${expid}/${version}/sys.nml does not exist"
    echo "EXIT..."
    exit
fi
if [ ! -e ~/noresm2cmor/namelists/CMIP6_NorESM2-LM/${expid}/${version}/mod.nml ]
then
    echo "ERROR:../namelists/CMIP6_NorESM2-LM/${expid}/${version}/mod.nml does not exist"
    echo "EXIT..."
    exit
fi
if [ ! -e ~/noresm2cmor/namelists/CMIP6_NorESM2-LM/${expid}/${version}/var.nml ]
then
    echo "ERROR: ../namelists/CMIP6_NorESM2-LM/${expid}/${version}/var.nml does not exist"
    echo "EXIT..."
    exit
fi

#sleep 6h
# copy template namelist and submit
for (( i = 0; i < ${#years1[*]}; i++ )); do
    year1=${years1[i]}
    year2=${years2[i]}
    echo ${year1} ${year2}
    cd ~/noresm2cmor/namelists

    cp CMIP6_NorESM2-LM/${expid}/template/exp.nml CMIP6_NorESM2-LM/${expid}/${version}/exp.nml
    sed -i "s/vyyyymmdd/${version}/" \
        CMIP6_NorESM2-LM/${expid}/${version}/exp.nml
    sed -i "s/year1         =.*/year1         = ${year1},/g" \
        CMIP6_NorESM2-LM/${expid}/${version}/exp.nml
    sed -i "s/yearn         =.*/yearn         = ${year2},/g" \
        CMIP6_NorESM2-LM/${expid}/${version}/exp.nml
    mv CMIP6_NorESM2-LM/${expid}/${version}/exp.nml CMIP6_NorESM2-LM/${expid}/${version}/exp_${year1}-${year2}.nml

    cd ~/noresm2cmor/bin

    #nohup mpirun -n 8 ./noresm2cmor3_mpi \
    nohup ./noresm2cmor3 \
    ../namelists/CMIP6_NorESM2-LM/${expid}/${version}/sys.nml \
    ../namelists/CMIP6_NorESM2-LM/${expid}/${version}/mod.nml \
    ../namelists/CMIP6_NorESM2-LM/${expid}/${version}/exp_${year1}-${year2}.nml \
    ../namelists/CMIP6_NorESM2-LM/${expid}/${version}/var.nml
    1>../logs/CMIP6_NorESM2-LM/${expid}/${version}/${year1}-${year2}.log \
    2>../logs/CMIP6_NorESM2-LM/${expid}/${version}/${year1}-${year2}.err &

    sleep 60s
done
