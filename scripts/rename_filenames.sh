#!/bin/bash
set -e

# change CMOR file name from:
# "*_experiment-id_source-id_*.nc"
# to
# "*_source-id_experiment-id_*.nc"
# The CMORized output file has been corrected in the noresm2cmor tool
# since 20190910

#version=v20190815
version=v20190909

cd /tos-project1/NS9034K/CMIP6/.cmorout/NorESM2-LM

dname=piClim-4xco2
echo $dname
find ./$dname/$version/ -name '*.nc' -exec rename "piClim-4xCO2_NorESM2-LM" "NorESM2-LM_piClim-4xCO2" {} \;

for dname in $(ls |cut -d"/" -f1 );
do
    if [ $dname == "piClim-4xco2" ]
    then
        continue
    fi
    echo $dname
    find ./$dname/$version/ -name '*.nc' -exec rename "${dname}_NorESM2-LM" "NorESM2-LM_${dname}" {} \;
done
