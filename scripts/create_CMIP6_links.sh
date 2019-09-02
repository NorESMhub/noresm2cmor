#!/bin/bash
set -e
pid=$$

ROOT=/projects/NS9034K/CMIP6
cd $ROOT

folders+=(cmorout/NorESM2-LM/1pctCO2/v20190815)
folders+=(cmorout/NorESM2-LM/abrupt-4xCO2/v20190815)
folders+=(cmorout/NorESM2-LM/hist-GHG/v20190815)
folders+=(cmorout/NorESM2-LM/historical/v20190815)
folders+=(cmorout/NorESM2-LM/hist-piAer/v20190815)
folders+=(cmorout/NorESM2-LM/hist-piNTCF/v20190815)
folders+=(cmorout/NorESM2-LM/piClim-4xco2/v20190815)
folders+=(cmorout/NorESM2-LM/piClim-aer/v20190815)
folders+=(cmorout/NorESM2-LM/piClim-BC/v20190815)
folders+=(cmorout/NorESM2-LM/piClim-control/v20190815)
folders+=(cmorout/NorESM2-LM/piClim-ghg/v20190815)
folders+=(cmorout/NorESM2-LM/piClim-lu/v20190815)
folders+=(cmorout/NorESM2-LM/piClim-OC/v20190815)
folders+=(cmorout/NorESM2-LM/piClim-SO2/v20190815)
folders+=(cmorout/NorESM2-LM/piControl/v20190815)

insitute=NCC
for (( i = 0; i < ${#folders[*]}; i++ )); do
    folder=${folders[i]}

    find $folder -name *.nc -print >/tmp/flist.txt.$pid
    fname1=$(head -1 /tmp/flist.txt.$pid) 
    version=$(echo $folder | awk -F/ '{print $(NF) }')
    activity=$(cdo -s showattribute,activity_id $fname1 |grep 'activity_id' |cut -d'"' -f2)
    while read -r fname
    do
        bname=$(basename $fname .nc)
        fstr=($(echo $bname |tr "_" " "))

        var=${fstr[0]}
        table=${fstr[1]}
        expid=${fstr[2]}
        model=${fstr[3]}
        real=${fstr[4]}
        grid=${fstr[5]}

        subfolder=$activity/$insitute/$model/$expid/$real/$table/$var/$grid/$version
        if [ ! -d "$subfolder" ]
        then
            mkdir -p "$subfolder"
        fi
        echo "$subfolder/${bname}.nc"
        ln -sf ../../../../../../../../../$fname "$subfolder/${bname}.nc"
    done </tmp/flist.txt.$pid
done
echo "ALL DONE"
