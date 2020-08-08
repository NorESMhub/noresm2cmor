#!/bin/bash
set -e

# Setup namelist and bash scripts for cmorization

if [ $# -eq 0 ] || [ $1 == "--help" ] 
 then
     printf "\n"
     printf " Usage:\n"
     printf ' ./cmorSetup.sh \
       -c=[casename]     # e.g., NHIST_f19_tn14_20190625 \
       -m=[model]        # e.g., NorESM2-LM, NorESM2-MM, NorESM1-F,NorESM1-M \
       -e=[expid]        # e.g., historical, piControl, ssp126, omip2, etc \
       -v=[version]      # e.g., v20200702 \
       -y1=[year1]       # e.g., 1850 \
       -y2=[yearn]       # e.g., 2014 \
       -r=[realization]  # e.g., 1,2,3 \
       -p=[physics]      # e.g., 1,2,3 \
       -i=[ibasedir]     # path to model output. e.g., /projects/NS9560K/noresm/cases \
       -o=[obasedir]     # path to cmorized output. e.g., /projects/NSxxxxK/CMIP6/cmorout (by default, set to ~/cmorout) \'
     exit
 else
     # set default values
     realization=1
     physics=1
     ibasedir=/projects/NS9560K/noresm/cases
     #obasedir=/projects/NS9034K/CMIP6/.cmorout
     obasedir=~/cmorout
     while test $# -gt 0; do
         case "$1" in
             -c=*)
                 casename=$(echo $1|sed -e 's/^[^=]*=//g')
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
             -y1=*)
                 year1=($(echo $1|sed -e 's/^[^=]*=//g'))
                 shift
                 ;;
             -y2=*)
                 yearn=($(echo $1|sed -e 's/^[^=]*=//g'))
                 shift
                 ;;
             -r=*)
                 realization=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             -p=*)
                 physics=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             -i=*)
                 ibasedir=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             -o=*)
                 obasedir=$(echo $1|sed -e 's/^[^=]*=//g')
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

#CMOR_ROOT=$(cd .. && pwd)
if [ -z $CMOR_ROOT ]; then
   echo "The environment variable CMOR_ROOT is NOT set. Set by:"
   echo "export CMOR_ROOT=/path/to/noresm2cmor/root in bash shell"
   echo "or"
   echo "setenv CMOR_ROOT /path/to/noresm2cmor/root in csh shell"
fi

cd $CMOR_ROOT/namelists/CMIP6_${model}/${expid}/
[ ! -d $version ] && mkdir $version

expnmltemp=$(ls template/exp*.nml |head -1)
cp $expnmltemp template/exp_${casename}.nml
sed -i "s/casename * = '.*',/casename      = '${casename}',/g" template/exp_${casename}.nml
sed -i "s/realization * = .*,/realization   = ${realization},/g" template/exp_${casename}.nml
sed -i "s/physics_version * = .*,/physics_version = ${physics},/g" template/exp_${casename}.nml
sed -i "s/year1 * = .*,/year1         = ${year1},/g" template/exp_${casename}.nml
sed -i "s/yearn * = .*,/yearn         = ${yearn},/g" template/exp_${casename}.nml

cp $CMOR_ROOT/namelists/sys_CMIP6_default.nml $version/sys.nml
cp $CMOR_ROOT/namelists/mod_CMIP6_${model}.nml $version/mod.nml
cp $CMOR_ROOT/namelists/var_CMIP6_NorESM2_default.nml $version/var.nml

sed -i "s~ibasedir * = '.*',~ibasedir      = '${ibasedir}',~g" ${version}/sys.nml
sed -i "s~obasedir * = '.*',~obasedir      = '${obasedir}',~g" ${version}/sys.nml
sed -i "s~griddata * = '.*',~griddata      = '/projects/NS9560K/cmor/griddata',~g" ${version}/sys.nml
sed -i "s/forcefilescan * = .*.,/forcefilescan = .false.,/g" ${version}/sys.nml

# update cmor_casename.sh
cp $CMOR_ROOT/workflow/cmor.template cmor_${casename}.sh
sed -i "s/^version=.*/version=${version}/" cmor_${casename}.sh
sed -i "s/^expid=.*[[:alnum:]_]$/expid=${expid}/" cmor_${casename}.sh
sed -i "s/^model=.*/model=${model}/" cmor_${casename}.sh
sed -i "s/^CaseName=.*/CaseName=${casename}/" cmor_${casename}.sh
sed -i "s/^real=.*/real=${realization}/" cmor_${casename}.sh
sed -i "s/^physics=.*/physics=${physics}/" cmor_${casename}.sh

year11=$year1
year12=$(( ($year1/10+1)*10  ))
year13=$(( $yearn/10*10-10   ))
year14=$(( $yearn/10*10      ))
year21=$(( $year1/10*10+9    ))
year22=$(( ($year1/10+1)*10+9))
year23=$(( $yearn/10*10-1    ))
year24=$yearn

sed -i "s/year11/$year11/" cmor_${casename}.sh
sed -i "s/year12/$year12/" cmor_${casename}.sh
sed -i "s/year13/$year13/" cmor_${casename}.sh
sed -i "s/year14/$year14/" cmor_${casename}.sh
sed -i "s/year21/$year21/" cmor_${casename}.sh
sed -i "s/year22/$year22/" cmor_${casename}.sh
sed -i "s/year23/$year23/" cmor_${casename}.sh
sed -i "s/year24/$year24/" cmor_${casename}.sh

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
echo -e "  cmor_${casename}.sh -m=${model} -e=${expid} -v=${version} &>cmor.log &"
echo -e "       "
echo -e " \e[1;mThen keep track on the overview log at:\e[0m"
echo -e "  ./cmor.log"
echo -e "       "
echo -e " \e[1;mAnd the detailed log under:\e[0m"
echo -e "  $CMOR_ROOT/logs/CMIP6_${model}/${expid}/$version"
echo -e "       "


