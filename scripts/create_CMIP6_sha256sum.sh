#!/bin/bash
#set -x

# Data Version
#Version=v20190815
#Version=v20190909
#Version=v20190917
Version=v20190920
#Version=v20191009
#Version=v20191018
#Version=v20191022

# set if overwrite the whole .sha256sum file
#OverWrite=TRUE

# set if replace or skip the existing sha256sum entries
WriteMode="skip"
#WriteMode="replace"

# AerChemMIP
#folders+=(/projects/NS9034K/CMIP6/AerChemMIP/NCC/NorESM2-LM/hist-piAer)
#folders+=(/projects/NS9034K/CMIP6/AerChemMIP/NCC/NorESM2-LM/hist-piNTCF)
#folders+=(/projects/NS9034K/CMIP6/AerChemMIP/NCC/NorESM2-LM/piClim-BC)
#folders+=(/projects/NS9034K/CMIP6/AerChemMIP/NCC/NorESM2-LM/piClim-OC)
#folders+=(/projects/NS9034K/CMIP6/AerChemMIP/NCC/NorESM2-LM/piClim-SO2)
#folders+=(/projects/NS9034K/CMIP6/AerChemMIP/NCC/NorESM2-LM/piClim-2xss)
#folders+=(/projects/NS9034K/CMIP6/AerChemMIP/NCC/NorESM2-LM/piClim-2xdust)
#folders+=(/projects/NS9034K/CMIP6/AerChemMIP/NCC/NorESM2-LM/piClim-2xDMS)
#folders+=(/projects/NS9034K/CMIP6/AerChemMIP/NCC/NorESM2-LM/piClim-2xVOC)
#folders+=(/projects/NS9034K/CMIP6/AerChemMIP/NCC/NorESM2-LM/piClim-CH4)
#folders+=(/projects/NS9034K/CMIP6/AerChemMIP/NCC/NorESM2-LM/piClim-N2O)
#folders+=(/projects/NS9034K/CMIP6/AerChemMIP/NCC/NorESM2-LM/histSST)
#folders+=(/projects/NS9034K/CMIP6/AerChemMIP/NCC/NorESM2-LM/histSST-piAer)
#folders+=(/projects/NS9034K/CMIP6/AerChemMIP/NCC/NorESM2-LM/histSST-piNTCF)

# CMIP
#folders+=(/projects/NS9034K/CMIP6/CMIP/NCC/NorESM2-LM/1pctCO2)
#folders+=(/projects/NS9034K/CMIP6/CMIP/NCC/NorESM2-LM/abrupt-4xCO2)
#folders+=(/projects/NS9034K/CMIP6/CMIP/NCC/NorESM2-LM/historical)
#folders+=(/projects/NS9034K/CMIP6/CMIP/NCC/NorESM2-LM/piControl)
#folders+=(/projects/NS9034K/CMIP6/CMIP/NCC/NorESM2-LM/esm-hist)
#folders+=(/projects/NS9034K/CMIP6/CMIP/NCC/NorESM2-LM/esm-piControl)

# DAMIP
#folders+=(/projects/NS9034K/CMIP6/DAMIP/NCC/NorESM2-LM/hist-GHG)

# RFMIP
#folders+=(/projects/NS9034K/CMIP6/RFMIP/NCC/NorESM2-LM/piClim-4xCO2)
#folders+=(/projects/NS9034K/CMIP6/RFMIP/NCC/NorESM2-LM/piClim-ghg)
#folders+=(/projects/NS9034K/CMIP6/RFMIP/NCC/NorESM2-LM/piClim-lu)
#folders+=(/projects/NS9034K/CMIP6/RFMIP/NCC/NorESM2-LM/piClim-aer)
#folders+=(/projects/NS9034K/CMIP6/RFMIP/NCC/NorESM2-LM/piClim-control)
#folders+=(/projects/NS9034K/CMIP6/RFMIP/NCC/NorESM2-LM/piClim-spAer-aer)
#folders+=(/projects/NS9034K/CMIP6/RFMIP/NCC/NorESM2-LM/piClim-spAer-anthro)
#folders+=(/projects/NS9034K/CMIP6/RFMIP/NCC/NorESM2-LM/piClim-anthro)
#folders+=(/projects/NS9034K/CMIP6/RFMIP/NCC/NorESM2-LM/piClim-histall)

# PAMIP
#folders+=(/projects/NS9034K/CMIP6/PAMIP/NCC/NorESM2-LM/pdSST-pdSIC)
#folders+=(/projects/NS9034K/CMIP6/PAMIP/NCC/NorESM2-LM/pdSST-futArcSIC)
#folders+=(/projects/NS9034K/CMIP6/PAMIP/NCC/NorESM2-LM/pdSST-piAntSIC)
#folders+=(/projects/NS9034K/CMIP6/PAMIP/NCC/NorESM2-LM/pdSST-futAntSIC)

# OMIP
 #folders+=(/projects/NS9034K/CMIP6/OMIP/NCC/NorESM2-LM/omip1)
 #folders+=(/projects/NS9034K/CMIP6/OMIP/NCC/NorESM2-LM/omip2)

# CDRMIP
folders+=(/projects/NS9034K/CMIP6/CDRMIP/NCC/NorESM2-LM/1pctCO2-cdr)


pid=$$
for (( i = 0; i < ${#folders[*]}; i++ )); do
    folder=${folders[i]}
    cd "$folder"
    reals=($(find -maxdepth 1  -type d -name 'r*i*p*f*' -print |awk -F"/" '{print $NF}'|sort --version-sort ))
    #reals=(r2i1p1f1)
    #reals=(r3i1p1f1)
    for (( j = 0; j < ${#reals[*]}; j++ )); do
        real=${reals[j]}
        echo "Process $folder/$real"
        find $real/*/*/*/$Version -name *.nc -print 2>/dev/null 1>/tmp/flist.txt.$pid
        if [ $? -ne 0 ]
        then
            echo "WARNING: no file found under $folder/$real/*/*/*/$Version"
            echo "SKIP $real ..."
            continue
        fi

        if [ ! -z $OverWrite ] && [ "$OverWrite" == "TRUE" ]
        then
            rm -f ./.${real}.sha256sum_${Version}
        fi
        cp /tmp/flist.txt.$pid /tmp/flist2.txt.$pid
        touch .${real}.sha256sum_${Version}
        while read -r fname
        do
            bname=$(basename $fname)
            grep "${Version}\/${bname}" .${real}.sha256sum_${Version} >/dev/null 2>&1
            if [ $? -eq 0 ]
            then
                if [ $WriteMode == "replace" ]
                then
                    echo "replace ${Version}\/${bname}"
                    sed -i "/${Version}\/${bname}/d" .${real}.sha256sum_${Version}
                elif [ $WriteMode == "skip" ]
                then
                    echo "skip ${Version}\/${bname}"
                    sed -i "/$bname/d" /tmp/flist2.txt.$pid
                else
                    echo "ERROR: unknow WriteMode: $WriteMode"
                fi
            fi
        done </tmp/flist.txt.$pid

        k=1
        nf=$(cat /tmp/flist2.txt.$pid |wc -l)
        while read -r fname
        do
            bname=$(basename $fname)
            sha256sum $fname >>.${real}.sha256sum_${Version} &
            echo -ne "sha256sum: $k/$nf files\r"
            if [ $(($k%15)) -eq 0 ]; then
                wait
            fi
            let k+=1
        done </tmp/flist2.txt.$pid
        rm -f /tmp/flist.txt.$pid /tmp/flist2.txt.$pid
    done
done
echo -e "\rALL DONE"

