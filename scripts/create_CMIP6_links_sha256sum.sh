#!/bin/bash

# USAGE:   ./create_CMIP6_links_sha256sum.sh 
#       or ./create_CMIP6_links_sha256sum.sh  $VERSIOIN "data folders" true/false

# quit if in IPCC node
if [ $(hostname -f |grep 'ipcc') ]; then
    echo "                       "
    echo "On IPCC node, QUIT...  "
    echo "SHA256SUM NOT DONE     "
    echo "~~~~~~~~~~~~~~~~~~~~~~~"
fi

pid=$$

ROOT=/projects/NS9034K/CMIP6
cd $ROOT

# set data version
#VER=v20190815
#VER=v20190909
#VER=v20190917
#VER=v20190920
#VER=v20190920b
#VER=v20190920c
#VER=v20191009
#VER=v20191018
#VER=v20191022
VER=v20191108b

##Set Paths of Cmorized Data
# CMIP
#folders+=(.cmorout/NorESM2-LM/1pctCO2/${VER})
#folders+=(.cmorout/NorESM2-LM/abrupt-4xCO2/${VER})
#folders+=(.cmorout/NorESM2-LM/amip/${VER})
#folders+=(.cmorout/NorESM2-LM/esm-hist/${VER})
#folders+=(.cmorout/NorESM2-LM/esm-piControl/${VER})
#folders+=(.cmorout/NorESM2-LM/historical/${VER})
folders+=(.cmorout/NorESM2-LM/piControl/${VER})

# OMIP
#folders+=(.cmorout/NorESM2-LM/omip1/${VER})
#folders+=(.cmorout/NorESM2-LM/omip2/${VER})

# DAMIP
#folders+=(.cmorout/NorESM2-LM/hist-GHG/${VER})
#folders+=(.cmorout/NorESM2-LM/hist-nat/${VER})
#folders+=(.cmorout/NorESM2-LM/hist-aer/${VER})

# AerChemMIP
#folders+=(.cmorout/NorESM2-LM/hist-piAer/${VER})
#folders+=(.cmorout/NorESM2-LM/hist-piNTCF/${VER})
#folders+=(.cmorout/NorESM2-LM/histSST/${VER})
#folders+=(.cmorout/NorESM2-LM/histSST-piAer/${VER})
#folders+=(.cmorout/NorESM2-LM/histSST-piNTCF/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-2xDMS/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-2xVOC/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-2xdust/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-2xss/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-BC/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-CH4/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-N2O/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-OC/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-SO2/${VER})

# RFMIP
#folders+=(.cmorout/NorESM2-LM/hist-spAer-all/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-4xCO2/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-aer/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-anthro/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-control/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-ghg/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-histaer/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-histall/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-histghg/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-histnat/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-lu/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-spAer-aer/${VER})
#folders+=(.cmorout/NorESM2-LM/piClim-spAer-anthro/${VER})

# CDRMIP
#folders+=(.cmorout/NorESM2-LM/1pctCO2-cdr/${VER})

# PAMIP
#folders+=(.cmorout/NorESM2-LM/pdSST-futAntSIC/${VER})
#folders+=(.cmorout/NorESM2-LM/pdSST-futArcSIC/${VER})
#folders+=(.cmorout/NorESM2-LM/pdSST-pdSIC/${VER})
#folders+=(.cmorout/NorESM2-LM/pdSST-piAntSIC/${VER})
#folders+=(.cmorout/NorESM2-LM/pdSST-piArcSIC/${VER})
#folders+=(.cmorout/NorESM2-LM/piSST-pdSIC/${VER})

# PMIP
#folders+=(.cmorout/NorESM1-F/lig127k/${VER})
#folders+=(.cmorout/NorESM1-F/midHolocene/${VER})
#folders+=(.cmorout/NorESM1-F/midPliocene-eoi400/${VER})
#folders+=(.cmorout/NorESM1-F/piControl/${VER})

#~~~~~~~~~NO EDIT BELOW~~~~~~~~~~~

# If VERBOSE log
verbose=true

# Overwrite if external input
if [ $# -eq 3 ]
then
    VER=$1
    folders=($2)
    verbose=$3
fi

echo "~~~~~~~~~~~~~~~~"
echo "LINKING FILES..."
echo "                "

insitute=NCC
for (( i = 0; i < ${#folders[*]}; i++ )); do
    folder=${folders[i]}
    echo "$folder"

    find $folder -name *.nc -print 1>/tmp/flist.txt.$pid
    sort --version-sort /tmp/flist.txt.$pid -o /tmp/flist.txt.$pid

    # if no files found
    if [ $? -ne 0 ]
    then
        continue
    fi
    nf=$(cat /tmp/flist.txt.$pid |wc -l)
    echo "Total $nf files"
    fname1=$(head -1 /tmp/flist.txt.$pid) 
    version=$(echo $folder | awk -F/ '{print $(NF) }')
    version=${version:0:9}
    activity=$(cdo -s showattribute,activity_id $fname1 |grep 'activity_id' |cut -d'"' -f2)
    if [ "$activity" == "RFMIP AerChemMIP" ]
    then
        activity="RFMIP"
    elif [ "$activity" == "C4MIP CDRMIP" ]
    then
        activity="C4MIP"
    fi
    k=1

    fname=$(head -1 /tmp/flist.txt.$pid)
    bname=$(basename $fname .nc)
    fstr=($(echo $bname |tr "_" " "))
    model=${fstr[2]}
    expid=${fstr[3]}
    echo $activity/$insitute/$model/$expid  > "${folder}.links"

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
        echo "$real/$table/$var/$grid/$version/${bname}.nc" >> ${folder}.links
        if $verbose
        then
            echo -ne "Linking $k/$nf files\r"
        fi
        let k+=1
    done </tmp/flist.txt.$pid

done
echo -e "\r"
echo "                       "
echo "LINKS DONE             "
echo "~~~~~~~~~~~~~~~~~~~~~~~"

echo "                       "
echo "~~~~~~~~~~~~~~~~~~~~~~~"
echo "UPDATING SHA256SUM...  "
echo "                       "

cd $activity/$insitute/$model/$expid

reals=($(tail -n +2 ${ROOT}/${folder}.links |cut -d"/" -f1 |sort -u --version-sort))
for (( j = 0; j < ${#reals[*]}; j++ )); do
    real=${reals[j]}
    rm -f .${real}.sha256sum_${VER}
done

k=1
nf=$(tail -n +2 ${ROOT}/${folder}.links |wc -l)
echo "Total $nf files"
for fname in $(tail -n +2 ${ROOT}/${folder}.links)
    do
        real=$(echo $fname |cut -d"/" -f1)
        sha256sum $fname >>.${real}.sha256sum_${VER} &
        if $verbose
        then
            echo -ne "sha256sum: $k/$nf files\r"
        fi

        # keep maximumn 15 jobs
        flag=true
        while $flag ; do
            np=$(ps x |grep -c 'sha256sum')
            if [ $np -lt 17 ]; then
                flag=false
            else
                sleep 10s
            fi
        done
        #if [ $(($k%15)) -eq 0 ]; then
            #echo -ne "sha256sum: $k/$nf files\r"
            #wait
        #fi
        let k+=1
done
echo -e "\r"
echo "                       "
echo "SHA256SUM DONE         "
echo "~~~~~~~~~~~~~~~~~~~~~~~"
