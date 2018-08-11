#!/bin/sh -e 

# determine location of noresm2cmor and cd to bin-dir 
CMORHOME=`dirname \`readlink -f $0\``/..
OUTPATH=$CMORHOME/data/cmorout/N20TRAERCN_f19_g16_01
mkdir -p $OUTPATH
cd $CMORHOME/bin 

# load modules required for running noresm2cmor on norstore
if [ `uname -n | grep norstore | wc -l` -gt 0 ]
then
  . /usr/share/Modules/init/sh
  module unload netcdf gcc hdf
  module load netcdf.intel/4.4.0 udunits/2.2.17 uuid/1.5.1
elif [ `uname -n | grep nird | wc -l` -gt 0 ]
then
  source /opt/intel/compilers_and_libraries/linux/bin/compilervars.sh -arch intel64 -platform linux
  ulimit -s unlimited
fi

# cmor-ize 
echo "Output written to ${OUTPATH}" 
echo "Log written to ${OUTPATH}/noresm2cmor.log"
./noresm2cmor ../namelists/noresm2cmor_CMIP5_NorESM1-M_historical_r1i1p1.nml  >& $OUTPATH/noresm2cmor.log

# change group permissions 
chmod g+w ${OUTPATH} ${OUTPATH}/*
