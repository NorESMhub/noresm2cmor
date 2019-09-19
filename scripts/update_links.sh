#!/bin/sh -e 

#for ITEM in `find /projects/NS9034K/CMIP6 -name "*.nc"`
#do 
        #echo "cd `dirname $ITEM`"
	#cd `dirname $ITEM`
	#FNAME=`basename $ITEM`
	#SLINK=`stat -c %N $FNAME | cut -d"‘" -f3 | cut -d"’" -f1`
	#echo "ln -sf `echo $SLINK | sed 's%/cmorout%/.cmorout%'` $FNAME"
	#ln -sf `echo $SLINK | sed 's%/cmorout%/.cmorout%'` $FNAME
#done 

cd /projects/NS9034K/CMIP6/
for dname in AerChemMIP  CMIP  DAMIP  RFMIP
do
    echo $dname
    for prefix in cCwd_Lmon cLeaf_Lmon cLitter_Lmon cRoot_Lmon cSoilFast_Lmon cSoilMedium_Lmon cSoilSlow_Lmon cVeg_Lmon cWood_Emon evspsblsoi_Lmon evspsblveg_Lmon fFire_Lmon fHarvest_Lmon fVegLitter_Lmon gpp_Lmon lai_Lmon lwsnl_LImon mrfso_Lmon mrlso_Emon mrro_Lmon mrros_Lmon mrsfl_Emon mrsll_Emon mrsol_Emon mrso_Lmon mrsos_Lmon nbp_Lmon nep_Emon nppLeaf_Lmon npp_Lmon nppRoot_Lmon nppWood_Lmon prveg_Lmon ra_Lmon rGrowth_Lmon rh_Lmon rMaint_Lmon snc_LImon snd_LImon snw_LImon sootsn_LImon tran_Lmon tsl_Lmon vegHeight_Emon
    do
        echo $prefix
        find $dname -name ${prefix}*.nc -exec rm -f {} \;
    done
    for prefix in loadbc loadpoa
    do
        echo $prefix
        find $dname -name ${prefix}*.nc -exec rm -f {} \;
    done
    for prefix in hus_Emon loaddust_Emon loadss_Emon ps_Emon rsdsdiff_Emon ua_Emon va_Emon wap_Emon
    do
        echo $prefix
        find $dname -name ${prefix}*.nc -exec rm -f {} \;
    done
done


