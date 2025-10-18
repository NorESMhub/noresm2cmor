#!/usr/bin/env bash

# load compilber toolchain (now only compiler)

if [ $# -lt 1 ]; then
  echo "Usage: source load_modules.sh gnu|intel"
  exit 1
fi

toolchain=$1

load_gnu(){
  module purge
  module load GCCcore/13.2.0
}

load_intel(){
  module purge
  module load intel/2023b
}

load_${toolchain}
