# submit comrisation for single realisation
function runcmor {
#
local CaseName expid version real years1 years2 project
local nmlroot logroot
#
if [ $# -gt 0 ] && [ $1 == "--help" ] 
 then
     printf "Usage:\n"
     printf "runcmor -c=[CaseName] -e=[expid] -v=[version] -r=[realisation] \
                     -yrs1=[(${years1[*]})] -yrs2=[(${years2[*]})] -p=[project] \
                     -mpi=[DMPI] \n"
     return
 else
     while test $# -gt 0; do
         case "$1" in
             -c=*)
                 CaseName=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             -m=*)
                 model=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             -e=*)
                 expid=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             -v=*)
                 version=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             -r=*)
                 real=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             -yrs1=*)
                 years1=($(echo $1|sed -e 's/^[^=]*=//g'))
                 shift
                 ;;
             -yrs2=*)
                 years2=($(echo $1|sed -e 's/^[^=]*=//g'))
                 shift
                 ;;
             -p=*)
                 project=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             -mpi=*)
                 mpi=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             * )
                 echo "ERROR: option $1 not allowed."

                 echo "*** EXITING THE SCRIPT"
                 exit 1
                 ;;
         esac
     done
 fi

echo -e "CaseName: $CaseName"
echo -e "expid   : $expid"
echo -e "version : $version"
echo -e "real    : $real"
if [ ! -z $project ]
then
    echo -e "project : $project"
fi
#echo -e "years1  : ${years1[*]}"
#echo -e "years2  : ${years2[*]}"
# ==========================================================
ulimit -c 0
if [ $(hostname -f |grep 'ipcc') ]
then
    root=/scratch/NS9034K
    project=${project}ipcc
    export PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/usr/local/sbin
    source /opt/intel/compilers_and_libraries/linux/bin/compilervars.sh -arch intel64 -platform linux
else
    root=~
fi
cwd=$(pwd)

cd ${root}/noresm2cmor/bin
nmlroot=../namelists/CMIP6_NorESM2-MM/${expid}/${version}
logroot=../logs/CMIP6_NorESM2-MM/${expid}/${version}

if [ ! -d $logroot ]
then
    mkdir -p $logroot
fi
# check if sys mod var namelist exist
nf=$(ls ${nmlroot}/{mod*.nml,sys*.nml,var*.nml} |wc -l)
if [ $nf -lt 3 ]
then
    echo "ERROR: one or more ${nmlroot}/{mod*.nml,sys*.nml,var*.nml} does not exist"
    echo "EXIT..."
    exit
fi

# if CaseName and realisation are defined
if [ ! -z $CaseName ]
then
    CaseName="_${CaseName}"
fi
if [ ! -z $real ]
then
    real="r${real}"
fi

# copy template namelist and submit
for (( i = 0; i < ${#years1[*]}; i++ )); do
    year1=${years1[i]}
    year2=${years2[i]}
    echo ${year1} ${year2}
    cd ../namelists

    cp CMIP6_NorESM2-MM/${expid}/template/exp${CaseName}.nml \
       CMIP6_NorESM2-MM/${expid}/${version}/exp.nml
    sed -i "s/vyyyymmdd/${version}/" \
        CMIP6_NorESM2-MM/${expid}/${version}/exp.nml
    sed -i "s/year1         =.*/year1         = ${year1},/g" \
        CMIP6_NorESM2-MM/${expid}/${version}/exp.nml
    sed -i "s/yearn         =.*/yearn         = ${year2},/g" \
        CMIP6_NorESM2-MM/${expid}/${version}/exp.nml
    mv CMIP6_NorESM2-MM/${expid}/${version}/exp.nml CMIP6_NorESM2-MM/${expid}/${version}/exp_${year1}-${year2}${real}.nml

    cd ../bin

    # keep maximumn 8 jobs
    flag=true
    while $flag ; do
        np=$(ps x |grep -c 'noresm2cmor3')
        if [ $np -lt 8 ]; then
            flag=false
        fi
        sleep 30s
    done

    if [ ! -z $mpi ] && [ $mpi == "DMPI" ]
    then
        nohup mpirun -n 8 ./noresm2cmor3_mpi \
            ${nmlroot}/sys${project}.nml \
            ${nmlroot}/mod.nml \
            ${nmlroot}/exp_${year1}-${year2}${real}.nml \
            ${nmlroot}/var.nml \
            1>${logroot}/${year1}-${year2}${real}.log \
            2>${logroot}/${year1}-${year2}${real}.err &
    else
        nohup ./noresm2cmor3 \
                ${nmlroot}/sys${project}.nml \
                ${nmlroot}/mod.nml \
                ${nmlroot}/exp_${year1}-${year2}${real}.nml \
                ${nmlroot}/var.nml \
                1>${logroot}/${year1}-${year2}${real}.log \
                2>${logroot}/${year1}-${year2}${real}.err &
    fi
    sleep 30s
done

cd $cwd

}
