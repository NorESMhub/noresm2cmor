#!/bin/sh -evx 

# IMPORTANT: Before running the script, change ibasedir and obasedir in namelist files. 
#            If obasedir does not exit, it needs to be created. 

# test cam 
../../bin/cam2cmor 

# test clm
../../bin/clm2cmor 

# test cice
../../bin/cice2cmor 

# test micom
../../bin/micom2cmor 

