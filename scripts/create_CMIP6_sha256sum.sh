#!/bin/bash
#set -e

#Version=v20190815
#Version=v20190909
Version=v20190917

# CAUTIOUS: if overwrite the sha256sum file? default is false
#OverWrite=FALSE
#OverWrite=TRUE

#tree -f -L 4 /projects/NS9034K/CMIP6/ESGF

folders+=(/projects/NS9034K/CMIP6/AerChemMIP/NCC/NorESM2-LM/hist-piAer)
folders+=(/projects/NS9034K/CMIP6/AerChemMIP/NCC/NorESM2-LM/hist-piNTCF)
folders+=(/projects/NS9034K/CMIP6/AerChemMIP/NCC/NorESM2-LM/piClim-BC)
folders+=(/projects/NS9034K/CMIP6/AerChemMIP/NCC/NorESM2-LM/piClim-OC)
folders+=(/projects/NS9034K/CMIP6/AerChemMIP/NCC/NorESM2-LM/piClim-SO2)
folders+=(/projects/NS9034K/CMIP6/CMIP/NCC/NorESM2-LM/1pctCO2)
folders+=(/projects/NS9034K/CMIP6/CMIP/NCC/NorESM2-LM/abrupt-4xCO2)
folders+=(/projects/NS9034K/CMIP6/CMIP/NCC/NorESM2-LM/historical)
folders+=(/projects/NS9034K/CMIP6/CMIP/NCC/NorESM2-LM/piControl)
folders+=(/projects/NS9034K/CMIP6/DAMIP/NCC/NorESM2-LM/hist-GHG)
folders+=(/projects/NS9034K/CMIP6/RFMIP/NCC/NorESM2-LM/piClim-4xCO2)
folders+=(/projects/NS9034K/CMIP6/RFMIP/NCC/NorESM2-LM/piClim-ghg)
folders+=(/projects/NS9034K/CMIP6/RFMIP/NCC/NorESM2-LM/piClim-lu)
folders+=(/projects/NS9034K/CMIP6/RFMIP/NCC/NorESM2-LM/piClim-aer)
folders+=(/projects/NS9034K/CMIP6/RFMIP/NCC/NorESM2-LM/piClim-control)

pid=$$
for (( i = 0; i < ${#folders[*]}; i++ )); do
    folder=${folders[i]}
    cd "$folder"
    reals=($(basename $(find -maxdepth 1  -type d -name 'r*' -print)))
    for (( j = 0; j < ${#reals[*]}; j++ )); do
        real=${reals[j]}
        echo "Process $folder/$real"
        if [ ! -z $OverWrite ] && [ "$OverWrite" == "TRUE" ]
        then
            rm -f ./.${real}.sha256sum
        fi
        k=1
        find $real/*/*/*/$Version -name *.nc -print 2>/dev/null 1>/tmp/flist.txt.$pid
        while read -r fname
        do
            sha256sum $fname &>>.${real}.sha256sum &
            while [ $k -gt 15 ]; do
                wait
                let k=1
            done
            let k+=1
        done </tmp/flist.txt.$pid
        rm -f /tmp/flist.txt.$pid
    done
done
echo "ALL DONE"
