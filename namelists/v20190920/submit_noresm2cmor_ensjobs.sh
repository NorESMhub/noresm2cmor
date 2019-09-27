#!/bin/bash
set -e

#version=v20190815
version=v20190920

#----------------
# pdSST-pdSIC part1
#----------------
ExpName=NFHISTnorpddmsbc_PAMIP_1p1_pdSST-pdSIC_mem1-25_f19_mg17_20190819
expid=pdSST-pdSIC
#login0
years1=(2000)
years2=(2001)
month1=6
month2=5

# login0
reals=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16)
membs=(0001 0002 0003 0004 0005 0006 0007 0008 0009 0010 0011 0012 0013 0014 0015 0016)
# login1
#reals=(17 18 19 20 21 22 23 24 25)
#membs=(0017 0018 0019 0020 0021 0022 0023 0024 0025)

#----------------
# pdSST-pdSIC part2
#----------------
#ExpName=NFHISTnorpddmsbc_PAMIP_1p1_pdSST-pdSIC_mem26-50_f19_mg17_20190819
#expid=pdSST-pdSIC
#years1=(2000)
#years2=(2001)
#month1=6
#month2=5

#login2
#reals=(  26   27   28   29   30   31   32   33   34   35   36   37)
#membs=(0001 0002 0003 0004 0005 0006 0007 0008 0009 0010 0011 0012)
# login3
#reals=(  38   39   40   41   42   43   44   45   46   47   48   49   50)
#membs=(0013 0014 0015 0016 0017 0018 0019 0020 0021 0022 0023 0024 0025)

#----------------
# pdSST-pdSIC part3
#----------------
#ExpName=NFHISTnorpddmsbc_PAMIP_1p1_pdSST-pdSIC_mem51-75_f19_mg17_20190819
#expid=pdSST-pdSIC
#years1=(2000)
#years2=(2001)
#month1=6
#month2=5

#login0
#reals=(  51   52   53   54   55   56   57   58   59   60   61   62)
#membs=(0001 0002 0003 0004 0005 0006 0007 0008 0009 0010 0011 0012)
# login1
#reals=(  63   64   65   66   67   68   69   70   71   72   73   74   75)
#membs=(0013 0014 0015 0016 0017 0018 0019 0020 0021 0022 0023 0024 0025)

#----------------
# pdSST-pdSIC part4
#----------------
#ExpName=NFHISTnorpddmsbc_PAMIP_1p1_pdSST-pdSIC_mem76-100_f19_mg17_20190819
#expid=pdSST-pdSIC
#years1=(2000)
#years2=(2001)
#month1=6
#month2=5

#login2
#reals=(  76   77   78   79   80   81   82   83   84   85   86   87)
#membs=(0001 0002 0003 0004 0005 0006 0007 0008 0009 0010 0011 0012)
# login3
#reals=(  88   89   90   91   92   93   94   95   96   97   98   99  100)
#membs=(0013 0014 0015 0016 0017 0018 0019 0020 0021 0022 0023 0024 0025)

#----------------
# pdSST-futArcSIC part 1
#----------------
#ExpName=NFHISTnorpddmsbc_PAMIP_1p6_pdSST-futArcSIC_mem1-25_f19_mg17_20190819
#expid=pdSST-futArcSIC
#years1=(2000)
#years2=(2001)
#month1=6
#month2=5

# login0
#reals=(   1    2    3    4    5    6    7    8    9   10   11   12   13)
#membs=(0001 0002 0003 0004 0005 0006 0007 0008 0009 0010 0011 0012 0013)
# login1
#reals=(  14   15   16   17   18   19   20   21   22   23   24   25)
#membs=(0014 0015 0016 0017 0018 0019 0020 0021 0022 0023 0024 0025)

#----------------
# pdSST-futArcSIC part 2
#----------------
#ExpName=NFHISTnorpddmsbc_PAMIP_1p6_pdSST-futArcSIC_mem26-50_f19_mg17_20190819
#expid=pdSST-futArcSIC
#years1=(2000)
#years2=(2001)
#month1=6
#month2=5
#login2
#reals=(  26   27   28   29   30   31   32   33   34   35   36   37)
#membs=(0001 0002 0003 0004 0005 0006 0007 0008 0009 0010 0011 0012)
# login3
#reals=(  38   39   40   41   42   43   44   45   46   47   48   49   50)
#membs=(0013 0014 0015 0016 0017 0018 0019 0020 0021 0022 0023 0024 0025)

