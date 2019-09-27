#!/bin/bash
set -e

#version=v20190815
#version=v20190909
#version=v20190917
version=v20190920

#ExpName=piClim-SpAer2014
#expid=piClim-spAer-aer
#project=NS9560K
#login0
#years1=($(seq 1 10 21))
#years2=($(seq 10 10 30))



#----------------
# historical 1
#----------------
#ExpName=NHIST_f19_tn14_20190625
#expid=historical
#login0
#years1=(1849 1860 1870 1880 1890 1900 1910 1920 1930 1940)
#years2=(1859 1869 1879 1889 1899 1909 1919 1929 1939 1949)

#----------------
# historical 2
#----------------
#ExpName=NHIST_f19_tn14_20190710
#expid=historical
#login0
#years1=(1950 1960 1970 1980 1990 2000 2010)
#years2=(1959 1969 1979 1989 1999 2009 2014)

#----------------
# piControl 1
#----------------
#ExpName=N1850_f19_tn14_20190621
#expid=piControl
#login1
#years1=(1600 1610 1620 1630 1640 1650 1660)
#years2=(1609 1619 1629 1639 1649 1659 1669)

#login1
#years1=(1670 1680 1690 1700 1710 1720 1730)
#years2=(1679 1689 1699 1709 1719 1729 1739)

#login2
#years1=(1740 1750 1760 1770 1780 1790 1800)
#years2=(1749 1759 1769 1779 1789 1799 1800)

#----------------
# piControl 2
#----------------
#ExpName=N1850_f19_tn14_20190722
#expid=piControl
#login2
#years1=(1801 1811 1821 1831 1841 1851 1861 1871 1881 1891)
#years2=(1810 1820 1830 1840 1850 1860 1870 1880 1890 1900)

#----------------
# abrupt-4xCO2 1
#----------------
#ExpName=NCO2x4_f19_tn14_20190624
#expid=abrupt-4xCO2
#login3
#years1=(0  $(seq 11 10 111))
#years2=(10 $(seq 20 10 120))

#----------------
# abrupt-4xCO2 2
#----------------
#ExpName=NCO2x4_f19_tn14_20190705
#expid=abrupt-4xCO2
#login3
#years1=($(seq 121 10 141))
#years2=($(seq 130 10 150))

#----------------
# abrupt-4xCO2 3
#----------------
#ExpName=NCO2x4_f19_tn14_20190724
#expid=abrupt-4xCO2
#login0
#years1=($(seq 151 10 291))
#years2=($(seq 160 10 300))

#----------------
# piClim-control
#----------------
#ExpName=NF1850norbc_f19_20190727
#expid=piClim-control
#login1
#years1=(0  11 21)
#years2=(10 20 30)

#----------------
# piClim-4xco2
#----------------
#ExpName=NF1850norbc_4xCO2_f19_20190727
#expid=piClim-4xCO2
##login1
#years1=(0  11 21)
#years2=(10 20 30)

#----------------
# piClim-ghg
#----------------
#ExpName=NF1850norbc_ghg2014_f19_20190727
#expid=piClim-ghg
#login1
#years1=(0  11 21)
#years2=(10 20 30)

#----------------
# piClim-BC
#----------------
#ExpName=NF1850norbc_bc2014_f19_20190727
#expid=piClim-BC
#login1
#years1=(0  11 21)
#years2=(10 20 30)

#----------------
# piClim-OC
#----------------
#ExpName=NF1850norbc_oc2014_f19_20190727
#expid=piClim-OC
#login1
#years1=(0  11 21)
#years2=(10 20 30)

#----------------
# piClim-SO2
#----------------
#ExpName=NF1850norbc_so22014_f19_20190727
#expid=piClim-SO2
#login1
#years1=(0  11 21)
#years2=(10 20 30)

#----------------
# piClim-aer
#----------------
#ExpName=NF1850norbc_aer2014_f19_20190727
#expid=piClim-aer
#login2
#years1=(0  11 21)
#years2=(10 20 30)

