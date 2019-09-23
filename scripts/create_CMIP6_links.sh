#!/bin/bash
#set -e
pid=$$

ROOT=/projects/NS9034K/CMIP6
cd $ROOT

#VER=v20190815
#VER=v20190909
#VER=v20190917
VER=v20190920

#folders+=(.cmorout/NorESM2-LM/1pctCO2/${VER})
#folders+=(.cmorout/NorESM2-LM/abrupt-4xCO2/${VER})
#folders+=(.cmorout/NorESM2-LM/hist-GHG/${VER})
#folders+=(.cmorout/NorESM2-LM/historical/${VER})
#folders+=(.cmorout/NorESM2-LM/hist-piAer/${VER})
#folders+=(.cmorout/NorESM2-LM/hist-piNTCF/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-4xCO2/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-aer/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-BC/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-control/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-ghg/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-lu/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-OC/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-SO2/${VER})
#folders+=(.cmorout/NorESM2-LM/piControl/${VER})
#folders+=(.cmorout/NorESM2-LM/pdSST-pdSIC/${VER})
folders+=(.cmorout/NorESM2-LM/pdSST-futArcSIC/${VER})

insitute=NCC
for (( i = 0; i < ${#folders[*]}; i++ )); do
    folder=${folders[i]}
    echo "$folder"

    find $folder -name *.nc -print 1>/tmp/flist.txt.$pid
    if [ $? -ne 0 ]
    then
        continue
    fi
    nf=$(cat /tmp/flist.txt.$pid |wc -l)
    fname1=$(head -1 /tmp/flist.txt.$pid) 
    version=$(echo $folder | awk -F/ '{print $(NF) }')
    activity=$(cdo -s showattribute,activity_id $fname1 |grep 'activity_id' |cut -d'"' -f2)
    if [ "$activity" == "RFMIP AerChemMIP" ]
    then
        activity="RFMIP"
    fi
    k=1
    while read -r fname
    do
        bname=$(basename $fname .nc)
        fstr=($(echo $bname |tr "_" " "))
        #echo $bname

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
        ln -sf ../../../../../../../../../$fname "$subfolder/${bname}.nc"
        ln -sfT "$version"  "$latest"
        echo -ne "Linking $k/$nf files\r"
        let k+=1
    done </tmp/flist.txt.$pid
done
echo "ALL DONE"
