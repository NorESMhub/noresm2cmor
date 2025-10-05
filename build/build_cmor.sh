#!/usr/bin/env bash

if [ $# -eq 0 ] || [ $1 == "-h" ]; then
  echo "Usage:"
  echo "./build_cmor.sh --ifmpi=true|false --compiler=intel|gnu"
  echo "Example:"
  echo "./build_cmor.sh --ifmpi=false --compiler=intel"
  exit
else
  while test $# -gt 0; do
    case "$1" in
      --ifmpi=*)
        mpi_flag=$(echo $1 | sed -e 's/^[^=]*=//g')
        [[ ${mpi_flag} != "true" && ${mpi_flag} != "false" ]] && echo "'ifmpi' flag must be either 'true' or 'false'" && exit 1
        shift
        ;;
      --compiler=*)
        compiler=$(echo $1 | sed -e 's/^[^=]*=//g')
        [[ $compiler != "intel" && $compiler != "gnu" ]] && echo "'compiler' must be either 'intel' or 'gnu'" && exit 1
        shift
        ;;
      *)
        echo "ERROR: option $1 not recognised."
        echo "*** EXITING THE SCRIPT"
        exit 1
        ;;
    esac
  done
fi

# deafult value for machine, now only for nird
mach=nird

if ${mpi_flag}; then
    Makefile=Makefile_cmor3mpi.${mach}_${compiler}
else
    Makefile=Makefile_cmor3.${mach}_${compiler}
fi

######################################################
#           ** DONT MODIFY BELOW **
######################################################

load_module_intel(){
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

load_module_gnu(){
  module purge
  module load GCCcore/13.2.0
  module load HDF5/1.14.3-gompi-2023b
  module load UDUNITS/2.2.28-GCCcore-13.2.0
  module load expat/2.5.0-GCCcore-13.2.0
  module load json-c/0.17-GCCcore-13.2.0
  module load netCDF-Fortran/4.6.1-gompi-2023b
  module load netCDF/4.9.2-gompi-2023b
  module load util-linux/2.39-GCCcore-13.2.0
  module load zlib/1.2.13-GCCcore-13.2.0
}

# load module and build
load_module_${compiler}
make -f $Makefile
