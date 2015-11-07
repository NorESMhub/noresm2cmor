#!/bin/sh -evx

### Customized parameters ######################################################
CASENAME=${1:-N1850AERCNOC_f19_g16_CTRL_02}
CMIPNAME=${2:-piControl}
YEAR1=${3:-0}          # set to 0 if all available years are to be processed
YEARN=${4:-99999}      # set to 99999 if all available years are to be processed
GROUP=${5:-ALL}        # selection of groups "ALL"="M3D-M2D-D3D-D2D-6HY-6PL-62D-3HR"
FIELD=${6:-ALL}        # either "ALL" or a cmip variable name e.g. "tas"
BASEDIR=${7:-/projects/NS2345K/noresm/cases}
CMIPDIR=${8:-/projects/NS9034K}
################################################################################

# Derived parameters 
ROOTDIR=`dirname $0`/..
WORKDIR=${ROOTDIR}/run_wrapper/work_${CMIPNAME}_${CASENAME}_atm_${YEAR1}-${YEARN}_${GROUP}_${FIELD}

# Accumulation intervals in years (6HY: set 0 for six-month) 
ACCATMM3D=100 # ok 
ACCATMM2D=500 # ok 
ACCATMD3D=10  # ok 
ACCATMD2D=50  # ok 
ACCATM6HY=0   # ok 
ACCATM6PL=5   # ok 
ACCATM62D=10  # ok 
ACCATM3HR=10  # ok 

# Set appropriate accumulations periods if run with NorESM1-ME
if [ `echo $CMIPNAME | grep "_1me" | wc -l` -gt 0 ] 
then 
  ACCDAY='year' 
  ACC6HR='year' 
  ACC3HR='year'
else
  ACCDAY='month' 
  ACC6HR='month' 
  ACC3HR='month'
fi

# Check for sub-annual periods 
if [ $ACCATM6HY -eq 0 ] 
then 
  SPLITYEAR=1
  ACCATM6HY=1
else 
  SPLITYEAR=0
fi

# Check group 
#if [ ! "`id | cut -d"(" -f3 | cut -d")" -f1`" == "norclim" ] 
#then
#  echo "Please set group to norclim" 
#  exit
#fi 

# Load modules 
#module load netcdf udunits

# Create dirs and change to work dir 
mkdir -p $WORKDIR $CMIPDIR
cd $WORKDIR

# Prepare input namelist 
rm -f cam2cmor_template.nml 
echo "/ibasedir/s/=.*/= '"`echo ${BASEDIR} | sed -e 'y/\//:/'`"',/" > sedcmd
echo "/obasedir/s/=.*/= '"`echo ${CMIPDIR} | sed -e 'y/\//:/'`"',/" >> sedcmd
echo "y/:/\//" >> sedcmd 
echo "/verbose/s/=.*/= .true.,/" >> sedcmd
cat $ROOTDIR/namelist/glb_cam2cmor.nml | sed -f sedcmd  >> cam2cmor_template.nml
echo >> cam2cmor_template.nml
echo >> cam2cmor_template.nml
cat $ROOTDIR/namelist/exp_${CMIPNAME}.nml | sed \
  -e "/casename/s/=.*/= '${CASENAME}',/" >> cam2cmor_template.nml 
echo >> cam2cmor_template.nml
echo >> cam2cmor_template.nml
if [ $FIELD == "ALL" ] 
then 
  cat $ROOTDIR/namelist/var_cam2cmor.nml | sed \
  -e "s/\!\!/\ \ /g" >> cam2cmor_template.nml 
else
  cat $ROOTDIR/namelist/var_cam2cmor.nml | sed \
  -e "/'${FIELD}[ ']/s/\!\!/\ \ /g" >> cam2cmor_template.nml 
fi

