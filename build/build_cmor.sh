#!/usr/bin/env bash

#Makefile=Makefile_cmor3.nird_gnu
Makefile=Makefile_cmor3.nird_intel

######################################################
#           ** DONT MODIFY BELOW **
######################################################

load_module(){
  module purge
  module load GCCcore/13.2.0
  module load intel-compilers/2023.2.1
  module load HDF5/1.14.3-iompi-2023b
  module load UDUNITS/2.2.28-GCCcore-13.2.0
  module load expat/2.5.0-GCCcore-13.2.0
  module load json-c/0.17-GCCcore-13.2.0
  module load netCDF-Fortran/4.6.1-iompi-2023b
  module load netCDF/4.9.2-iompi-2023b
  module load util-linux/2.39-GCCcore-13.2.0
  module load zlib/1.2.13-GCCcore-13.2.0
}

load_module
make -f $Makefile
