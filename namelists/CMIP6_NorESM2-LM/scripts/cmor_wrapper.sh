#!/bin/bash
#set -e

version=v20191108b
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
#expids+=(1pctCO2)      # done
#expids+=(abrupt-4xCO2) # done

# OMIP
#expids+=(omip1)        # done
#expids+=(omip2)        # done

## RFMIP
#expids+=(piClim-4xCO2)  # done
#expids+=(piClim-aer)    # done
#expids+=(piClim-anthro) # done
expids+=(piClim-control) # no permission
#expids+=(piClim-ghg)    # done
expids+=(piClim-histaer) # running
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

if $login1
then
# CMIP
#expids+=(amip)          # done
#expids+=(esm-hist)      # done

## AerChemMIP
expids+=(hist-piAer)    # r3 missing, running
expids+=(hist-piNTCF)   # running
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
#expids+=(historical)    # done

## RFMIP
expids+=(hist-spAer-all)    # running
#~~~~~~~~~~~~~~~~~
:
fi
#~~~~~~~~~~~~~~~~~

if $login3
then
# CMIP
expids+=(piControl) # running 

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

