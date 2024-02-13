#!/bin/bash

CMOR_ROOT=$(cd $(dirname $0) && cd ../../.. && pwd)
# parse input parameters
source $CMOR_ROOT/workflow/cmorParse.sh

years1=(1850 $(seq 1860 10 1980) 1990)
years2=(1859 $(seq 1869 10 1989) 1999)

echo cmorout: $cmorout


${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -o=$cmoroutroot -yrs1="${years1[*]}" -yrs2="${years2[*]}"

