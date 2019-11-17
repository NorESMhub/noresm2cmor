#!/bin/bash
#set -e

#version=v20191108b
version=v20191108
# initialize
login0=false
login1=false
login2=false
login3=false

# set active
login0=true
#login1=true
#login2=true
#login3=true

if $login0
then

## DAMIP
expids+=(hist-GHG)
#expids+=(hist-nat)
#expids+=(hist-aer)
#~~~~~~~~~~~~~~~~~
fi
#~~~~~~~~~~~~~~~~~

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if [ $(hostname -f |grep 'ipcc') ]
then
    root=/scratch/NS9034K
else
    root=~
fi
nmlroot=${root}/noresm2cmor/namelists/CMIP6_NorESM2-LM

for (( i = 0; i < ${#expids[*]}; i++ )); do
    expid=${expids[i]}
    echo "--------------------"
    echo "CMORING...          "
    echo "$expid              "
    echo "$version            "
    cd ${nmlroot}/${expid}
    if [ ! -d ./logs ]
    then
        mkdir ./logs 
    fi
    ./cmor.sh ${version}  &> ./logs/cmor.log.${version}
    wait 
    cat  ./logs/cmor.log.${version} >>${root}/cmor.log.${version}
    echo "DONE                "
done

