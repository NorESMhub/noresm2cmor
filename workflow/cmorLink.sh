#!/bin/bash
# link to DKRZ folder structure and calculate sha256sum

# quit if in IPCC node
#if [ $(hostname -f |grep 'ipcc') ]; then
    #echo "                       "
    #echo "On IPCC node!!!        "
    #echo "LINKS NOT DONE, EXIT..."
    #echo "~~~~~~~~~~~~~~~~~~~~~~~"
    #exit 1
#fi

if [ $# -eq 0 ] || [ $1 == "--help" ] 
then
    printf "Usage:\n"
    printf "./cmorLink.sh -m=[model] -e=[expid] -v=[version] --verbose=[true|false]"
    exit 1
else
    while test $# -gt 0; do
        case "$1" in
            -m=*)
                model=$(echo $1|sed -e 's/^[^=]*=//g')
                shift
                ;;
            -e=*)
                expid=$(echo $1|sed -e 's/^[^=]*=//g')
                shift
                ;;
            -v=*)
                tag=$(echo $1|sed -e 's/^[^=]*=//g')
                version=${tag:0:9}
                shift
                ;;
            --verbose=*)
                verbose=$(echo $1|sed -e 's/^[^=]*=//g')
                shift
                ;;
            * )
                echo "ERROR: option $1 not allowed."

                echo "*** EXITING THE SCRIPT"
                exit 1
                ;;
        esac
    done
fi
# check if variable defined
if [[ -z $model || -z $expid || -z $tag ]]; then
    echo 'ERROR:One or more variables $model $expid $tag are undefined'
    echo 'EXIT...'
    exit 1
fi
# set default 
if [ -z $verbose ]; then
    verbose=false
fi

echo "~~~~~~~~~~~~~~~~"
echo "LINKING FILES..."
echo "                "

pid=$$
folder=.cmorout/${model}/${expid}/${tag}
ROOT=/projects/NS9034K/CMIP6
cd $ROOT

echo "$folder"

find $folder -name *.nc -print 1>/tmp/flist.txt.$pid
sort --version-sort /tmp/flist.txt.$pid -o /tmp/flist.txt.$pid

# if no files found
if [ $? -ne 0 ]
then
    continue
fi

insitute=NCC

nf=$(cat /tmp/flist.txt.$pid |wc -l)
echo "Total $nf files"
fname1=$(head -1 /tmp/flist.txt.$pid) 
activity=$(cdo -s showattribute,activity_id $fname1 |grep 'activity_id' |cut -d'"' -f2)
if [ "$activity" == "RFMIP AerChemMIP" ]
then
    activity="RFMIP"
elif [ "$activity" == "C4MIP CDRMIP" ]
then
    activity="C4MIP"
elif [ "$activity" == "ScenarioMIP AerChemMIP" ]
then
    activity="ScenarioMIP"
fi

fname=$(head -1 /tmp/flist.txt.$pid)
bname=$(basename $fname .nc)
fstr=($(echo $bname |tr "_" " "))
model=${fstr[2]}
expid=${fstr[3]}
echo $activity/$insitute/$model/$expid  >${folder}.links

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
        mkdir -p "$subfolder" && chmod g+w $activity/$insitute/$model/$expid
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

echo -e "\r"
echo "                       "
echo "LINKS DONE             "
echo "~~~~~~~~~~~~~~~~~~~~~~~"