#----------------
# pdSST-futArcSIC part 3
#----------------
#ExpName=NFHISTnorpddmsbc_PAMIP_1p6_pdSST-futArcSIC_mem51-75_f19_mg17_20190819
#expid=pdSST-futArcSIC
#years1=(2000)
#years2=(2001)
#month1=6
#month2=5
#login0
#reals=(  51   52   53   54   55   56   57   58   59   60   61   62)
#membs=(0001 0002 0003 0004 0005 0006 0007 0008 0009 0010 0011 0012)
# login1
#reals=(  63   64   65   66   67   68   69   70   71   72   73   74   75)
#membs=(0013 0014 0015 0016 0017 0018 0019 0020 0021 0022 0023 0024 0025)

#----------------
# pdSST-futArcSIC part 4
#----------------
#ExpName=NFHISTnorpddmsbc_PAMIP_1p6_pdSST-futArcSIC_mem76-100_f19_mg17_20190819
#expid=pdSST-futArcSIC
#years1=(2000)
#years2=(2001)
#month1=6
#month2=5

#login2
#reals=(  76   77   78   79   80   81   82   83   84   85   86   87)
#membs=(0001 0002 0003 0004 0005 0006 0007 0008 0009 0010 0011 0012)
# login3
#reals=(  88   89   90   91   92   93   94   95   96   97   98   99  100)
#membs=(0013 0014 0015 0016 0017 0018 0019 0020 0021 0022 0023 0024 0025)
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


# copy template namelist and submit
for (( i = 0; i < ${#years1[*]}; i++ )); do
    year1=${years1[i]}
    year2=${years2[i]}
    yyyy1=$(printf "%04i\n" $year1)
    yyyy2=$(printf "%04i\n" $year2)
    mm1=$(printf "%02i\n" $month1)
    mm2=$(printf "%02i\n" $month2)
    echo ${yyyy1}${mm1}-${yyyy2}${mm2}
    for (( i = 0; i < ${#reals[*]}; i++ )); do
        real=${reals[i]}
        memb=${membs[i]}
        echo ${real} ${memb}
        cd ~/noresm2cmor/namelists
        cp CMIP6_template/exp_CMIP6_${expid}_${ExpName}.nml \
            ${version}/exp_CMIP6_${expid}_${ExpName}_${yyyy1}${mm1}-${yyyy2}${mm2}_r${real}.nml
        if [ $? -ne 0 ]
        then
            echo "ERROR: copy template exp_*.nml"
            exit
        fi
        sed -i "s/vyyyymmdd/${version}/" \
            ${version}/exp_CMIP6_${expid}_${ExpName}_${yyyy1}${mm1}-${yyyy2}${mm2}_r${real}.nml
        sed -i "s/year1         =.*/year1         = ${year1},/g" \
            ${version}/exp_CMIP6_${expid}_${ExpName}_${yyyy1}${mm1}-${yyyy2}${mm2}_r${real}.nml
        sed -i "s/yearn         =.*/yearn         = ${year2},/g" \
            ${version}/exp_CMIP6_${expid}_${ExpName}_${yyyy1}${mm1}-${yyyy2}${mm2}_r${real}.nml
        sed -i "s/month1         =.*/month1         = ${month1},/g" \
            ${version}/exp_CMIP6_${expid}_${ExpName}_${yyyy1}${mm1}-${yyyy2}${mm2}_r${real}.nml
        sed -i "s/monthn         =.*/monthn         = ${month2},/g" \
            ${version}/exp_CMIP6_${expid}_${ExpName}_${yyyy1}${mm1}-${yyyy2}${mm2}_r${real}.nml
        sed -i "s/realization   =.*/realization   = ${real},/g" \
            ${version}/exp_CMIP6_${expid}_${ExpName}_${yyyy1}${mm1}-${yyyy2}${mm2}_r${real}.nml
        sed -i "s/membertag      =.*/membertag      = ${memb}/g" \
            ${version}/exp_CMIP6_${expid}_${ExpName}_${yyyy1}${mm1}-${yyyy2}${mm2}_r${real}.nml
        cd ~/noresm2cmor/bin
        nohup ./noresm2cmor3 ../namelists/${version}/sys_CMIP6_default.nml ../namelists/${version}/mod_CMIP6_NorESM2-LM.nml \
            ../namelists/${version}/exp_CMIP6_${expid}_${ExpName}_${yyyy1}${mm1}-${yyyy2}${mm2}_r${real}.nml \
            ../namelists/${version}/var_CMIP6_NorESM2_default.nml \
            1>~/noresm2cmor/logs/${version}/noresm2cmor3.${ExpName}_${yyyy1}${mm1}-${yyyy2}${mm2}_r${real}.log \
            2>~/noresm2cmor/logs/${version}/noresm2cmor3.${ExpName}_${yyyy1}${mm1}-${yyyy2}${mm2}_r${real}.err &
        sleep 10
    done
done
