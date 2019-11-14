#!/bin/bash
#set -ex

expids=(lig127k  midHolocene  midPliocene-eoi400  piControl)

for (( i=0; i<${#expids[*]}; i++ ))
do
    expid=${expids[i]}
    echo $expid
    if [ ! -d ../${expid}/v20191108b ]
    then
        mkdir ../${expid}/v20191108b
    fi
    cp ../../var_nml_diff/var_CMIP6_NorESM2_default_diff.nml ../${expid}/v20191108b/var.nml
done
