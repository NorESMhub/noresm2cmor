#!/bin/bash
set -e

#version=v20190815
version=v20190909

cd /tos-project1/NS9034K/CMIP6
for dname in AerChemMIP CMIP DAMIP RFMIP
do
    echo $dname
    #for filename in `find $dname/NCC/NorESM2-LM -name '.r1i1p1f1.map' -print`
        #do
        #echo ${filename}
        #expid=$(echo $filename |awk -F"/" '{print $(NF-1)}')
        #sed -i "s/${expid}_NorESM2-LM/NorESM2-LM_${expid}/" $filename
    #done
    #for filename in `find $dname/NCC/NorESM2-LM -name '.r1i1p1f1.sha256sum' -print`
        #do
        #echo ${filename}
        #expid=$(echo $filename |awk -F"/" '{print $(NF-1)}')
        #sed -i "s/${expid}_NorESM2-LM/NorESM2-LM_${expid}/" $filename
    #done
    # remove sha256sum for v20190909
    for filename in `find $dname/NCC/NorESM2-LM -name '.r1i1p1f1.sha256sum' -print`
        do
        echo ${filename}
        sed -i '/v20190909/d' ${filename}
    done
done