# Auxillary function to determine first and last year for output group $1
set_time_range() 
{
  YEAR11=`ls $BASEDIR/$CASENAME/atm/hist | grep "\.$1\." | \
            cut -d. -f4 | cut -d"-" -f1 | head -1`
  if [ -z $YEAR11 ]
  then
    YEAR11=99999
  elif [ $YEAR11 -lt $YEAR1 ]
  then
    YEAR11=$YEAR1
  fi
  #
  YEARNN=`ls $BASEDIR/$CASENAME/atm/hist | grep "\.$1\." | \
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

# Process monthly 3d data 
if [ $GROUP == "ALL" ] || [ `echo $GROUP | grep FX` ]
then  
  set_time_range h0
  # customize namelist 
  cat cam2cmor_template.nml | sed \
    -e "/year1/s/=.*/= $YEAR11,/"   \
    -e "/yearn/s/=.*/= $YEAR11,/"   \
    -e "/month1/s/=.*/= $M1,/"   \
    -e "/monthn/s/=.*/= $M1,/"   \
    -e "/do_2d/s/=.*/= .true.,/"  \
    -e "/do_fx/s/=.*/= .true.,/" > cam2cmor.nml
  # run cmor 
  $ROOTDIR/bin/cam2cmor 2>&1
fi 

# Process monthly 3d data 
if [ $GROUP == "ALL" ] || [ `echo $GROUP | grep M3D` ] 
then  
  set_time_range h0
  echo "Process monthly 3d data for the years "${YEAR11}-${YEARNN}
  while [ $Y1 -le $YEARNN ] 
  do 
    YN=`expr $Y1 + $ACCATMM3D - 1`
    if [ $YN -gt $YEARNN ] 
    then 
      YN=$YEARNN
    fi 
    # customize namelist 
    cat cam2cmor_template.nml | sed \
      -e "/year1/s/=.*/= $Y1,/"   \
      -e "/yearn/s/=.*/= $YN,/"   \
      -e "/month1/s/=.*/= $M1,/"  \
      -e "/monthn/s/=.*/= $M2,/"  \
      -e "/do_3d/s/=.*/= .true.,/"  \
      -e "/do_aero/s/=.*/= .true.,/"  \
      -e "/do_amon/s/=.*/= .true.,/" > cam2cmor.nml 
    # run cmor 
    $ROOTDIR/bin/cam2cmor 2>&1   
    Y1=`expr $Y1 + $ACCATMM3D`
  done 
fi 

# Process monthly 2d data
if [ $GROUP == "ALL" ] || [ `echo $GROUP | grep M2D` ] 
then  
  set_time_range h0
  echo "Process monthly 2d data for the years "${YEAR11}-${YEARNN}
  while [ $Y1 -le $YEARNN ] 
  do
    YN=`expr $Y1 + $ACCATMM2D - 1`
    if [ $YN -gt $YEARNN ]
    then
      YN=$YEARNN
    fi
    # customize namelist 
    cat cam2cmor_template.nml | sed \
      -e "/year1/s/=.*/= $Y1,/"   \
      -e "/yearn/s/=.*/= $YN,/"   \
      -e "/month1/s/=.*/= $M1,/"  \
      -e "/monthn/s/=.*/= $M2,/"  \
      -e "/do_2d/s/=.*/= .true.,/"  \
      -e "/do_aero/s/=.*/= .true.,/"  \
      -e "/do_amon/s/=.*/= .true.,/" > cam2cmor.nml
    # run cmor 
    $ROOTDIR/bin/cam2cmor 2>&1
    Y1=`expr $Y1 + $ACCATMM2D`
  done
fi 

# Process daily 3d data 
if [ $GROUP == "ALL" ] || [ `echo $GROUP | grep D3D` ] 
then  
  set_time_range h1
  echo "Process daily 3d data for the years "${YEAR11}-${YEARNN}
  while [ $Y1 -le $YEARNN ] 
  do
    YN=`expr $Y1 + $ACCATMD3D - 1`
    if [ $YN -gt $YEARNN ]
    then
      YN=$YEARNN
    fi
    # customize namelist 
    cat cam2cmor_template.nml | sed \
      -e "/year1/s/=.*/= $Y1,/"   \
      -e "/yearn/s/=.*/= $YN,/"   \
      -e "/month1/s/=.*/= $M1,/"  \
      -e "/monthn/s/=.*/= $M2,/"  \
      -e "/do_3d/s/=.*/= .true.,/"  \
      -e "/do_day/s/=.*/= .true.,/" > cam2cmor.nml
    # run cmor 
    $ROOTDIR/bin/cam2cmor 2>&1
    Y1=`expr $Y1 + $ACCATMD3D`
  done
fi 

# Process daily 2d data 
if [ $GROUP == "ALL" ] || [ `echo $GROUP | grep D2D` ] 
then  
  set_time_range h1
  echo "Process daily 2d data for the years "${YEAR11}-${YEARNN}
  while [ $Y1 -le $YEARNN ] 
  do
    YN=`expr $Y1 + $ACCATMD2D - 1`
    if [ $YN -gt $YEARNN ]
    then
      YN=$YEARNN
    fi
    # customize namelist 
    cat cam2cmor_template.nml | sed \
      -e "/year1/s/=.*/= $Y1,/"   \
      -e "/yearn/s/=.*/= $YN,/"   \
      -e "/month1/s/=.*/= $M1,/"  \
      -e "/monthn/s/=.*/= $M2,/"  \
      -e "/do_2d/s/=.*/= .true.,/"  \
      -e "/do_day/s/=.*/= .true.,/" > cam2cmor.nml
    # run cmor 
    $ROOTDIR/bin/cam2cmor 2>&1  
    Y1=`expr $Y1 + $ACCATMD2D`
  done
fi 

# Process six-hourly data on model levels
if [ $GROUP == "ALL" ] || [ `echo $GROUP | grep 6HY` ] 
then  
  set_time_range h2
  echo "Process six-hourly hybrid data for the years "${YEAR11}-${YEARNN}
  while [ $Y1 -le $YEARNN ] 
  do
    YN=`expr $Y1 + $ACCATM6HY - 1`
    if [ $YN -gt $YEARNN ]
    then 
      YN=$YEARNN
    fi
    # split year if requested 
    if [ $SPLITYEAR -eq 1 ] & [ ! $M1 -eq $M2 ]
    then 
      # customize namelist 
      cat cam2cmor_template.nml | sed \
        -e "/year1/s/=.*/= $Y1,/"     \
        -e "/yearn/s/=.*/= $YN,/"     \
        -e "/month1/s/=.*/= 1,/"      \
        -e "/monthn/s/=.*/= 6,/"      \
        -e "/do_3d/s/=.*/= .true.,/"  \
        -e "/do_2d/s/=.*/= .false.,/"  \
        -e "/do_6hrlev/s/=.*/= .true.,/" > cam2cmor.nml
      # run cmor 
      $ROOTDIR/bin/cam2cmor 2>&1  
     cat cam2cmor_template.nml | sed \
        -e "/year1/s/=.*/= $Y1,/"     \
        -e "/yearn/s/=.*/= $YN,/"     \
        -e "/month1/s/=.*/= 7,/"      \
        -e "/monthn/s/=.*/=12,/"      \
        -e "/do_3d/s/=.*/= .true.,/"  \
        -e "/do_2d/s/=.*/= .false.,/"  \
        -e "/do_6hrlev/s/=.*/= .true.,/" > cam2cmor.nml
      # run cmor 
      $ROOTDIR/bin/cam2cmor 2>&1
    else
      cat cam2cmor_template.nml | sed \
        -e "/year1/s/=.*/= $Y1,/"     \
        -e "/yearn/s/=.*/= $YN,/"     \
        -e "/month1/s/=.*/= $M1,/"  \
        -e "/monthn/s/=.*/= $M2,/"  \
        -e "/do_3d/s/=.*/= .true.,/"  \
        -e "/do_2d/s/=.*/= .false.,/"  \
        -e "/do_6hrlev/s/=.*/= .true.,/" > cam2cmor.nml
    fi
    Y1=`expr $Y1 + $ACCATM6HY`
  done
fi 

# Process six-hourly data on pressure levels
if [ $GROUP == "ALL" ] || [ `echo $GROUP | grep 6PL` ] 
then  
  set_time_range h2
  echo "Process six-hourly plev data for the years "${YEAR11}-${YEARNN}
  while [ $Y1 -le $YEARNN ] 
  do
    YN=`expr $Y1 + $ACCATM6PL - 1`
    if [ $YN -gt $YEARNN ]
    then
      YN=$YEARNN
    fi
    # customize namelist 
    cat cam2cmor_template.nml | sed \
      -e "/year1/s/=.*/= $Y1,/"   \
      -e "/yearn/s/=.*/= $YN,/"   \
      -e "/month1/s/=.*/= $M1,/"  \
      -e "/monthn/s/=.*/= $M2,/"  \
      -e "/do_3d/s/=.*/= .true.,/"  \
      -e "/do_2d/s/=.*/= .false.,/"  \
      -e "/do_6hrplev/s/=.*/= .true.,/" > cam2cmor.nml
    # run cmor 
    $ROOTDIR/bin/cam2cmor 2>&1  
    Y1=`expr $Y1 + $ACCATM6PL`
  done
fi 

# Process 2d six-hourly data 
if [ $GROUP == "ALL" ] || [ `echo $GROUP | grep 62D` ]
then  
  set_time_range h2
  echo "Process six-hourly plev data for the years "${YEAR11}-${YEARNN}
  while [ $Y1 -le $YEARNN ] 
  do
    YN=`expr $Y1 + $ACCATM62D - 1`
    if [ $YN -gt $YEARNN ]
    then 
      YN=$YEARNN
    fi
    # customize namelist 
    cat cam2cmor_template.nml | sed \
      -e "/year1/s/=.*/= $Y1,/"   \
      -e "/yearn/s/=.*/= $YN,/"   \
      -e "/month1/s/=.*/= $M1,/"  \
      -e "/monthn/s/=.*/= $M2,/"  \
      -e "/do_3d/s/=.*/= .false.,/"  \
      -e "/do_2d/s/=.*/= .true.,/"  \
      -e "/do_6hrlev/s/=.*/= .true.,/" \
      -e "/do_6hrplev/s/=.*/= .true.,/" > cam2cmor.nml
    # run cmor 
    $ROOTDIR/bin/cam2cmor 2>&1
    Y1=`expr $Y1 + $ACCATM62D`
  done
fi 

# Process three-hourly data
if [ $GROUP == "ALL" ] || [ `echo $GROUP | grep 3HR` ] 
then  
  set_time_range h3
  echo "Process three-hourly data for the years "${YEAR11}-${YEARNN}
  while [ $Y1 -le $YEARNN ] 
  do
    YN=`expr $Y1 + $ACCATM3HR - 1`
    if [ $YN -gt $YEARNN ]
    then
      YN=$YEARNN
    fi
    # customize namelist 
    cat cam2cmor_template.nml | sed \
      -e "/year1/s/=.*/= $Y1,/"   \
      -e "/yearn/s/=.*/= $YN,/"   \
      -e "/month1/s/=.*/= $M1,/"  \
      -e "/monthn/s/=.*/= $M2,/"  \
      -e "/do_2d/s/=.*/= .true.,/"  \
      -e "/do_3hri/s/=.*/= .true.,/"  \
      -e "/do_3hr/s/=.*/= .true.,/" > cam2cmor.nml
    # run cmor 
    $ROOTDIR/bin/cam2cmor 2>&1  
    Y1=`expr $Y1 + $ACCATM3HR`
  done
fi 

# Remove work directory 
cd .. 
rm -rf $WORKDIR
