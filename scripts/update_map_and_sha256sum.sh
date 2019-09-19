#!/bin/bash
set -e

#version=v20190815
version=v20190909

cd /tos-project1/NS9034K/CMIP6
for dname in AerChemMIP CMIP DAMIP RFMIP
do
    echo $dname

    # swap exp_id and source_id in .map files
    #for filename in `find $dname/NCC/NorESM2-LM -name '.r1i1p1f1.map' -print`
        #do
        #echo ${filename}
        #expid=$(echo $filename |awk -F"/" '{print $(NF-1)}')
        #sed -i "s/${expid}_NorESM2-LM/NorESM2-LM_${expid}/" $filename
    #done

    # swap exp_id and source_id in .sha256sum files
    #for filename in `find $dname/NCC/NorESM2-LM -name '.r1i1p1f1.sha256sum' -print`
        #do
        #echo ${filename}
        #expid=$(echo $filename |awk -F"/" '{print $(NF-1)}')
        #sed -i "s/${expid}_NorESM2-LM/NorESM2-LM_${expid}/" $filename
    #done

    # remove sha256sum for v20190909
    #for filename in `find $dname/NCC/NorESM2-LM -name '.r1i1p1f1.sha256sum' -print`
        #do
        #echo ${filename}
        #sed -i '/v20190909/d' ${filename}
    #done

    # remove *02-*.nc files of some Emon Lmon LImon tables for v20190815
    # expid piControl and piClim-lu are not affected
    for expid in 1pctCO2 abrupt-4xCO2 hist-GHG historical hist-piAer hist-piNTCF piClim-4xCO2 piClim-aer piClim-BC piClim-control piClim-ghg piClim-OC piClim-SO2
    do
        for shasumfile in `find $dname/NCC/NorESM2-LM/${expid} -name '.r1i1p1f1.sha256sum' -print 2>/dev/null`
        do
            #echo $shasumfile
            # remove afected Emon, Lmon, LImon fields
            for prefix in cCwd_Lmon cLeaf_Lmon cLitter_Lmon cRoot_Lmon cSoilFast_Lmon cSoilMedium_Lmon cSoilSlow_Lmon cVeg_Lmon cWood_Emon evspsblsoi_Lmon evspsblveg_Lmon fFire_Lmon fHarvest_Lmon fVegLitter_Lmon gpp_Lmon lai_Lmon lwsnl_LImon mrfso_Lmon mrlso_Emon mrro_Lmon mrros_Lmon mrsfl_Emon mrsll_Emon mrsol_Emon mrso_Lmon mrsos_Lmon nbp_Lmon nep_Emon nppLeaf_Lmon npp_Lmon nppRoot_Lmon nppWood_Lmon prveg_Lmon ra_Lmon rGrowth_Lmon rh_Lmon rMaint_Lmon snc_LImon snd_LImon snw_LImon sootsn_LImon tran_Lmon tsl_Lmon vegHeight_Emon
            do
                #echo $prefix
                sed -i "/$prefix/d" ${shasumfile}
            done
        done
    done
    for expid in 1pctCO2 abrupt-4xCO2 hist-GHG historical hist-piAer hist-piNTCF piClim-4xCO2 piClim-aer piClim-BC piClim-control piClim-ghg piClim-OC piClim-SO2 piClim-lu piControl
    do
        for shasumfile in `find $dname/NCC/NorESM2-LM/${expid} -name '.r1i1p1f1.sha256sum' -print 2>/dev/null`
        do
            # remove loadbc loadpoa which are not required by CMIP6
            for prefix in loadbc loadpoa
            do
                #echo $prefix
                sed -i "/${prefix}_Emon/d" ${shasumfile}
            done
            for prefix in hus loaddust loadss ps rsdsdiff ua va wap
            do
                #echo $prefix
                sed -i "/${prefix}_Emon/d" ${shasumfile}
            done
        done
    done
done


