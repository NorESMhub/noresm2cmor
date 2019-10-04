#!/bin/bash
set -e

version=v20190920

#----------------
# lig127k
#----------------
ExpName=NBF1850OC_f19_tn11_01_6ka
expid=midHolocene
#login0
#years1=($(seq 1501 10 1591))
#years2=($(seq 1510 10 1600))

#login1
years1=($(seq 1601 10 1691))
years2=($(seq 1610 10 1700))

# ==========================================================
if [ ! -d ~/noresm2cmor/namelists/CMIP6_NorESM1-F/${expid}/${version} ]
then
    mkdir -p ~/noresm2cmor/namelists/CMIP6_NorESM1-F/${expid}/${version}
fi
if [ ! -d ~/noresm2cmor/logs/CMIP6_NorESM1-F/${expid}/${version} ]
then
    mkdir -p ~/noresm2cmor/logs/CMIP6_NorESM1-F/${expid}/${version}
fi
# check if sys mod var namelist exist
if [ ! -e ~/noresm2cmor/namelists/CMIP6_NorESM1-F/${expid}/${version}/sys.nml ]
then
    echo "ERROR: ../namelists/CMIP6_NorESM1-F/${expid}/${version}/sys.nml does not exist"
    echo "EXIT..."
    exit
fi
if [ ! -e ~/noresm2cmor/namelists/CMIP6_NorESM1-F/${expid}/${version}/mod.nml ]
then
    echo "ERROR:../namelists/CMIP6_NorESM1-F/${expid}/${version}/mod.nml does not exist"
    echo "EXIT..."
    exit
fi
if [ ! -e ~/noresm2cmor/namelists/CMIP6_NorESM1-F/${expid}/${version}/var.nml ]
then
    echo "ERROR: ../namelists/CMIP6_NorESM1-F/${expid}/${version}/var.nml does not exist"
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

    cp CMIP6_NorESM1-F/${expid}/template/exp.nml CMIP6_NorESM1-F/${expid}/${version}/exp.nml
    sed -i "s/vyyyymmdd/${version}/" \
        CMIP6_NorESM1-F/${expid}/${version}/exp.nml
    sed -i "s/year1         =.*/year1         = ${year1},/g" \
        CMIP6_NorESM1-F/${expid}/${version}/exp.nml
    sed -i "s/yearn         =.*/yearn         = ${year2},/g" \
        CMIP6_NorESM1-F/${expid}/${version}/exp.nml
    mv CMIP6_NorESM1-F/${expid}/${version}/exp.nml CMIP6_NorESM1-F/${expid}/${version}/exp_${year1}-${year2}.nml

    cd ~/noresm2cmor/bin

    #nohup mpirun -n 8 ./noresm2cmor3_mpi \
    nohup ./noresm2cmor3 \
    ../namelists/CMIP6_NorESM1-F/${expid}/${version}/sys.nml \
    ../namelists/CMIP6_NorESM1-F/${expid}/${version}/mod.nml \
    ../namelists/CMIP6_NorESM1-F/${expid}/${version}/exp_${year1}-${year2}.nml \
    ../namelists/CMIP6_NorESM1-F/${expid}/${version}/var.nml \
    1>../logs/CMIP6_NorESM1-F/${expid}/${version}/${year1}-${year2}.log \
    2>../logs/CMIP6_NorESM1-F/${expid}/${version}/${year1}-${year2}.err &

    sleep 60s
done
