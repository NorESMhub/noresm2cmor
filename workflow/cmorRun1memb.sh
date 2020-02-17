# submit comrisation for single realisation
function runcmor {
#
local CaseName expid version real years1 years2 project
local nmlroot logroot
#
if [ $# -eq 0 ] || [ $1 == "--help" ] 
 then
     printf "Usage:\n"
     printf 'runcmor -c=[CaseName] -m=[model] -e=[expid] -v=[version] -r=[realisation] \
                     -yrs1=[(${years1[*]})] -yrs2=[(${years2[*]})] -p=[project] \
                     -mpi=[DMPI] \n'
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
#ulimit -c unlimited
ulimit -s unlimited
source /opt/intel/compilers_and_libraries/linux/bin/compilervars.sh -arch intel64 -platform linux
#if [ $(hostname -f |grep 'ipcc') ]
#then
    #project=${project}ipcc
    #export PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/usr/local/sbin
#fi
cwd=$(pwd)

cd ${CMOR_ROOT}/bin
nmlroot=${CMOR_ROOT}/namelists/CMIP6_${model}/${expid}/${version}
logroot=${CMOR_ROOT}/logs/CMIP6_${model}/${expid}/${version}

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

    # keep maximumn 8 jobs
    flag=true
    while $flag ; do
        sleep 30s
        np=$(ps x |grep -c 'noresm2cmor3')
        if [ $np -lt 8 ]; then
            flag=false
        fi
    done

    year1=${years1[i]}
    year2=${years2[i]}
    echo ${year1} ${year2}
    cd ../namelists

    cp CMIP6_${model}/${expid}/template/exp${CaseName}.nml \
       CMIP6_${model}/${expid}/${version}/exp.nml
    sed -i "s/vyyyymmdd/${version}/" \
        CMIP6_${model}/${expid}/${version}/exp.nml
    sed -i "s/year1         =.*/year1         = ${year1},/g" \
        CMIP6_${model}/${expid}/${version}/exp.nml
    sed -i "s/yearn         =.*/yearn         = ${year2},/g" \
        CMIP6_${model}/${expid}/${version}/exp.nml
    mv CMIP6_${model}/${expid}/${version}/exp.nml CMIP6_${model}/${expid}/${version}/exp_${year1}-${year2}${real}.nml

    cd ../bin

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
done

cd $cwd

}
