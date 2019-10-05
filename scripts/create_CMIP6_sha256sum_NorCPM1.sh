#!/bin/bash
set -evx

Version=v20190914

# CAUTIOUS: if overwrite the sha256sum file? default is false
OverWrite=FALSE
#OverWrite=TRUE

#tree -f -L 4 /projects/NS9034K/CMIP6/ESGF

#folders+=(/projects/NS9034K/CMIP6/CMIP/NCC/NorCPM1/piControl)
#folders+=(/projects/NS9034K/CMIP6/DCPP/NCC/NorCPM1/dcppA-assim)
#folders+=(/projects/NS9034K/CMIP6/CMIP/NCC/NorCPM1/historical)
folders+=(/projects/NS9034K/CMIP6/DCPP/NCC/NorCPM1/dcppA-hindcast)

IREGEX='2'

pid=$$
for (( i = 0; i < ${#folders[*]}; i++ )); do
    folder=${folders[i]}
    cd "$folder"
    reals=($(find -maxdepth 1  -type d -name "s????-r*i${IREGEX}p*" -print))
    #reals=($(find -maxdepth 1  -type d -name "r*i${IREGEX}p*" -print))
    for (( j = 0; j < ${#reals[*]}; j++ )); do
        real=$(basename ${reals[j]})
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
