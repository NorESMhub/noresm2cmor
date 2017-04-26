#!/bin/sh -e 

# determine location of noresm2cmor and cd to bin-dir 
CMORHOME=`dirname \`readlink -f $0\``/..
OUTPATH=$CMORHOME/data/cmorout/$USER/N20TRAERCN_f19_g16_01
mkdir -p $OUTPATH
cd $CMORHOME/bin 

# cmor-ize 
echo "Output written to ${OUTPATH}" 
echo "Log written to ${OUTPATH}/noresm2cmor.log"
./noresm2cmor ../namelists/noresm2cmor_CMIP5_NorESM1-M_historical_r1i1p1.nml  >& $OUTPATH/noresm2cmor.log

# change group permissions 
chmod g+w ${OUTPATH} ${OUTPATH}/*
