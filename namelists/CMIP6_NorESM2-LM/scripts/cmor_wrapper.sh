#!/bin/bash
#set -e

version=v20191108b
# initialize
login0=false
login1=false
login2=false
login3=false

# set active
#login0=true
login1=true
#login2=true
#login3=true

if $login0
then
# CMIP
#expids+=(1pctCO2)      # done
#expids+=(abrupt-4xCO2) # done

# OMIP
#expids+=(omip1)        # done
#expids+=(omip2)        # done

## DAMIP (not cmorized, since upcoming extension)
#expids+=(hist-GHG)
#expids+=(hist-nat)
#expids+=(hist-aer)
#~~~~~~~~~~~~~~~~~
:
fi
#~~~~~~~~~~~~~~~~~

if $login1
then
# CMIP
#expids+=(amip)          # done
#expids+=(esm-hist)      # done

## AerChemMIP
expids+=(hist-piAer)    # running
expids+=(hist-piNTCF)
expids+=(histSST)
expids+=(histSST-piAer)
expids+=(histSST-piNTCF)
expids+=(piClim-2xDMS)
expids+=(piClim-2xVOC)
expids+=(piClim-2xdust)
expids+=(piClim-2xss)
expids+=(piClim-BC)
expids+=(piClim-CH4)
expids+=(piClim-N2O)
expids+=(piClim-OC)
expids+=(piClim-SO2)
#~~~~~~~~~~~~~~~~~
:
fi
#~~~~~~~~~~~~~~~~~

if $login2
then
# CMIP
#expids+=(esm-piControl) # done
#expids+=(historical)    # running on login0

## RFMIP
expids+=(hist-spAer-all)
expids+=(piClim-4xCO2)
expids+=(piClim-aer)
expids+=(piClim-anthro)
expids+=(piClim-control)
expids+=(piClim-ghg)
expids+=(piClim-histaer)
expids+=(piClim-histall)
expids+=(piClim-histghg)
expids+=(piClim-histnat)
expids+=(piClim-lu)
expids+=(piClim-spAer-aer)
expids+=(piClim-spAer-anthro)
#~~~~~~~~~~~~~~~~~
:
fi
#~~~~~~~~~~~~~~~~~

if $login3
then
# CMIP
#expids+=(piControl) # running 

# CDRMIP
#expids+=(1pctCO2-cdr)   # wrong

## PAMIP
#expids+=(pdSST-pdSIC)      # done
#expids+=(piSST-pdSIC)      # done
#expids+=(pdSST-futAntSIC)  # done
#expids+=(pdSST-futArcSIC)  # done
#expids+=(pdSST-piAntSIC)   # done
#expids+=(pdSST-piArcSIC)   # done
#~~~~~~~~~~~~~~~~~
:
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

