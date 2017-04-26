#!/bin/sh -e

### Customized parameters ######################################################
CASENAME=${1:-N1850AERCNOC_f19_g16_CTRL_02}
CMIPNAME=${2:-piControl}
YEAR1=${3:-0}          # set to 0 if all available years are to be processed
YEARN=${4:-99999}      # set to 99999 if all available years are to be processed
GROUP=${5:-ALL}        # selection of groups e.g. "MON-DAY"
FIELD=${6:-ALL}        # either "ALL" or a cmip variable name e.g. "sic"
BASEDIR=${7:-/norstore/project/norclim/noresm/cases}
CMIPDIR=${8:-/norstore/project/norclim/noresm/cmor}
################################################################################

# Derived parameters 
ROOTDIR=`dirname $0`/..
WORKDIR=${ROOTDIR}/run_wrapper/work_${CMIPNAME}_${CASENAME}_ice_${YEAR1}-${YEARN}_${GROUP}_${FIELD} 

# Accumulation intervals in years 
ACCMON=300
ACCDAY=10

# Load modules 
module load netcdf udunits

# Create dirs and change to work dir 
mkdir -p $WORKDIR $CMIPDIR
cd $WORKDIR

# Prepare input namelist 
rm -f cice2cmor_template.nml 
echo "/ibasedir/s/=.*/= '"`echo ${BASEDIR} | sed -e 'y/\//:/'`"',/" > sedcmd
echo "/obasedir/s/=.*/= '"`echo ${CMIPDIR} | sed -e 'y/\//:/'`"',/" >> sedcmd
echo "y/:/\//" >> sedcmd 
echo "/verbose/s/=.*/= .true.,/" >> sedcmd
cat $ROOTDIR/namelist/glb_cice2cmor.nml | sed -f sedcmd  >> cice2cmor_template.nml
echo >> cice2cmor_template.nml
echo >> cice2cmor_template.nml
cat $ROOTDIR/namelist/exp_${CMIPNAME}.nml | sed \
  -e "/casename/s/=.*/= '${CASENAME}',/" >> cice2cmor_template.nml 
echo >> cice2cmor_template.nml
echo >> cice2cmor_template.nml
if [ $FIELD == "ALL" ] 
then 
  cat $ROOTDIR/namelist/var_cice2cmor.nml | sed \
  -e "s/\!\!/\ \ /g" >> cice2cmor_template.nml 
else
  cat $ROOTDIR/namelist/var_cice2cmor.nml | sed \
  -e "/'${FIELD}[ ']/s/\!\!/\ \ /g" >> cice2cmor_template.nml 
fi

# Auxillary function to determine first and last year for output group $1
set_time_range() 
{
  YEAR11=`ls $BASEDIR/$CASENAME/ice/hist | grep "\.$1\." | \
            cut -d. -f4 | cut -d"-" -f1 | head -1`
  if [ -z $YEAR11 ]
  then
    YEAR11=99999
  elif [ $YEAR11 -lt $YEAR1 ]
  then
    YEAR11=$YEAR1
  fi
  #
  YEARNN=`ls $BASEDIR/$CASENAME/ice/hist | grep "\.$1\." | \
            cut -d. -f4 | cut -d"-" -f1 | tail -2 | head -1`
  if [ -z $YEARNN ]
  then
    YEARNN=0
  elif [ $YEARNN -gt $YEARN ]
  then
    YEARNN=$YEARN
  fi
  #
  Y1=$YEAR11
  # 
  if [ $YEAR11 -eq $YEARNN ]
  then
    M1=`ls $BASEDIR/$CASENAME/atm/hist | grep "\.$1\." | grep "\.${YEARNN}" | \
          cut -d. -f4 | cut -d"-" -f2 | head -1`
    M2=`ls $BASEDIR/$CASENAME/atm/hist | grep "\.$1\." | grep "\.${YEARNN}" | \
          cut -d. -f4 | cut -d"-" -f2 | tail -1`
  else
    M1=01
    M2=12
  fi
} 

# Process monthly data 
if [ $GROUP == "ALL" ] || [ `echo $GROUP | grep MON` ] 
then  
  set_time_range h
  echo "Process monthly data for the years "${YEAR11}-${YEARNN}
  while [ $Y1 -le $YEARNN ] 
  do 
    YN=`expr $Y1 + $ACCMON - 1`
    if [ $YN -gt $YEARNN ] 
    then 
      YN=$YEARNN
    fi 
    # customize namelist 
    cat cice2cmor_template.nml | sed \
      -e "/year1/s/=.*/= $Y1,/"      \
      -e "/yearn/s/=.*/= $YN,/"      \
      -e "/month1/s/=.*/= $M1,/"     \
      -e "/monthn/s/=.*/= $M2,/"     \
      -e "/do_omon/s/=.*/= .true.,/" \
      -e "/do_oimon/s/=.*/= .true.,/" > cice2cmor.nml 
    # run cmor 
    $ROOTDIR/bin/cice2cmor 2>&1   
    Y1=`expr $Y1 + $ACCMON`
  done 
fi 

# Process daily data 
if [ $GROUP == "ALL" ] || [ `echo $GROUP | grep DAY` ] 
then  
  set_time_range h1
  echo "Process daily data for the years "${YEAR11}-${YEARNN}
  while [ $Y1 -le $YEARNN ] 
  do
    YN=`expr $Y1 + $ACCDAY - 1`
    if [ $YN -gt $YEARNN ]
    then
      YN=$YEARNN
    fi
    # customize namelist 
    cat cice2cmor_template.nml | sed \
      -e "/year1/s/=.*/= $Y1,/"      \
      -e "/yearn/s/=.*/= $YN,/"      \
      -e "/month1/s/=.*/= $M1,/"     \
      -e "/monthn/s/=.*/= $M2,/"     \
      -e "/do_day/s/=.*/= .true.,/" > cice2cmor.nml
    # run cmor 
    $ROOTDIR/bin/cice2cmor 2>&1
    Y1=`expr $Y1 + $ACCDAY`
  done
fi 

# Remove work directory 
cd .. 
rm -rf $WORKDIR