#----------------
# hist-GHG
#----------------
#ExpName=N1850ghgonly_f19_tn14_20190712
#expid=hist-GHG
##login2
#years1=(1849 $(seq 1860 10 2000) 2010)
#years2=(1859 $(seq 1869 10 2009) 2014)

#----------------
# hist-piNTCF
#----------------
#ExpName=NHISTpintcf_f19_tn14_20190720
#expid=hist-piNTCF
#login3
#years1=(1849 $(seq 1860 10 2000) 2010)
#years2=(1859 $(seq 1869 10 2009) 2014)

#----------------
# hist-piAer
#----------------
#ExpName=NHISTpiaer_f19_tn14_20190721
#expid=hist-piAer
#login0
#years1=(1849 $(seq 1860 10 2000) 2010)
#years2=(1859 $(seq 1869 10 2009) 2014)

#----------------
# 1pctCO2 part1
#----------------
#ExpName=N1PCT_f19_tn14_20190626
#expid=1pctCO2
##login1
#years1=(0  $(seq 11 10 111))
#years2=(10 $(seq 20 10 120))

#----------------
# 1pctCO2 part2
#----------------
#ExpName=N1PCT_f19_tn14_20190712
#expid=1pctCO2
##login1
#years1=($(seq 121 10 141))
#years2=($(seq 130 10 150))

#----------------
# piClim-lu
#----------------
#ExpName=piClim-lu2deg
#expid=piClim-lu
#login1
#years1=(1  11 21)
#years2=(10 20 30)

# ==========================================================
if [ ! -d ~/noresm2cmor/namelists/$version ]
then
    mkdir ~/noresm2cmor/namelists/$version
fi
if [ ! -d ~/noresm2cmor/logs/$version ]
then
    mkdir ~/noresm2cmor/logs/$version
fi
# check if sys mod var namelist exist
if [ ! -e ../namelists/${version}/sys_CMIP6_default.nml ]
then
    echo "ERROR:../namelists/${version}/sys_CMIP6_default.nml does not exist"
    echo "EXIT..."
    exit
fi
if [ ! -e ../namelists/${version}/mod_CMIP6_NorESM2-LM.nml ]
then
    echo "ERROR:../namelists/${version}/mod_CMIP6_NorESM2-LM.nml does not exist"
    echo "EXIT..."
    exit
fi
if [ ! -e ../namelists/${version}/var_CMIP6_NorESM2_default.nml ]
then
    echo "ERROR:../namelists/${version}/var_CMIP6_NorESM2_default.nml does not exist"
    echo "EXIT..."
    exit
fi

#sleep 6h
# copy template namelist and submit
for (( i = 0; i < ${#years1[*]}; i++ )); do
    year1=${years1[i]}
    year2=${years2[i]}
    echo ${year1} ${year2}
    cd ~/noresm2cmor/namelists

    cp CMIP6_template/exp_CMIP6_${expid}_${ExpName}.nml ${version}/exp_CMIP6_${expid}_${ExpName}_${year1}-${year2}.nml
    sed -i "s/vyyyymmdd/${version}/" \
        ${version}/exp_CMIP6_${expid}_${ExpName}_${year1}-${year2}.nml
    sed -i "s/year1         =.*/year1         = ${year1},/g" \
        ${version}/exp_CMIP6_${expid}_${ExpName}_${year1}-${year2}.nml
    sed -i "s/yearn         =.*/yearn         = ${year2},/g" \
        ${version}/exp_CMIP6_${expid}_${ExpName}_${year1}-${year2}.nml
    cd ~/noresm2cmor/bin
    nohup ./noresm2cmor3 ../namelists/${version}/sys_CMIP6_default${project}.nml ../namelists/${version}/mod_CMIP6_NorESM2-LM.nml \
        ../namelists/${version}/exp_CMIP6_${expid}_${ExpName}_${year1}-${year2}.nml \
        ../namelists/${version}/var_CMIP6_NorESM2_default.nml \
        1>~/noresm2cmor/logs/${version}/noresm2cmor3.${ExpName}_${year1}-${year2}.log \
        2>~/noresm2cmor/logs/${version}/noresm2cmor3.${ExpName}_${year1}-${year2}.err &
    sleep 10
done
