#!/bin/sh -evx

### Customized parameters ######################################################
CASENAME=${1:-N1850AERCNOC_f19_g16_CTRL_02}
CMIPNAME=${2:-piControl}
YEAR1=${3:-0}          # set to 0 if all available years are to be processed
YEARN=${4:-99999}      # set to 99999 if all available years are to be processed
GROUP=${5:-ALL}        # selection of groups e.g. "FX-ANN-M3D-MXD-DAY-BGC"
FIELD=${6:-ALL}        # either "ALL" or a cmip variable name e.g. "tos"
BASEDIR=${7:-/projects/NS2345K/noresm/cases}
CMIPDIR=${8:-/projects/NS9034K}
FILLDAY=${9:-false}
################################################################################

# Derived parameters 
ROOTDIR=`dirname $0`/..
WORKDIR=${ROOTDIR}/run_wrapper/work_${CMIPNAME}_${CASENAME}_ocn_${YEAR1}-${YEARN}_${GROUP}_${FIELD} 

# Accumulation intervals in years 
ACCANN=50
ACCM3D=4
ACCMXD=300
ACCDAY=1

# Load modules 
module load netcdf udunits

# Create dirs and change to work dir 
mkdir -p $WORKDIR $CMIPDIR
cd $WORKDIR

# set bgc flag
if [ `echo $GROUP | grep BGC` ] || [ `echo $GROUP | grep ALL` ] 
then 
  BGCFLAG=.true.
else 
  BGCFLAG=.false.
fi

# Prepare input namelist 
rm -f micom2cmor_template.nml 
echo "/ibasedir/s/=.*/= '"`echo ${BASEDIR} | sed -e 'y/\//:/'`"',/" > sedcmd
echo "/obasedir/s/=.*/= '"`echo ${CMIPDIR} | sed -e 'y/\//:/'`"',/" >> sedcmd
echo "y/:/\//" >> sedcmd 
echo "/verbose/s/=.*/= .true.,/" >> sedcmd
if [ $FILLDAY == true ] || [ $FILLDAY == TRUE ] || [ $FILLDAY == FILLDAY ] 
then 
  echo "/add_fill_day/s/=.*/= .true./" >> sedcmd 
fi
cat $ROOTDIR/namelist/glb_micom2cmor.nml | sed -f sedcmd  >> micom2cmor_template.nml
echo >> micom2cmor_template.nml
echo >> micom2cmor_template.nml
cat $ROOTDIR/namelist/exp_${CMIPNAME}.nml | sed \
  -e "/casename/s/=.*/= '${CASENAME}',/" >> micom2cmor_template.nml 
echo >> micom2cmor_template.nml
echo >> micom2cmor_template.nml
if [ $FIELD == "ALL" ] 
then 
  cat $ROOTDIR/namelist/var_micom2cmor.nml | sed \
  -e "s/\!\!/\ \ /g" >> micom2cmor_template.nml 
else
  cat $ROOTDIR/namelist/var_micom2cmor.nml | sed \
  -e "/'${FIELD}[ ']/s/\!\!/\ \ /g" >> micom2cmor_template.nml 
fi

# Auxillary function to determine first and last year for output group $1
set_time_range() 
{
  YEAR11=`ls $BASEDIR/$CASENAME/ocn/hist | grep $CASENAME | grep "\.$1\." | \
            cut -d. -f4 | cut -d"-" -f1 | head -1`
  if [ -z $YEAR11 ]
  then
    YEAR11=99999
  elif [ $YEAR11 -lt $YEAR1 ]
  then
    YEAR11=$YEAR1
  fi
  #
  YEARNN=`ls $BASEDIR/$CASENAME/ocn/hist | grep $CASENAME | grep "\.$1\." | \
            cut -d. -f4 | cut -d"-" -f1 | tail -1`
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
    M1=`ls $BASEDIR/$CASENAME/atm/hist | grep $CASENAME | grep "\.$1\." | grep "\.${YEARNN}" | \
          cut -d. -f4 | cut -d"-" -f2 | head -1`
    M2=`ls $BASEDIR/$CASENAME/atm/hist | grep $CASENAME | grep "\.$1\." | grep "\.${YEARNN}" | \
          cut -d. -f4 | cut -d"-" -f2 | tail -1`
  else
    M1=01
    M2=12
  fi
} 

# Process fixed data 
if [ $GROUP == "ALL" ] || [ `echo $GROUP | grep FX` ]
then
  set_time_range hm
  cat micom2cmor_template.nml | sed \
    -e "/year1/s/=.*/= $YEAR11,/"   \
    -e "/yearn/s/=.*/= $YEAR11,/"   \
    -e "/month1/s/=.*/= $M1,/"     \
    -e "/monthn/s/=.*/= $M2,/"     \
    -e "/do_bgc/s/=.*/= $BGCFLAG,/"   \
    -e "/do_3d/s/=.*/= .true.,/"   \
    -e "/do_xd/s/=.*/= .true.,/"   \
    -e "/do_fx/s/=.*/= .true.,/" > micom2cmor.nml
  # run cmor
  $ROOTDIR/bin/micom2cmor 2>&1
