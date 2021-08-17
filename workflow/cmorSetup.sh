#!/bin/bash
set -e

# Setup namelist and bash scripts for cmorization

if [ $# -eq 0 ] || [ $1 == "--help" ] 
 then
     printf "\n"
     printf " Description: \n"
     printf "   Create necessary namelist files and script for an experiment (cmip or noncmip),\n"
     printf "   using existing experiments under namelists/ as template\n"
     printf "\n"
     printf " Usage:\n"
     printf '   ./cmorSetup.sh \
       --casename=[casename]        # e.g., NHIST_f19_tn14_20190625 \
       --model=[model]              # e.g., NorESM2-LM, NorESM2-MM, NorESM1-F \
       --expid=[expid]              # e.g., experiment id (either CMIP exp_id or your own defined experiment id)\
       --expidref=[expidref]        # e.g., an equivalent/similar CMIP6 experiment id to be used as template
       --version=[version]          # e.g., v20200702 (or other vyyyymmdd) \
       --year1=[year1]              # e.g., 1850 (first model year to be cmorized) \
       --yearn=[yearn]              # e.g., 2014 (last model year to be cmorized) \
       --realization=[realization]  # e.g., (optional) 1 (default),2,3,etc\
       --physics=[physics]          # e.g., (optional) 1 (default),2,3,etc\
       --forcing=[forcing]          # e.g., (optional) 1 (default),2,3,etc\
       --init=[initialization]      # e.g., (optional) 1 (default),2,3,etc\
       --mpi=[DMPI|UMPI]            # e.g., (optional) DMPI, UMPI \
       --ibasedir=[ibasedir]        # path to model output (optional), default /projects/NS9560K/noresm/cases \
       --obasedir=[obasedir]        # path to cmorized output.\
                                      e.g., /projects/NSxxxxK/CMIP6/cmorout \
                                      by default, set to /scratch/$USER/cmorout \
       --noncmip=[ifnoncmip]        # flag if cmip expperiment or non-cmip experiment
        \n'
     printf " Example:\n"
     printf "   ./cmorSetup.sh --casename=test_casename --model=NorESM2-LM --expid=testexpid --expidref=piControl --version=v20210614 --year1=1600 --yearn=1900 --realization=1 --physics=1 --forcing=1 --mpi=DMPI --ibasedir=/projects/NS2345K/noresm/cases --obasedir=/scratch/$USER/cmorout --noncmip=true \n"
     exit
 else
     # set default values
     realization=1
     physics=1
     forcing=1
     init=1
     parallel=DMPI
     ibasedir=/projects/NS9560K/noresm/cases
     obasedir=/scratch/$USER/cmorout
     noncmip=false
     while test $# -gt 0; do
         case "$1" in
             --casename=*)
                 casename=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             --model=*)
                 model=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             --expid=*)
                 expid=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             --expidref=*)
                 expidref=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             --version=*)
                 version=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             --year1=*)
                 year1=($(echo $1|sed -e 's/^[^=]*=//g'))
                 shift
                 ;;
             --yearn=*)
                 yearn=($(echo $1|sed -e 's/^[^=]*=//g'))
                 shift
                 ;;
             --realization=*)
                 realization=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             --physics=*)
                 physics=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             --forcing=*)
                 forcing=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             --init=*)
                 init=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             --mpi=*)
                 mpi=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             --ibasedir=*)
                 ibasedir=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             --obasedir=*)
                 obasedir=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             --noncmip=*)
                 noncmip=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             * )
                 echo "ERROR: option $1 not recognised."
                 echo "*** EXITING THE SCRIPT"
                 exit 1
                 ;;
         esac
     done
fi

CMOR_ROOT=$(cd $(dirname $0) && cd .. && pwd)
for param in casename model expid version year1 yearn realization physics ibasedir obasedir
    do
    [ -z ${!param} ] && echo "** ERROR: \$$param is not specificed **" && exit 1
done

if [ -z $expidref ]; then
    expidref=$expid
fi

if [ ! -d $CMOR_ROOT/namelists/CMIP6_${model}/${expid} ];then
    mkdir -p $CMOR_ROOT/namelists/CMIP6_${model}/${expid}
fi
cd $CMOR_ROOT/namelists/CMIP6_${model}/${expid}/

[ ! -d $version ] && mkdir $version
[ ! -d template ] && mkdir template
if $noncmip; then
    [ ! -d tables ]   && mkdir tables
    for fname in $(ls ../../../tables/CMIP6_*.json)
    do
        [ ! -f tables/$fname ] && ln -s ../$fname tables/
    done
fi

expnmltemp=$(ls $CMOR_ROOT/namelists/CMIP6_${model}/${expidref}/template/exp.nml 2>/dev/null | tail -1 |cat)
if [ -z $expnmltemp ]; then
    expnmltemp=$(ls $CMOR_ROOT/namelists/CMIP6_${model}/${expidref}/template/exp*.nml |head -1)
fi
#[ ! -f template/exp_${casename}.nml ] && \
cp $expnmltemp template/exp_${casename}.nml |cat

sed -i "s/casename * = '.*',/casename      = '${casename}',/g" template/exp_${casename}.nml
sed -i "s~osubdir * = '.*',*~osubdir       = '${model}/${expid}/vyyyymmdd',~g" template/exp_${casename}.nml
sed -i "s~^ experiment_id * = '.*',*~ experiment_id = '${expid}',~g" template/exp_${casename}.nml
sed -i "s/realization * = .*,/realization   = ${realization},/g" template/exp_${casename}.nml
sed -i "s/physics_version * = .*,/physics_version = ${physics},/g" template/exp_${casename}.nml
sed -i "s/forcing_index * = .*,/forcing_index = ${forcing},/g" template/exp_${casename}.nml
sed -i "s/initialization_method * = .*,/initialization_method = ${init},/g" template/exp_${casename}.nml
sed -i "s/year1 * = .*,/year1         = ${year1},/g" template/exp_${casename}.nml
sed -i "s/yearn * = .*,/yearn         = ${yearn},/g" template/exp_${casename}.nml

