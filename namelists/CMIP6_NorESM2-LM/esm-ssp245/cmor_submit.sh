#!/bin/bash

scripts=()
#scripts+=(cmor_NSSP245frc2esm_1851_f19_tn14_20230505.sh)
#scripts+=(cmor_NSSP245frc2esm_1901_f19_tn14_20230427.sh)
scripts+=(cmor_NSSP245frc2esm_1951_f19_tn14_20230505.sh)
#scripts+=(cmor_NSSP245frc2esm_2001_f19_tn14_20230505.sh)
scripts+=(cmor_NSSP245frc2esm_2051_f19_tn14_20230505.sh)
#scripts+=(cmor_NSSP245frc2esm_2201_f19_tn14_20230505.sh)
scripts+=(cmor_NSSP245frc2esm_2231_f19_tn14_20230505.sh)
scripts+=(cmor_NSSP245frc2esm_2251_f19_tn14_20230505.sh)
scripts+=(cmor_NSSP245frc2esm_2291_f19_tn14_20230505.sh)
scripts+=(cmor_NSSP245frc2esm_2311_f19_tn14_20230505.sh)

for fname in ${scripts[*]}
do
  echo $fname
  logname=$(basename -s .sh $fname).log
  ./$fname -m=NorESM2-LM -e=esm-ssp245 -v=v20230616 &>./$logname &
  sleep 15
done
