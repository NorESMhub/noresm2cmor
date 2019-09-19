#!/bin/bash
#set -ex

# remove wrong files in v20190815

cd /projects/NS9034K/CMIP6/.cmorout/NorESM2-LM
for dname in $(ls -1 |cut -d"/" -f1)
do
    echo $dname
    #rm -f ${dname}_rmfiles.txt
    # 1, remove not-requested fields by cmip6: loadbc loadpoa
    for prefix in loadbc loapoa
    do
        rm -f ${dname}/v20190815/${prefix}_Emon_*.nc
    done
    # 2, remove Emon fields affected by bugs in m_modelsatm.F : hus loaddust loadss ps rsdsdiff ua va wap
    for prefix in hus loaddust loadss ps rsdsdiff ua va wap
    do
        rm -f ${dname}/v20190815/${prefix}_Emon_*.nc
    done
    # 3, remove CLM history files affected fields for Lmon and LImon tables
    #    for prefix in $(ls ${dname}/v20190815/*_*02-*.nc 2>/dev/null |cut -d"_" -f1-3 |sort -u)
    #    not include piClim-lu piControl
    for prefix in 1pctCO2 abrupt-4xCO2 hist-GHG historical hist-piAer hist-piNTCF piClim-4xCO2 piClim-aer piClim-BC piClim-control piClim-ghg piClim-OC piClim-SO2
        do
            for filename in $(ls ${prefix}_*.nc)
                do
                rm -f ${filename}
            done
    done
done

