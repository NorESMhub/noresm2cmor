#!/bin/bash
set -e

version=v20190920

#----------------
# piClim-histall, esemble 1
#----------------
#CaseName=NFHISTnorpibc_f19_20190810
#expid=piClim-histall
#real=1
#login0
#years1=(1849 $(seq 1860 10 1940))
#years2=(1859 $(seq 1869 10 1949))
#login1
#years1=($(seq 1950 10 2000) 2010)
#years2=($(seq 1959 10 2009) 2014)

#----------------
# piClim-histall, esemble 2
#----------------
CaseName=NFHISTnorpibc_02_f19_20190909
expid=piClim-histall
real=2
#login0
#years1=(1849 $(seq 1860 10 1940))
#years2=(1859 $(seq 1869 10 1949))
#login1
years1=($(seq 1950 10 2000) 2010)
years2=($(seq 1959 10 2009) 2014)

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
if [ ! -z $CaseName ]
then
    CaseName="_${CaseName}"
fi
if [ ! -z $real ]
then
    real="r${real}"
fi

#sleep 6h
# copy template namelist and submit
for (( i = 0; i < ${#years1[*]}; i++ )); do
    year1=${years1[i]}
    year2=${years2[i]}
    echo ${year1} ${year2}
    cd ~/noresm2cmor/namelists

    cp CMIP6_NorESM2-LM/${expid}/template/exp${CaseName}.nml CMIP6_NorESM2-LM/${expid}/${version}/exp.nml
    sed -i "s/vyyyymmdd/${version}/" \
        CMIP6_NorESM2-LM/${expid}/${version}/exp.nml
    sed -i "s/year1         =.*/year1         = ${year1},/g" \
        CMIP6_NorESM2-LM/${expid}/${version}/exp.nml
    sed -i "s/yearn         =.*/yearn         = ${year2},/g" \
        CMIP6_NorESM2-LM/${expid}/${version}/exp.nml
    mv CMIP6_NorESM2-LM/${expid}/${version}/exp.nml CMIP6_NorESM2-LM/${expid}/${version}/exp_${year1}-${year2}${real}.nml

    cd ~/noresm2cmor/bin

    nmlroot="../namelists/CMIP6_NorESM2-LM/${expid}/${version}"
    logroot="../logs/CMIP6_NorESM2-LM/${expid}/${version}"

    #nohup mpirun -n 5 ./noresm2cmor3_mpi \
    nohup ./noresm2cmor3 \
            ${nmlroot}/sys.nml \
            ${nmlroot}/mod.nml \
            ${nmlroot}/exp_${year1}-${year2}${real}.nml \
            ${nmlroot}/var.nml \
            1>${logroot}/${year1}-${year2}${real}.log \
            2>${logroot}/${year1}-${year2}${real}.err &

    sleep 60s
done
