#!/bin/bash

# --- set  running node ---
# initialize
#login1=false
#login2=false
#login3=false
#login4=false
#ipcc=false

# set active
#login1=true
#login2=true
#login3=true
#login4=true
#ipcc=true


# --- set expid, version, model ---
# initialize
expids=()
versions=()
models=()

NODE=$(echo $HOSTNAME |cut -d"-" -f1)

# --- BODY ---
case $NODE in
    "login1")
        # CMIP
        #expids+=(historical)           ; versions+=(v20200218)     ; models+=(NorESM2-LM)  # done
        #expids+=(ssp126)               ; versions+=(v20200218)     ; models+=(NorESM2-LM)  # done

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
        #expids+=(historical)           ; versions+=(v20191108)     ; models+=(NorESM2-MM)  # done
        #expids+=(abrupt-4xCO2)         ; versions+=(v20191108)     ; models+=(NorESM2-MM)  # done
        #expids+=(1pctCO2)              ; versions+=(v20191108)     ; models+=(NorESM2-MM)  # done
        ;;

    "login2")
        # CMIP
        #expids+=(ssp245)               ; versions+=(v20200218)     ; models+=(NorESM2-LM)  # done
         expids+=(ssp370)               ; versions+=(v20200218)     ; models+=(NorESM2-LM)  #
        #expids+=(ssp585)               ; versions+=(v20200218)     ; models+=(NorESM2-LM)  # done

        # CMIP
        #expids+=(amip)                 ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
        #expids+=(esm-hist)             ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done

        # CMIP
        #expids+=(piControl)            ; versions+=(v20191108)     ; models+=(NorESM2-MM)  # done
        #expids+=(ssp126)               ; versions+=(v20191108)     ; models+=(NorESM2-MM)  # done
        #expids+=(ssp245)               ; versions+=(v20191108)     ; models+=(NorESM2-MM)  # done
        ;;

    "login3")
        # CMIP
        #expids+=(amip)                 ; versions+=(v20200218)     ; models+=(NorESM2-LM)  # done
        #expids+=(esm-piControl)        ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
        #expids+=(historical)           ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
        #expids+=(abrupt-4xCO2)         ; versions+=(v20191108)     ; models+=(NorESM2-LM)  # done

        # CMIP
        #expids+=(amip)                 ; versions+=(v20200218)     ; models+=(NorESM2-MM)  # done

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
        #expids+=(piClim-histall)       ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
        #expids+=(piClim-histghg)       ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done

        # CMIP
        #expids+=(ssp370)               ; versions+=(v20191108)     ; models+=(NorESM2-MM)  # done
        #expids+=(ssp585)               ; versions+=(v20191108)     ; models+=(NorESM2-MM)  # done
        ;;

    "login4")
        # CMIP
        #expids+=(ssp126)               ; versions+=(v20200218)     ; models+=(NorESM2-MM)  # done
        #expids+=(ssp245)               ; versions+=(v20200218)     ; models+=(NorESM2-MM)  # done

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
        #expids+=(ssp126)               ; versions+=(v20191108)     ; models+=(NorESM2-LM)  # done
        #expids+=(ssp245)               ; versions+=(v20191108)     ; models+=(NorESM2-LM)  # done
        #expids+=(ssp370)               ; versions+=(v20191108)     ; models+=(NorESM2-LM)  # done
        #expids+=(ssp585)               ; versions+=(v20191108)     ; models+=(NorESM2-LM)  # done

        # PMIP
        #expids+=(midHolocene)          ; versions+=(v20191108)     ; models+=(NorESM2-LM)  # done
        ;;

    "ipcc")
        # CMIP
        #expids+=(ssp370)               ; versions+=(v20200218)     ; models+=(NorESM2-MM)  # done
        #expids+=(ssp585)               ; versions+=(v20200218)     ; models+=(NorESM2-MM)  # done

        ## DAMIP
        #expids+=(hist-GHG)             ; versions+=(v20191108)     ; models+=(NorESM2-LM)  # done
        #expids+=(hist-nat)              ; versions+=(v20191108b)   ; models+=(NorESM2-LM)  # done

        ## AerChemMIP
        #expids+=(hist-piAer)           ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
        #expids+=(hist-piNTCF)          ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
        #expids+=(histSST)              ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done 
        #expids+=(histSST-piAer)        ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
        #expids+=(histSST-piNTCF)       ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
        #expids+=(piClim-2xDMS)         ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
        #expids+=(piClim-2xVOC)         ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
        #expids+=(piClim-2xdust)        ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
        #expids+=(piClim-2xss)          ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
        #expids+=(piClim-BC)            ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
        #expids+=(piClim-CH4)           ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
        #expids+=(piClim-N2O)           ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
        #expids+=(piClim-OC)            ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
        #expids+=(piClim-SO2)           ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done

        ## AerChemMIP
        #expids+=(hist-aer)             ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done

        ## RFMIP
        #expids+=(piClim-lu)            ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
        #expids+=(piClim-histnat)       ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
        #expids+=(piClim-spAer-aer)     ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
        #expids+=(piClim-spAer-anthro)  ; versions+=(v20191108b)    ; models+=(NorESM2-LM)  # done
        ;;
    "*")
        echo "UNKNOWN LOGIN NODE"
        echo "EXIT..."
        exit 1
esac

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

CMOR_ROOT=$(cd $(dirname $0) && cd .. && pwd)
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

