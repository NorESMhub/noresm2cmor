#!/bin/bash

# Usage:
#       cmorParse.sh -m=[model] -e=[expid] -v=[version] -o=[cmoroutroot]

# --- Use input arguments if exits
if [ $# -ge 3 ]
then
     while test $# -gt 0; do
         case "$1" in
             -m=*)
                 model=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             -e=*)
                 expid=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             -v=*)
                 version=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             -o=*)
                 cmoroutroot=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             * )
                 echo "ERROR: option $1 not allowed."
                 echo "*** EXITING THE SCRIPT"
                 exit 1
                 ;;
         esac
    done
else
    echo "** NOT enough input, EXIT **"
    echo "Usage:"
    echo "  ./cmorParse.sh -m=[model] -e=[expid] -v=[version] -o=[cmoroutroot (optional)]"
    echo "  e.g., ./checkcmorout.sh -e=piControl -m=NorESM2-LM -v=v20210319 -o=/projects/NS9034K/CMIP6/.cmorout"
    exit
fi

opts=(model expid version)
for opt in ${opts[@]};do
    [ -z "${!opt}" ] && echo "$opt is not defined, EXIT" && exit
done
