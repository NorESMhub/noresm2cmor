#!/bin/bash
#set -x

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

expids=()
if $login0
then
# CMIP
expids+=(piControl)
expids+=(historical)
expids+=(abrupt-4xCO2)
expids+=(1pctCO2) 

#~~~~~~~~~~~~~~~~~
:
fi
#~~~~~~~~~~~~~~~~~

if $login1
then

#~~~~~~~~~~~~~~~~~
:
fi
#~~~~~~~~~~~~~~~~~

if $login2
then

#~~~~~~~~~~~~~~~~~
:
fi
#~~~~~~~~~~~~~~~~~

if $login3
then

#~~~~~~~~~~~~~~~~~
:
fi
#~~~~~~~~~~~~~~~~~


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# wait if already jobs in queue
flag=true
while $flag ; do
    ps x | grep -e "cmor_tmp\.sh" -e "cmor\.sh" >/dev/null
    if [ $? -eq 0 ]
    then
        sleep 10m
    else
        flag=false
    fi
done

if [ $(hostname -f |grep 'ipcc') ]
then
    root=/scratch/NS9034K
else
    root=~
fi
nmlroot=${root}/noresm2cmor/namelists/CMIP6_NorESM2-MM

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
    ./cmor.sh ${version} ${expid}  &> ./logs/cmor.log.${version}
    wait 
    cat  ./logs/cmor.log.${version} >>${root}/cmor.log.${version}
    echo "DONE                "
done