fi

# Process yearly data
if [ $GROUP == "ALL" ] || [ `echo $GROUP | grep ANN` ]
then
  set_time_range hm
  echo "Process monthly data for the years "${YEAR11}-${YEARNN}
  while [ $Y1 -le $YEARNN ] 
  do
    YN=`expr $Y1 + $ACCANN - 1`
    if [ $YN -gt $YEARNN ]
    then
      YN=$YEARNN
    fi
    # customize namelist 
    cat micom2cmor_template.nml | sed \
      -e "/year1/s/=.*/= $Y1,/"   \
      -e "/yearn/s/=.*/= $YN,/"   \
      -e "/month1/s/=.*/= $M1,/"     \
      -e "/monthn/s/=.*/= $M2,/"     \
      -e "/do_bgc/s/=.*/= $BGCFLAG,/"   \
      -e "/do_2d/s/=.*/= .true.,/"   \
      -e "/do_3d/s/=.*/= .true.,/"   \
      -e "/do_xd/s/=.*/= .false.,/"   \
      -e "/do_oyr/s/=.*/= .true.,/" > micom2cmor.nml
    # run cmor 
    $ROOTDIR/bin/micom2cmor 2>&1
    Y1=`expr $Y1 + $ACCANN`
  done
fi


# Process monthly 3d data 
if [ $GROUP == "ALL" ] || [ `echo $GROUP | grep M3D` ] 
then  
  set_time_range hm
  echo "Process monthly data for the years "${YEAR11}-${YEARNN}
  while [ $Y1 -le $YEARNN ] 
  do 
    YN=`expr $Y1 + $ACCM3D - 1`
    if [ $YN -gt $YEARNN ] 
    then 
      YN=$YEARNN
    fi 
    # customize namelist 
    cat micom2cmor_template.nml | sed \
      -e "/year1/s/=.*/= $Y1,/"   \
      -e "/yearn/s/=.*/= $YN,/"   \
      -e "/month1/s/=.*/= $M1,/"     \
      -e "/monthn/s/=.*/= $M2,/"     \
      -e "/do_bgc/s/=.*/= $BGCFLAG,/"   \
      -e "/do_3d/s/=.*/= .true.,/"   \
      -e "/do_xd/s/=.*/= .false.,/"   \
      -e "/do_omon/s/=.*/= .true.,/" > micom2cmor.nml 
    # run cmor 
    $ROOTDIR/bin/micom2cmor 2>&1   
    Y1=`expr $Y1 + $ACCM3D`
  done 
fi


# Process monthly data except 3d  
if [ $GROUP == "ALL" ] || [ `echo $GROUP | grep MXD` ]
then
  set_time_range hm
  echo "Process monthly data for the years "${YEAR11}-${YEARNN}
  while [ $Y1 -le $YEARNN ]
  do
    YN=`expr $Y1 + $ACCMXD - 1`
    if [ $YN -gt $YEARNN ]
    then
      YN=$YEARNN
    fi
    # customize namelist 
    cat micom2cmor_template.nml | sed \
      -e "/year1/s/=.*/= $Y1,/"   \
      -e "/yearn/s/=.*/= $YN,/"   \
      -e "/month1/s/=.*/= $M1,/"     \
      -e "/monthn/s/=.*/= $M2,/"     \
      -e "/do_bgc/s/=.*/= $BGCFLAG,/"   \
      -e "/do_3d/s/=.*/= .false.,/"   \
      -e "/do_xd/s/=.*/= .true.,/"   \
      -e "/do_omon/s/=.*/= .true.,/" > micom2cmor.nml
    # run cmor 
    $ROOTDIR/bin/micom2cmor 2>&1
    Y1=`expr $Y1 + $ACCMXD`
  done
fi
 
# Process daily data 
if [ $GROUP == "ALL" ] || [ `echo $GROUP | grep DAY` ] 
then  
  set_time_range hd
  echo "Process daily data for the years "${YEAR11}-${YEARNN}
  while [ $Y1 -le $YEARNN ] 
  do
    YN=`expr $Y1 + $ACCDAY - 1`
    if [ $YN -gt $YEARNN ]
    then
      YN=$YEARNN
    fi
    # customize namelist 
    cat micom2cmor_template.nml | sed \
      -e "/year1/s/=.*/= $Y1,/"   \
      -e "/yearn/s/=.*/= $YN,/"   \
      -e "/month1/s/=.*/= $M1,/"     \
      -e "/monthn/s/=.*/= $M2,/"     \
      -e "/do_bgc/s/=.*/= $BGCFLAG,/"   \
      -e "/do_3d/s/=.*/= .true.,/"   \
      -e "/do_xd/s/=.*/= .true.,/"   \
      -e "/do_day/s/=.*/= .true.,/" > micom2cmor.nml
    # run cmor 
    $ROOTDIR/bin/micom2cmor 2>&1
    Y1=`expr $Y1 + $ACCDAY`
  done
fi 

# Remove work directory 
cd ..
rm -rf $WORKDIR
