#!/bin/bash

CMOR_ROOT=$(cd $(dirname $0) && cd ../../.. && pwd)
# parse input parameters
source $CMOR_ROOT/workflow/cmorParse.sh

years1+=($(seq 1600 10 1700))
years2+=($(seq 1609 10 1709))
years1+=(1701 $(seq 1710 10 1790) 1800)
years2+=(1709 $(seq 1719 10 1799) 1800)
years1+=($(seq 1801 10 1891))
years2+=($(seq 1810 10 1900))
years1+=($(seq 1901 10 1991))
years2+=($(seq 1910 10 2000))
years1+=($(seq 2001 10 2091))
years2+=($(seq 2010 10 2100))

years1=(1601 $(seq 1610 10 1890) 1900)
years2=(1609 $(seq 1619 10 1899) 1900)

${CMOR_ROOT}/workflow/cmorCheck.sh -v=$version -e=$expid -m=$model -o=$cmorout -yrs1="${years1[*]}" -yrs2="${years2[*]}"

