#!/bin/env bash
#set -e

#sfx=010
#rplus=1
#sfx=020
#rplus=36
sfx=030
rplus=71
for i in {0..34}
do
    ((r=$i+$rplus))
    n=$(printf %02d $i)
    #echo $r $n
    cmorSetup.sh --casename=NHIST_f19_tn14_pamip2p1_${sfx}${n} --model=NorESM2-LM --expid=pa-pdSIC --version=v20200702 --year1=2000 --yearn=2001 --realization=$r --physics=1 --mpi=DMPI --ibasedir=/projects/NS2345K/noresm/cases/NHIST_f19_tn14_pamip2p1 --obasedir=/projects/NS9034K/CMIP6/.cmorout
    sed -i "s/runcmor.*$/& -s=NHIST_f19_tn14_pamip2p1/g" cmor_NHIST_f19_tn14_pamip2p1_${sfx}${n}.sh
done

