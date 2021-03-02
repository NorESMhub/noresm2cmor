#!/bin/bash

if [ $# -eq 0 ] || [ $1 == "--help" ] 
 then
     printf "Usage:\n"
     printf "cmorRetract -m=[model] -e=[expid] --oldversions=['version1 version2 (optional)'] --newversion=[newversion]"
     exit
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
             --oldversions=*)
                 oldversions=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             --newversion=*)
                 newversion=$(echo $1|sed -e 's/^[^=]*=//g')
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

opts=(model expid newversion)
for opt in ${opts[@]};do
    [ -z "${!opt}" ] && echo "$opt is not defined, EXIT" && exit
done

datapath=/projects/NS9034K/CMIP6/.cmorout/${model}/${expid}
activity=$(dirname /projects/NS9034K/CMIP6/*/NCC/${model}/${expid}|cut -d"/" -f5)
linkpath=/projects/NS9034K/CMIP6/${activity}/NCC/${model}/${expid}
# make folders and move old files to RETRACTED FOLDER
mkdir ${datapath}/{$newversion,RETRACTED}
mkdir ${linkpath}/RETRACTED

if [ -z ${oldversions} ];then
    # if not specified, find all data versions
    oldversions=$(find ${datapath} -maxdepth 1 -name 'v20*' -type d -print |awk -F/ '{print $NF}'|sed "/${newversion}/d" |sort)
fi

printf "%-15s:%s\n" model $model
printf "%-15s:%s\n" expid $expid
printf "%-15s:" oldversions
printf "%-11s" ${oldversions[*]}
printf "\n"
printf "%-15s:%s\n" newversion $newversion

# move all data to newversion folder
echo "Moving:"
for version in ${oldversions[@]}
do
    echo "$version"
    find ${datapath}/${version} -name "*.nc" -type f -exec mv -t ${datapath}/${newversion}/ {} +
    rmdir ${datapath}/${version}
    mv ${linkpath}/{.*.map_$version,.*.sha256sum_$version} ${linkpath}/RETRACTED/
    mv $datapath/{${version}.links,${version}.QCreport*} ${datapath}/RETRACTED/
done

rename ".r" "r" ${linkpath}/RETRACTED/.*.*

# remove old links
#rm -rf /projects/NS9034K/CMIP6/${activity}/NCC/${model}/${expid}/r?i?p?f?/
find /projects/NS9034K/CMIP6/${activity}/NCC/${model}/${expid}/r?i?p?f? -xtype l -delete
find /projects/NS9034K/CMIP6/${activity}/NCC/${model}/${expid}/r?i?p?f? -empty -delete

# redo post-prepparation
cmorPost.sh -m=$model -e=$expid -v=$newversion --verbose=false --errexit=false

echo "cmorRetract for $model $expid done!"
