#!/bin/bash
set -e
pid=$$

ROOT=/projects/NS9034K/CMIP6
cd $ROOT

VER=v20190914

#folders+=(.cmorout/NorCPM1/dcppA-assim/${VER})
#folders+=(.cmorout/NorCPM1/piControl/${VER})
#folders+=(.cmorout/NorCPM1/historical/${VER})
#folders+=(.cmorout/NorCPM1/dcppA-hindcast/${VER})
folders+=(.cmorout/NorCPM1/1pctCO2/${VER})
folders+=(.cmorout/NorCPM1/abrupt4XCO2/${VER})

insitute=NCC
for (( i = 0; i < ${#folders[*]}; i++ )); do
    folder=${folders[i]}
    echo "$folder"
    pwd

    find $folder -name *.nc -print >/tmp/flist.txt.$pid
    fname1=$(head -1 /tmp/flist.txt.$pid) 
    version=$(echo $folder | awk -F/ '{print $(NF) }')
    activity=$(cdo -s showattribute,activity_id $fname1 |grep 'activity_id' |cut -d'"' -f2)
    if [ "$activity" == "RFMIP AerChemMIP" ]
    then
        activity="RFMIP"
    fi
    while read -r fname
    do
        bname=$(basename $fname .nc)
        fstr=($(echo $bname |tr "_" " "))

        var=${fstr[0]}
        table=${fstr[1]}
        model=${fstr[2]}
        expid=${fstr[3]}
        real=${fstr[4]}
        grid=${fstr[5]}

        subfolder=$activity/$insitute/$model/$expid/$real/$table/$var/$grid/$version
        latest=$activity/$insitute/$model/$expid/$real/$table/$var/$grid/latest
        if [ ! -d "$subfolder" ]
        then
            mkdir -p "$subfolder"
        fi
        if [ ! -e $subfolder/${bname}.nc ] 
        then  
          echo processing $fname 
          ln -sf ../../../../../../../../../$fname "$subfolder/${bname}.nc"
        else 
          echo skipping $fname 
        fi 
        if [ ! -e $latest ] 
        then
          ln -sfT "$version"  "$latest"
        fi 
    done </tmp/flist.txt.$pid
done
echo "ALL DONE"
