#!/bin/bash

CMOR_ROOT=$(cd $(dirname $0) && cd ../../.. && pwd)
# parse input parameters
source $CMOR_ROOT/workflow/cmorParse.sh

opts=(model expid version)
for opt in ${opts[@]};do
    [ -z "${!opt}" ] && echo "$opt is not defined, EXIT" && exit
done
years1=(0  $(seq 1  10 21))
years2=(10 $(seq 10 10 30))

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -o=$cmorout -yrs1="${years1[*]}" -yrs2="${years2[*]}"

