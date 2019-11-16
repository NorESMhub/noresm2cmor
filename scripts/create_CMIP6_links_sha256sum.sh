#!/bin/bash
# link to DKRZ folder structure and calculate sha256sum

if [ $# -eq 0 ] || [ $1 == "--help" ] 
then
    printf "Usage:\n"
    printf "./create_CMIP6_links_sha256sum.sh -m=[model] -e=[expid] -v=[version] --verbose=[true|false]"
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

# quit if in IPCC node
if [ $(hostname -f |grep 'ipcc') ]; then
    echo "                       "
    echo "On IPCC node, QUIT...  "
    echo "SHA256SUM NOT DONE     "
    echo "~~~~~~~~~~~~~~~~~~~~~~~"
    exit 1
fi

pid=$$

ROOT=/projects/NS9034K/CMIP6
cd $ROOT

folder=.cmorout/${model}/${expid}/${tag}

echo "~~~~~~~~~~~~~~~~"
echo "LINKING FILES..."
echo "                "

insitute=NCC
#for (( i = 0; i < ${#folders[*]}; i++ )); do
    #folder=${folders[i]}
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
    version=${tag:0:9}
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

#done
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
    rm -f .${real}.sha256sum_${tag}
done

k=1
nf=$(tail -n +2 ${ROOT}/${folder}.links |wc -l)
echo "Total $nf files"
for fname in $(tail -n +2 ${ROOT}/${folder}.links)
    do
        real=$(echo $fname |cut -d"/" -f1)
        sha256sum $fname >>.${real}.sha256sum_${tag} &
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
