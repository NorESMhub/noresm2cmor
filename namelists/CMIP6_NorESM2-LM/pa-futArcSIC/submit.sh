#!/bin/env bash
#set -ex

#sfx=010
#sfx=020
sfx=030
for n in {00..34}
do
    rm -f /projects/NS9560K/cmor/noresm2cmor/bin/filelist_NHIST_f19_tn14_pamip2p2_${sfx}${n}
    ./cmor_NHIST_f19_tn14_pamip2p2_${sfx}${n}.sh -m=NorESM2-LM -e=pa-futArcSIC -v=v20201001
done

#for n in {00..34}
#do
    #cp ./cmor_NHIST_f19_tn14_pamip2p2_${sfx}${n}.sh ./cmor_NHIST_f19_tn14_pamip2p2_${sfx}${n}EP.sh
    #sed -i 's/\-mpi=DMPI/-mpi=DMPI \-s=EP/g' cmor_NHIST_f19_tn14_pamip2p2_${sfx}${n}EP.sh
    #rm -f /projects/NS9560K/cmor/noresm2cmor/bin/filelist_NHIST_f19_tn14_pamip2p2_${sfx}${n}
    #./cmor_NHIST_f19_tn14_pamip2p2_${sfx}${n}EP.sh
#done
