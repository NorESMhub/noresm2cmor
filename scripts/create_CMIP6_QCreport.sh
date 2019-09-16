#!/bin/sh -e 

IPATH=$1
if [ ! $IPATH ] || [ ! -d $IPATH ]
then 
  echo "Usage: $0 <path to folder with netcdf files>" 
  exit
fi 


export PATH=/opt/anaconda3/bin:${PATH}
source activate /projects/NS9560K/cmor/PrePARE
export CMIP6_CMOR_TABLES=/projects/NS9560K/cmor/noresm2cmor/tables


REPORT=`dirname $IPATH`/`basename $IPATH`.QCreport 
echo "QC report written to $REPORT" 
PrePARE $IPATH > $REPORT
echo COMPLETE 
