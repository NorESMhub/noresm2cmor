#!/bin/bash
set -e

#version=v20190815
#version=v20190909
#version=v20190917
version=v20190920

#----------------
# historical ensemble 1 part 1
#----------------
#CaseName=NHIST_f19_tn14_20190625
#expid=historical
#real=1
#login0
#years1=(1849 $(seq 1860 10 1940))
#years2=(1859 $(seq 1869 10 1949))
#----------------
# historical ensemble 1 part 2
#----------------
CaseName=NHIST_f19_tn14_20190710
expid=historical
real=1
#login1
years1=($(seq 1950 10 2000) 2010)
years2=($(seq 1959 10 2009) 2014)

#----------------
# historical ensemble 2 part 1
#----------------
#CaseName=NHIST_02_f19_tn14_20190801
#expid=historical
#real=2
#login0
#years1=(1849)
#years2=(1859)
#years1=(1849 $(seq 1860 10 1940))
#years2=(1859 $(seq 1869 10 1949))
#----------------
# historical ensemble 2 part 2
#----------------
#CaseName=NHIST_02_f19_tn14_20190813
#expid=historical
#real=2
#login1
#years1=($(seq 1950 10 2000) 2010)
#years2=($(seq 1959 10 2009) 2014)
#----------------
# historical ensemble 3 part 1
#----------------
#CaseName=NHIST_03_f19_tn14_20190801
#expid=historical
#real=3
#login2
#years1=(1849 $(seq 1860 10 1940))
#years2=(1859 $(seq 1869 10 1949))
#----------------
# historical ensemble 3 part 2
#----------------
#CaseName=NHIST_03_f19_tn14_20190813
#expid=historical
#real=3
#login3
#years1=($(seq 1950 10 2000) 2010)
#years2=($(seq 1959 10 2009) 2014)

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

    cp CMIP6_NorESM2-LM/${expid}/template/exp_${CaseName}.nml CMIP6_NorESM2-LM/${expid}/${version}/exp.nml
    sed -i "s/vyyyymmdd/${version}/" \
        CMIP6_NorESM2-LM/${expid}/${version}/exp.nml
    sed -i "s/year1         =.*/year1         = ${year1},/g" \
        CMIP6_NorESM2-LM/${expid}/${version}/exp.nml
    sed -i "s/yearn         =.*/yearn         = ${year2},/g" \
        CMIP6_NorESM2-LM/${expid}/${version}/exp.nml
    mv CMIP6_NorESM2-LM/${expid}/${version}/exp.nml CMIP6_NorESM2-LM/${expid}/${version}/exp_${year1}-${year2}_r${real}.nml

    cd ~/noresm2cmor/bin

    #nohup mpirun -n 8 ./noresm2cmor3_mpi \
    nohup ./noresm2cmor3 \
    ../namelists/CMIP6_NorESM2-LM/${expid}/${version}/sys.nml \
    ../namelists/CMIP6_NorESM2-LM/${expid}/${version}/mod.nml \
    ../namelists/CMIP6_NorESM2-LM/${expid}/${version}/exp_${year1}-${year2}_r${real}.nml \
    ../namelists/CMIP6_NorESM2-LM/${expid}/${version}/var.nml \
    1>../logs/CMIP6_NorESM2-LM/${expid}/${version}/${year1}-${year2}_r${real}.log \
    2>../logs/CMIP6_NorESM2-LM/${expid}/${version}/${year1}-${year2}_r${real}.err &

    sleep 60s
done
