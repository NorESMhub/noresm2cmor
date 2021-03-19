#!/bin/bash

cd /projects/NS9034K/CMIP6/.cmorout/NorESM2-LM/piClim-histnat
for version in v20190920 v20200218 v20200702 v20191108b
do
    echo $version
    for fname in $(tail -n +2 ${version}.links |cut -d"/" -f6)
    do
        mv v20210118/$fname $version/ 2>/dev/null
    done
done
