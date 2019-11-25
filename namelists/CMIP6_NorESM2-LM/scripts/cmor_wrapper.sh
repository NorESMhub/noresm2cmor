#!/bin/bash
#set -e

# initialize
login0=false
login1=false
login2=false
login3=false
ipcc=false

# set active
#login0=true
#login1=true
#login2=true
#login3=true
ipcc=true

expids=()
versions=()
if $login0
then
# CMIP
#expids+=(1pctCO2)              ; versions+=(v20191108b)    # done
#expids+=(abrupt-4xCO2)         ; versions+=(v20191108b)    # done

# OMIP
#expids+=(omip1)                ; versions+=(v20191108b)    # done
#expids+=(omip2)                ; versions+=(v20191108b)    # done

## RFMIP
#expids+=(piClim-4xCO2)         ; versions+=(v20191108b)    # done
#expids+=(piClim-aer)           ; versions+=(v20191108b)    # done
#expids+=(piClim-anthro)        ; versions+=(v20191108b)    # done
#expids+=(piClim-ghg)           ; versions+=(v20191108b)    # done
expids+=(piClim-histaer)        ; versions+=(v20191108b)    # running
expids+=(piClim-control)        ; versions+=(v20191108b)    # no permission
expids+=(piClim-histall)        ; versions+=(v20191108b)    # 
expids+=(piClim-histghg)        ; versions+=(v20191108b)
expids+=(piClim-histnat)        ; versions+=(v20191108b)
expids+=(piClim-lu)             ; versions+=(v20191108b)
expids+=(piClim-spAer-aer)      ; versions+=(v20191108b)
expids+=(piClim-spAer-anthro)   ; versions+=(v20191108b)


#~~~~~~~~~~~~~~~~~
:
fi
#~~~~~~~~~~~~~~~~~

if $login1
then
# CMIP
#expids+=(amip)                 ; versions+=(v20191108b)    # done
#expids+=(esm-hist)             ; versions+=(v20191108b)    # done

## AerChemMIP
expids+=(hist-piAer)            ; versions+=(v20191108b)    # done
expids+=(hist-piNTCF)           ; versions+=(v20191108b)    # running
expids+=(histSST)               ; versions+=(v20191108b)
expids+=(histSST-piAer)         ; versions+=(v20191108b)
expids+=(histSST-piNTCF)        ; versions+=(v20191108b)
expids+=(piClim-2xDMS)          ; versions+=(v20191108b)
expids+=(piClim-2xVOC)          ; versions+=(v20191108b)
expids+=(piClim-2xdust)         ; versions+=(v20191108b)
expids+=(piClim-2xss)           ; versions+=(v20191108b)
expids+=(piClim-BC)             ; versions+=(v20191108b)
expids+=(piClim-CH4)            ; versions+=(v20191108b)
expids+=(piClim-N2O)            ; versions+=(v20191108b)
expids+=(piClim-OC)             ; versions+=(v20191108b)
expids+=(piClim-SO2)            ; versions+=(v20191108b)
#~~~~~~~~~~~~~~~~~
:
fi
#~~~~~~~~~~~~~~~~~

if $login2
then
# CMIP
#expids+=(esm-piControl)         ; versions+=(v20191108b)    # done
#expids+=(historical)            ; versions+=(v20191108b)    # done

## RFMIP
#expids+=(hist-spAer-all)        ; versions+=(v20191108b)    # done

# CDRMIP
#expids+=(esm-pi-cdr-pulse)      ; versions+=(v20191108)     # done
#expids+=(esm-pi-CO2pulse)       ; versions+=(v20191108)     # done
#~~~~~~~~~~~~~~~~~
:
fi
#~~~~~~~~~~~~~~~~~

if $login3
then
# CMIP
#expids+=(piControl)             ; versions+=(v20191108b)    # done

## PAMIP
#expids+=(pdSST-pdSIC)           ; versions+=(v20191108b)    # done
#expids+=(piSST-pdSIC)           ; versions+=(v20191108b)    # done
#expids+=(pdSST-futAntSIC)       ; versions+=(v20191108b)    # done
#expids+=(pdSST-futArcSIC)       ; versions+=(v20191108b)    # done
#expids+=(pdSST-piAntSIC)        ; versions+=(v20191108b)    # done
#expids+=(pdSST-piArcSIC)        ; versions+=(v20191108b)    # done

# CDRMIP
#expids+=(1pctCO2-cdr)           ; versions+=(v20191108b)    # wrong

## ScenarioMIP
expids+=(ssp126)                ; versions+=(v20191108)
expids+=(ssp245)                ; versions+=(v20191108)
expids+=(ssp370)                ; versions+=(v20191108)
expids+=(ssp585)                ; versions+=(v20191108)
#~~~~~~~~~~~~~~~~~
:
fi
#~~~~~~~~~~~~~~~~~

if $ipcc
then

## DAMIP
#expids+=(hist-GHG)              ; versions+=(v20191108)     # done
expids+=(hist-nat)             ; versions+=(v20191108)
expids+=(hist-aer)             ; versions+=(v20191108)
#~~~~~~~~~~~~~~~~~
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
nmlroot=${root}/noresm2cmor/namelists/CMIP6_NorESM2-LM

for (( i = 0; i < ${#expids[*]}; i++ )); do
    expid=${expids[i]}
    version=${versions[i]}
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

