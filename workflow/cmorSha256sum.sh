#!/bin/bash
# link to DKRZ folder structure and calculate sha256sum

# quit if in IPCC node
if [ $(hostname -f |grep 'ipcc') ]; then
    echo "                       "
    echo "On IPCC node!!!        "
    echo "SHA256sum NOT DONE, EXIT..."
    echo "~~~~~~~~~~~~~~~~~~~~~~~"
    exit 1
fi

if [ $# -eq 0 ] || [ $1 == "--help" ] 
then
    printf "Usage:\n"
    printf "./cmorSha256sum.sh -m=[model] -e=[expid] -v=[version] --verbose=[true|false]"
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

echo "                       "
echo "~~~~~~~~~~~~~~~~~~~~~~~"
echo "UPDATING SHA256SUM...  "
echo "                       "

pid=$$
CMIP6root=/projects/NS9034K/CMIP6
folder=.cmorout/${model}/${expid}/${tag}
cd $CMIP6root

echo "$folder"

insitute=NCC

if [ ! -f ${CMIP6root}/${folder}.links ]
then
    echo "                       "
    echo "ERROR: ${CMIP6root}/${folder}.links does not exits."
    echo "EXIT...                "
    exit 1
fi

DKRZ=$(awk 'NR==1' ${CMIP6root}/${folder}.links)
fname1=$(awk 'NR==2' ${CMIP6root}/${folder}.links)
activity=$(cdo -s showattribute,activity_id ${CMIP6root}/${DKRZ}/$fname1 |grep 'activity_id' |cut -d'"' -f2)
if [ "$activity" == "RFMIP AerChemMIP" ]
then
    activity="RFMIP"
elif [ "$activity" == "C4MIP CDRMIP" ]
then
    activity="C4MIP"
elif [ "$activity" == "ScenarioMIP AerChemMIP" ]
then
    activity="ScenarioMIP"
else
    :
fi

cd $activity/$insitute/$model/$expid

reals=($(tail -n +2 ${CMIP6root}/${folder}.links |cut -d"/" -f1 |sort -u --version-sort))
for (( j = 0; j < ${#reals[*]}; j++ )); do
    real=${reals[j]}
    rm -f .${real}.sha256sum_${tag}
done

k=1
nf=$(tail -n +2 ${CMIP6root}/${folder}.links |wc -l)
echo "Total $nf files"
for fname in $(tail -n +2 ${CMIP6root}/${folder}.links)
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
