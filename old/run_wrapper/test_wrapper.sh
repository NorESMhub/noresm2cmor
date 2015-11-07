#!/bin/sh -evx 

# path etc 
CNAME=N20TRAERCN_f19_g16_01
IBASE=/scratch/ingo/outputsample
OBASE=/scratch/ingo/cmor_advanced

# create output directory 
mkdir -p $OBASE

# test cam 
../script/cam2cmor.sh $CNAME historical 0 9999 ALL ALL $IBASE $OBASE  

# test clm
../script/clm2cmor.sh $CNAME historical 0 9999 ALL ALL $IBASE $OBASE  

# test cice 
../script/cice2cmor.sh $CNAME historical 0 9999 ALL ALL $IBASE $OBASE  

# test micom
../script/micom2cmor.sh $CNAME historical 0 9999 ALL ALL $IBASE $OBASE  

