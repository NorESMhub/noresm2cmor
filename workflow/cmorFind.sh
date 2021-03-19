#!/bin/bash
# Find datasets of high frequency that is small than certain size (potenally wrong)

dataroot=/projects/NS9034K/CMIP6
models=(NorESM2-LM NorESM2-MM)
for model in ${models[*]}
do
    # find files smaller than 40M (an empirical number)
    cd $dataroot/.cmorout/${model}
    #find ./ -type f \( -name "*_6hr*.nc" -or -name "*3hr*.nc" \) -size -40M | \
        #cut -d"_" -f1-2,5 |sort -u >/tmp/files_${model}.txt
    find ./ -type f -name "*_6hr*.nc" -size -40M -exec ls -lh {} \; \
        >/tmp/files_${model}.txt
    sed -i 's+\./++g' /tmp/files_${model}.txt

    # format as: expid table var
    rm -f /tmp/dataset_${model}.txt
    while read -r dataset
    do
        file=$(echo $dataset |awk -F" " '{print $NF}')
        expid=$(echo $file  |cut -d"/" -f1)
        version=$(echo $file|cut -d"/" -f2)
        table=$(echo $file  |cut -d"_" -f2)
        var=$(echo $file    |cut -d"/" -f3|cut -d"_" -f1)
        real=$(echo $file   |cut -d"/" -f3 |cut -d"_" -f5)
        echo $expid $version $real $table $var >>/tmp/dataset_${model}.txt
    done </tmp/files_${model}.txt
    export LC_ALL=C # set traditional sortting
    sort -u /tmp/dataset_${model}.txt >/tmp/tmp.txt
    mv /tmp/tmp.txt /tmp/dataset_${model}.txt

    # print in format as: expid table var1 var2 ... varn
    rm -f /tmp/datalist_${model}.txt
    expid0=''
    version0=''
    real0=''
    table0=''
    while read -r dataset
    do
        read -r expid1 version1 real1 table1 var <<<$(echo $dataset |cut -d" " -f1-5)
        if [ "$expid1" != "$expid0" ] || [ $real1 != $real0 ] || [ "$table1" != "$table0" ]
        then
            printf "\n" |tee -a /tmp/datalist_${model}.txt
            printf "%-15s|%-10s|%-10s|%-10s|" $expid1 $real1 $table1 $version1 |tee -a /tmp/datalist_${model}.txt
        fi
        printf "%-10s|" $var |tee -a /tmp/datalist_${model}.txt
        expid0=$expid1
        real0=$real1
        table0=$table1
        version0=$version1
    done </tmp/dataset_${model}.txt
    printf "\n\n" |tee -a /tmp/datalist_${model}.txt

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
    echo "full data files:"
    echo "  /tmp/files_${model}.txt"
    echo "full data sets:"
    echo "  /tmp/datalist_${model}.txt"
    echo "~~~~~~~~~"
done

