#!/bin/bash
#set -ex

if [ $# -gt 0 ] && [ $1 == "--help" ] 
then
    printf "Usage:\n"
    printf "create_CMIP6_sha256sum.sh -e [path_to_experiment] -v [data_version] -O [TRUE]\n"
    printf "\t Command line options:\n"
    printf "\t -e, --exp=path_to_experiment     :specify path to the data [optional];\n"
    printf "\t -v, --version=vyyyymmdd          :speicify variable version [optional];\n"
    printf "\t -O, --overwrite=TRUE             :specify if overwrite existed sha256sum file [optional];\n"
    exit 1
else
    while test $# -gt 0; do
        case "$1" in
            -e )
                shift
                if test $# -gt 0; then
                    folders=($1)
                else
                    echo "ERROR: no experiment path specified (-e, --exp=)"
                    echo "*** EXITING THE SCRIPT"
                    exit 1
                fi
                shift
                ;;
            --exp=* )
                folders=($(echo $1|sed -e 's/^[^=]*=//g'))
                shift
                ;;
            -v )
                shift
                if test $# -gt 0; then
                    version=$(echo $1 | sed 's/,/ /g')
                else
                    echo "ERROR: no version specified (-v, --version=)"
                    echo "*** EXITING THE SCRIPT"
                    exit 1
                fi
                shift
                ;;
            --version=* )
                version=$(echo $1|sed -e 's/^[^=]*=//g'|sed 's/,/ /g')
                shift
                ;;
            -O )
                shift
                if test $# -gt 0; then
                    OverWrite=$(echo $1 | sed 's/,/ /g')
                else
                    echo "ERROR: no overwrite flag specified (-O, --overwrite=TRUE)"
                    echo "*** EXITING THE SCRIPT"
                    exit 1
                fi
                shift
                ;;
            --overwrite=* )
                version=($(echo $1|sed -e 's/^[^=]*=//g'|sed 's/,/ /g'))
                shift
                ;;
            * )
                echo "ERROR: option $1 not allowed."

                echo "*** EXITING THE SCRIPT"
                exit 1
                ;;
        esac
    done
fi

if [ -z "${folders[*]}" ]
then
    #folders+=(/projects/NS9034K/CMIP6/AerChemMIP/NCC/NorESM2-LM/hist-piAer)
    #folders+=(/projects/NS9034K/CMIP6/AerChemMIP/NCC/NorESM2-LM/hist-piNTCF)
    #folders+=(/projects/NS9034K/CMIP6/AerChemMIP/NCC/NorESM2-LM/piClim-BC)
    #folders+=(/projects/NS9034K/CMIP6/AerChemMIP/NCC/NorESM2-LM/piClim-OC)
    #folders+=(/projects/NS9034K/CMIP6/AerChemMIP/NCC/NorESM2-LM/piClim-SO2)
    #folders+=(/projects/NS9034K/CMIP6/CMIP/NCC/NorESM2-LM/1pctCO2)
    #folders+=(/projects/NS9034K/CMIP6/CMIP/NCC/NorESM2-LM/abrupt-4xCO2)
    #folders+=(/projects/NS9034K/CMIP6/CMIP/NCC/NorESM2-LM/historical)
    #folders+=(/projects/NS9034K/CMIP6/CMIP/NCC/NorESM2-LM/piControl)
    #folders+=(/projects/NS9034K/CMIP6/DAMIP/NCC/NorESM2-LM/hist-GHG)
    #folders+=(/projects/NS9034K/CMIP6/RFMIP/NCC/NorESM2-LM/piClim-4xCO2)
    #folders+=(/projects/NS9034K/CMIP6/RFMIP/NCC/NorESM2-LM/piClim-ghg)
    #folders+=(/projects/NS9034K/CMIP6/RFMIP/NCC/NorESM2-LM/piClim-lu)
    #folders+=(/projects/NS9034K/CMIP6/RFMIP/NCC/NorESM2-LM/piClim-aer)
    #folders+=(/projects/NS9034K/CMIP6/RFMIP/NCC/NorESM2-LM/piClim-control)
    #folders+=(/projects/NS9034K/CMIP6/PAMIP/NCC/NorESM2-LM/pdSST-pdSIC)
    #folders+=(/projects/NS9034K/CMIP6/PAMIP/NCC/NorESM2-LM/pdSST-futArcSIC)
    #folders+=(/projects/NS9034K/CMIP6/OMIP/NCC/NorESM2-LM/omip1)
    #folders+=(/projects/NS9034K/CMIP6/OMIP/NCC/NorESM2-LM/omip2)
    #folders+=(/projects/NS9034K/CMIP6/RFMIP/NCC/NorESM2-LM/piClim-spAer-aer)
    folders+=(/projects/NS9034K/CMIP6/CMIP/NCC/NorESM2-LM/esm-hist)
fi
if [ -z "$version" ]
then
    #Version=v20190815
    #Version=v20190909
    #Version=v20190917
    Version=v20190920
fi

pid=$$
for (( i = 0; i < ${#folders[*]}; i++ )); do
    folder=${folders[i]}
    cd "$folder"
    reals=($(find -maxdepth 1  -type d -name 'r*i*p*f*' -print |awk -F"/" '{print $NF}' ))
    for (( j = 0; j < ${#reals[*]}; j++ )); do
        real=${reals[j]}
        echo "Process $folder/$real"
        if [ ! -z $OverWrite ] && [ "$OverWrite" == "TRUE" ]
        then
            rm -f ./.${real}.sha256sum
        fi
        k=1
        find $real/*/*/*/$Version -name *.nc -print 2>/dev/null 1>/tmp/flist.txt.$pid
        if [ $? -ne 0 ]
        then
            echo "ERROR: no file found under $folder/$real/*/*/*/$Version"
            echo "EXIT..."
            exit 1
        fi
        while read -r fname
        do
            name=$(basename $fname)
            grep "${Version}\/${bname}" .${real}.sha256sum >/dev/null 2>&1
            if [ $? -eq 0 ]
            then
                sed -i "/${Version}\/${bname}/d" .${real}.sha256sum
            fi
            sha256sum $fname &>>.${real}.sha256sum &
            while [ $k -gt 15 ]; do
                wait
                let k=1
            done
            let k+=1
        done </tmp/flist.txt.$pid
        rm -f /tmp/flist.txt.$pid
    done
done
echo "ALL DONE"

