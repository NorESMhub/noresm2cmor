#!/bin/bash
#set -e
pid=$$

ROOT=/projects/NS9034K/CMIP6
cd $ROOT

# set data version
#VER=v20190815
#VER=v20190909
#VER=v20190917
VER=v20190920
#VER=v20191009
#VER=v20191018
#VER=v20191022

# set extra find operator
fop="-mtime -2"     #modified in two days

# set paths of cmorized data
#folders+=(.cmorout/NorESM2-LM/1pctCO2/${VER})
#folders+=(.cmorout/NorESM2-LM/abrupt-4xCO2/${VER})
#folders+=(.cmorout/NorESM2-LM/hist-GHG/${VER})
#folders+=(.cmorout/NorESM2-LM/historical/${VER})
#folders+=(.cmorout/NorESM2-LM/hist-piAer/${VER})
#folders+=(.cmorout/NorESM2-LM/hist-piNTCF/${VER})
#folders+=(.cmorout/NorESM2-LM/piControl/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-spAer-aer/${VER})
#folders+=(.cmorout/NorESM2-LM/esm-hist/${VER})
#folders+=(.cmorout/NorESM2-LM/omip1/${VER})
#folders+=(.cmorout/NorESM2-LM/omip2/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-spAer-anthro/${VER})

folders+=(.cmorout/NorESM2-LM/1pctCO2-cdr/${VER})

#folders+=(.cmorout/NorESM2-LM/pdSST-pdSIC/${VER})
#folders+=(.cmorout/NorESM2-LM/pdSST-futArcSIC/${VER})
#folders+=(.cmorout/NorESM2-LM/pdSST-piAntSIC/${VER})
#folders+=(.cmorout/NorESM2-LM/pdSST-futAntSIC/${VER})

#folders+=(.cmorout/NorESM2-LM/histSST/${VER})
#folders+=(.cmorout/NorESM2-LM/histSST-piAer/${VER})
#folders+=(.cmorout/NorESM2-LM/histSST-piNTCF/${VER})

#folders+=(.cmorout/NorESM2-LM/piClim-4xCO2/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-aer/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-BC/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-control/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-ghg/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-lu/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-OC/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-SO2/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-anthro/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-2xss/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-2xdust/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-2xDMS/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-2xVOC/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-CH4/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-N2O/${VER})

#folders+=(.cmorout/NorESM2-LM/piClim-histall/${VER})

insitute=NCC
for (( i = 0; i < ${#folders[*]}; i++ )); do
    folder=${folders[i]}
    echo "$folder"

    # extra operatore, e.g., -mtime -2, modified within 2 days
    find $folder $fop -name *.nc -print 1>/tmp/flist.txt.$pid

    # if no files found
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
echo "--------"
echo "ALL DONE"
