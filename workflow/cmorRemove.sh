#!/bin/bash
# Find datasets of high frequency that is small than certain size (potenally wrong)

dataroot=/projects/NS9034K/CMIP6
models=(NorESM2-LM NorESM2-MM)
for model in ${models[*]}
do
    # find files smaller than 40M (an empirical number)
    cd $dataroot/.cmorout/${model}

    # remove retracted data
    rm -f /tmp/removed_{files,links}_${model}.txt
    while read -r dataset
    do
        #file=$(echo $dataset |awk -F" " '{print $NF}')
        #filename=$(basename $file)
        expid=$(echo $dataset   |cut -d" " -f1)
        version=$(echo $dataset |cut -d" " -f2)
        real=$(echo $dataset    |cut -d" " -f3)
        table=$(echo $dataset   |cut -d" " -f4)
        var=$(echo $dataset     |cut -d" " -f5)
        activity=$(dirname $dataroot/*/NCC/${model}/${expid}|cut -d"/" -f5)
        #echo $activity $expid $real $table $var $version
        [ ! -d $dataroot/.cmorout/$model/$expid/RETRACTED ] && mkdir $dataroot/.cmorout/$model/$expid/RETRACTED
        ls $dataroot/.cmorout/$model/$expid/$version/${var}_${table}_*_${real}_*.nc >>/tmp/removed_files_${model}.txt
        ls $dataroot/$activity/NCC/${model}/${expid}/$real/$table/$var/*/${version:0:9}/${var}_${table}_*_${real}_*.nc >>/tmp/removed_links_${model}.txt
        #rm -vf $dataroot/.cmorout/$model/$expid/$version/$filename \
            #>>$dataroot/.cmorout/$model/$expid/RETRACTED/removed_files.txt
        #rm -vf $dataroot/$activity/NCC/${model}/${expid}/$real/$table/$var/*/${version:0:9}/$filename \
            #>>$dataroot/.cmorout/$model/$expid/RETRACTED/removed_links.txt
    done </tmp/dataset_${model}.txt

    # final info
    echo "~~~~~~~~~"
    echo "removed data files:"
    echo "  $dataroot/.cmorout/$model/$expid/RETRACTED/removed_files.txt"
    echo "  (/tmp/removed_files_${model}.txt)"
    echo "removed data links:"
    echo "  $dataroot/.cmorout/$model/$expid/RETRACTED/removed_links.txt"
    echo "  (/tmp/removed_links_${model}.txt)"
    echo "~~~~~~~~~"
done

