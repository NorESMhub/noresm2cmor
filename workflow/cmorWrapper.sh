#!/bin/bash

# --- set  running node ---
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
login3=true
#ipcc=true

# --- set expid, version, model ---
# initialize
expids=()
versions=()
models=()

if $login0
then
# CMIP
#expids+=(1pctCO2)              ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
#expids+=(abrupt-4xCO2)         ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done

# CMIP
#expids+=(piControl)            ; versions+=(v20191108b)    ; models+=(NorESM1-F)   # done

# PMIP
#expids+=(lig127k)              ; versions+=(v20191108b)    ; models+=(NorESM1-F)   # done
#expids+=(midHolocene)          ; versions+=(v20191108b)    ; models+=(NorESM1-F)   # done
#expids+=(midPliocene-eoi400)   ; versions+=(v20191108b)    ; models+=(NorESM1-F)   # done

# OMIP
#expids+=(omip1)                ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
#expids+=(omip2)                ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done

# CMIP
#expids+=(historical)           ; versions+=(v20191108)     ; models+=(NorESM2-MM)  # missing years, running again
 expids+=(abrupt-4xCO2)         ; versions+=(v20191108)     ; models+=(NorESM2-MM)  # queue
 expids+=(1pctCO2)              ; versions+=(v20191108)     ; models+=(NorESM2-MM)  # queue

#~~~~~~~~~~~~~~~~~
:
fi
#~~~~~~~~~~~~~~~~~

if $login1
then
# CMIP
#expids+=(amip)                 ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
#expids+=(esm-hist)             ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done

# CMIP
#expids+=(piControl)            ; versions+=(v20191108)     ; models+=(NorESM2-MM)  # missing years, running again
 expids+=(ssp126)               ; versions+=(v20191108)     ; models+=(NorESM2-MM)  # error
 expids+=(ssp245)               ; versions+=(v20191108)     ; models+=(NorESM2-MM)  # error

#~~~~~~~~~~~~~~~~~
:
fi
#~~~~~~~~~~~~~~~~~

if $login2
then
# CMIP
#expids+=(esm-piControl)        ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
#expids+=(historical)           ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done

# RFMIP
#expids+=(hist-spAer-all)       ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done

# CDRMIP
#expids+=(esm-pi-cdr-pulse)     ; versions+=(v20191108)     ; models+=(NorESM2-LM)  # done
#expids+=(esm-pi-CO2pulse)      ; versions+=(v20191108)     ; models+=(NorESM2-LM)  # done

# RFMIP
#expids+=(piClim-4xCO2)         ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
#expids+=(piClim-aer)           ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
#expids+=(piClim-anthro)        ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
#expids+=(piClim-ghg)           ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
#expids+=(piClim-histaer)       ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
#expids+=(piClim-control)       ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
#expids+=(piClim-histall)       ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # missing, running again
#expids+=(piClim-histghg)       ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # missing 1950-2010,running

 # CMIP
 expids+=(ssp370)               ; versions+=(v20191108)     ; models+=(NorESM2-MM)
 expids+=(ssp585)               ; versions+=(v20191108)     ; models+=(NorESM2-MM)


#~~~~~~~~~~~~~~~~~
:
fi
#~~~~~~~~~~~~~~~~~

if $login3
then
# CMIP
#expids+=(piControl)            ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done

## PAMIP
#expids+=(pdSST-pdSIC)          ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
#expids+=(piSST-pdSIC)          ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
#expids+=(pdSST-futAntSIC)      ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
#expids+=(pdSST-futArcSIC)      ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
#expids+=(pdSST-piAntSIC)       ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
#expids+=(pdSST-piArcSIC)       ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done

# CDRMIP
#expids+=(1pctCO2-cdr)          ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done

## ScenarioMIP
# on FRAM
 expids+=(ssp126)               ; versions+=(v20191108)     ; models+=(NorESM2-LM)  # HDF error,31,51,61,81, run twice, queue
 expids+=(ssp245)               ; versions+=(v20191108)     ; models+=(NorESM2-LM)  # HDF error,runned twice, queue
 expids+=(ssp370)               ; versions+=(v20191108)     ; models+=(NorESM2-LM)  # wrong, empty fnm list, queue
 expids+=(ssp585)               ; versions+=(v20191108)     ; models+=(NorESM2-LM)  # HDF error,invalid pointer, queue

#~~~~~~~~~~~~~~~~~
:
fi
#~~~~~~~~~~~~~~~~~

if $ipcc
then

## DAMIP
#expids+=(hist-GHG)             ; versions+=(v20191108)     ; models+=(NorESM2-LM)  # done
#expids+=(hist-nat)              ; versions+=(v20191108b)   ; models+=(NorESM2-LM)  # finished

## AerChemMIP
#expids+=(hist-piAer)           ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
#expids+=(hist-piNTCF)          ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
#expids+=(histSST)              ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done 
#expids+=(histSST-piAer)        ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
#expids+=(histSST-piNTCF)       ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # finished
#expids+=(piClim-2xDMS)         ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # finished
#expids+=(piClim-2xVOC)         ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # finished
#expids+=(piClim-2xdust)        ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # finished
#expids+=(piClim-2xss)          ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # finished
#expids+=(piClim-BC)            ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # finished
#expids+=(piClim-CH4)           ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # finished
#expids+=(piClim-N2O)           ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # finished
#expids+=(piClim-OC)            ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # finished
#expids+=(piClim-SO2)           ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # finished

## AerChemMIP
#expids+=(hist-aer)             ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # running

## RFMIP
#expids+=(piClim-lu)            ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # running
 expids+=(piClim-histnat)       ; versions+=(v20191108b)    ; models+=(NorESM2-LM)
 expids+=(piClim-spAer-aer)     ; versions+=(v20191108b)    ; models+=(NorESM2-LM)
 expids+=(piClim-spAer-anthro)  ; versions+=(v20191108b)    ; models+=(NorESM2-LM)
#~~~~~~~~~~~~~~~~~
fi
#~~~~~~~~~~~~~~~~~


# --- wait if already jobs in queue ---
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

for (( i = 0; i < ${#expids[*]}; i++ )); do
    expid=${expids[i]}
    version=${versions[i]}
    model=${models[i]}

    echo "--------------------"
    echo "CMORING...          "
    echo "$expid              "
    echo "$version            "
    cd ${CMOR_ROOT}/namelists/CMIP6_${model}/${expid}
    
    if [ ! -d ./logs ]
    then
        mkdir ./logs 
    fi
    ./cmor.sh -m=${model} -e=${expid} -v=${version}  &>./logs/cmor.log.${version}
    wait 
    echo "DONE                "
done