cp $CMOR_ROOT/namelists/sys_CMIP6_default.nml $version/sys.nml
cp $CMOR_ROOT/namelists/mod_CMIP6_${model}.nml $version/mod.nml
cp $CMOR_ROOT/namelists/var_CMIP6_NorESM2_default.nml $version/var.nml

sed -i "s~ibasedir * = '.*',~ibasedir      = '${ibasedir}',~g" ${version}/sys.nml
sed -i "s~obasedir * = '.*',~obasedir      = '${obasedir}',~g" ${version}/sys.nml
sed -i "s~griddata * = '.*',~griddata      = '/projects/NS9560K/cmor/griddata',~g" ${version}/sys.nml
sed -i "s~tabledir * = '.*',~tabledir      = '../namelists/CMIP6_${model}/${expid}/tables',~g" ${version}/sys.nml
sed -i "s/forcefilescan * = .*.,/forcefilescan = .false.,/g" ${version}/sys.nml

# split years
#year11=$(( $year1-1          ))
year11=$(( $year1            ))
year12=$(( ($year1/10+1)*10  ))
year13=$(( $yearn/10*10-10   ))
year14=$(( $yearn/10*10      ))
yearn1=$(( $year1/10*10+9    ))
yearn2=$(( ($year1/10+1)*10+9))
yearn3=$(( $yearn/10*10-1    ))
yearn4=$yearn

((dyr=$yearn-$year1))

# update cmor_casename.sh
cp $CMOR_ROOT/workflow/cmor.template cmor_${casename}.sh
sed -i "s/^version=.*/version=${version}/" cmor_${casename}.sh
sed -i "s/^expid=.*[[:alnum:]_]$/expid=${expid}/" cmor_${casename}.sh
sed -i "s/^model=.*/model=${model}/" cmor_${casename}.sh
sed -i "s/^CaseName=.*/CaseName=${casename}/" cmor_${casename}.sh
sed -i "s/^real=.*/real=${realization}/" cmor_${casename}.sh
sed -i "s/^physics=.*/physics=${physics}/" cmor_${casename}.sh
sed -i "s/^forcing=.*/forcing=${forcing}/" cmor_${casename}.sh
sed -i "s/^init=.*/init=${init}/" cmor_${casename}.sh
sed -i "s/^parallel=.*/parallel=${parallel}/" cmor_${casename}.sh

if [ $dyr -le 10 ]
then
    sed -i "s/years1=(year11 \$(seq year12 10 year13) year14)/years1=($year11)/" cmor_${casename}.sh 
    sed -i "s/years2=(yearn1 \$(seq yearn2 10 yearn3) yearn4)/years2=($yearn4)/" cmor_${casename}.sh 
else

    sed -i "s/year11/$year11/" cmor_${casename}.sh
    sed -i "s/year12/$year12/" cmor_${casename}.sh
    sed -i "s/year13/$year13/" cmor_${casename}.sh
    sed -i "s/year14/$year14/" cmor_${casename}.sh
    sed -i "s/yearn1/$yearn1/" cmor_${casename}.sh
    sed -i "s/yearn2/$yearn2/" cmor_${casename}.sh
    sed -i "s/yearn3/$yearn3/" cmor_${casename}.sh
    sed -i "s/yearn4/$yearn4/" cmor_${casename}.sh
fi

# update checkcmourout.sh
cp $CMOR_ROOT/workflow/checkcmorout.template checkcmorout.sh
years1line=$(grep 'years1=(' cmor_${casename}.sh)
years2line=$(grep 'years2=(' cmor_${casename}.sh)
sed -i "s/years1=(.*/$years1line/g" checkcmorout.sh
sed -i "s/years2=(.*/$years2line/g" checkcmorout.sh

echo -e "       "
echo -e "-----------------------------------------------------------------"
echo -e " *** Templates for CMOR submission are succussfully created! *** "
echo -e "-----------------------------------------------------------------"
echo -e "       "
echo -e " \e[1;mNamelist files are created under:\e[0m"
echo -e "  $CMOR_ROOT/namelists/CMIP6_${model}/${expid}/$version"
echo -e "       "
echo -e " \e[1;mSubmission script is created:\e[0m "
echo -e "  $CMOR_ROOT/namelists/CMIP6_${model}/${expid}/cmor_${casename}.sh"
echo -e "       "
echo -e " \e[1;mGo to the above path and review and submit the script with parameters as:\e[0m"
echo -e "  ./cmor_${casename}.sh -m=${model} -e=${expid} -v=${version} &>cmor.log &"
echo -e "       "
echo -e " \e[1;mCheck the cmorized output:\e[0m"
echo -e "  ./checkcmorout.sh -m=${model} -e=${expid} -v=${version} -o=${obasedir} &>cmor.log &"
echo -e "       "
echo -e " \e[1;mThen keep track on the overview log at:\e[0m"
echo -e "  ./cmor.log"
echo -e "       "
echo -e " \e[1;mAnd the detailed log under:\e[0m"
echo -e "  $CMOR_ROOT/logs/CMIP6_${model}/${expid}/$version"
echo -e "       "


