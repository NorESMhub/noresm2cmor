#!/bin/sh -e

# print help information if input arguments are incorrect 
if [[ ! $1 || `echo $1 | head -1c` == '-' ]]
then
  echo "Usage: $0 <absolute path to case folder> <start year> <end year> "
  echo 
  echo "Example: $0 /projects/NS2345K/www/cmor/sampledata/N20TRAERCN_f19_g16_01 2000 2000"
  echo 
  exit
fi

# set path information etc
CASENAME=`basename $1` 
CMORHOME=`dirname \`readlink -f $0\``/..
GRIDDATA=${GRIDDATA:-$CMORHOME/data/griddata}
CMOROUT=${CMOROUT:-$CMORHOME/data/cmorout/$USER}  
OUTPATH=${OUTPATH:-${CMOROUT}/${CASENAME}.$2-$3}  

# create output path and cd 
mkdir -p $OUTPATH 
cd $OUTPATH 

# prepare input namelist for noresm2cmor
cp -f $CMORHOME/namelists/noresm2cmor_NorESM_GENERIC_template.nml noresm2cmor.in 
sed -i "s/model_id      = .*/model_id      = '${CASENAME}',/" noresm2cmor.in  
sed -i "s/casename      = .*/casename      = '${CASENAME}',/" noresm2cmor.in  
sed -i "s%ibasedir      = .*%ibasedir      = '`dirname $1`',%" noresm2cmor.in  
sed -i "s%obasedir      = .*%obasedir      = '.',%" noresm2cmor.in  
sed -i "s%griddata      = .*%griddata      = '${GRIDDATA}',%" noresm2cmor.in  
sed -i "s%tabledir      = .*%tabledir      = '$CMORHOME/tables',%" noresm2cmor.in  
sed -i "s/year1         = .*/year1         = $2,/" noresm2cmor.in  
sed -i "s/yearn         = .*/yearn         = $3,/" noresm2cmor.in  
### CAM file names different in CESM1 and CESM2  
if [ `ls $1/atm/hist | head | grep cam2 | wc -l` -gt 0 ]
then
  sed -i "s/tagamon       = .*/tagamon       = 'cam2.h0',/" noresm2cmor.in  
  sed -i "s/tagaday       = .*/tagaday       = 'cam2.h1',/" noresm2cmor.in  
  sed -i "s/taga6hr       = .*/taga6hr       = 'cam2.h2',/" noresm2cmor.in  
  sed -i "s/taga3hr       = .*/taga3hr       = 'cam2.h3',/" noresm2cmor.in  
  sed -i "s/taga3hri      = .*/taga3hri      = 'cam2.h4',/" noresm2cmor.in  
else
  sed -i "s/tagamon       = .*/tagamon       = 'cam.h0',/" noresm2cmor.in  
  sed -i "s/tagaday       = .*/tagaday       = 'cam.h1',/" noresm2cmor.in  
  sed -i "s/taga6hr       = .*/taga6hr       = 'cam.h2',/" noresm2cmor.in  
  sed -i "s/taga3hr       = .*/taga3hr       = 'cam.h3',/" noresm2cmor.in  
  sed -i "s/taga3hri      = .*/taga3hri      = 'cam.h4',/" noresm2cmor.in  
fi 
### check output resolution and specify grid data accordingly 
if [ `ls $1/ocn/hist | wc -l` -gt 0 ] 
then 
  OCNFILE=$1/ocn/hist/`ls $1/ocn/hist | grep micom | head -1`
  OCNXDIM=`ncdump -h $OCNFILE | sed -n '/x =/p' | head -1 | cut -d"=" -f2 | cut -d";" -f1` 
  case `echo $OCNXDIM` in 
    320) OCNGRID=gx1v6 ;; 
    360) OCNGRID=tnx1v1 ;; 
    1440) OCNGRID=tnx0.25v1 ;; 
    *) OCNGRID=unknown ;; 
  esac
else 
  OCNGRID=gx1v6
fi
if [ `ls $1/atm/hist | wc -l` -gt 0 ]
then
  ATMFILE=$1/atm/hist/`ls $1/atm/hist | grep cam | head -1`
  ATMXDIM=`ncdump -h $ATMFILE | sed -n '/lat =/p' | head -1 | cut -d"=" -f2 | cut -d";" -f1`
  case `echo $ATMXDIM` in
    96) ATMGRID=1.9x2.5 ;;
    192) ATMGRID=0.9x1.25 ;;
    *) ATMGRID=unknown ;;
  esac
else
  ATMGRID=unknown
fi
sed -i "s/atmgridfile   = .*/atmgridfile   = 'grid_atm_${ATMGRID}_${OCNGRID}.nc',/" noresm2cmor.in
sed -i "s/ocngridfile   = .*/ocngridfile   = 'grid_${OCNGRID}.nc',/" noresm2cmor.in
sed -i "s/ocninitfile   = .*/ocninitfile   = 'inicon_${OCNGRID}.nc',/" noresm2cmor.in
sed -i "s/ocnmertfile   = .*/ocnmertfile   = 'mertraoceans_${OCNGRID}.dat',/" noresm2cmor.in
sed -i "s/secindexfile  = .*/secindexfile  = 'secindex_${OCNGRID}.dat',/" noresm2cmor.in
if [ ! -e $GRIDDATA/grid_atm_${ATMGRID}_${OCNGRID}.nc ] 
then 
  sed -i "s/dfx           = .*/dfx           = .false.,/" noresm2cmor.in
fi 
### check if grid data is present  
for ITEM in grid inicon 
do
  if [ ! -e $GRIDDATA/${ITEM}_${OCNGRID}.nc ]
  then
    echo "Cannot find $GRIDDATA/${ITEM}_${OCNGRID}.nc. Continue? [y/n]" 
    read $ANSWER
    if [ $ANSWER == 'n' ]
    then 
      exit
    fi   
  fi
done 
for ITEM in mertraoceans secindex
do
  if [ ! -e $GRIDDATA/${ITEM}_${OCNGRID}.dat ]
  then
    echo "Cannot find $GRIDDATA/${ITEM}_${OCNGRID}.dat. Continue? [y/n]" 
    read $ANSWER
    if [ $ANSWER == 'n' ]
    then
      exit
    fi
  fi
done 

# load modules required for running noresm2cmor on norstore
if [ `uname -n | grep norstore | wc -l` -gt 0 ] 
then 
  . /usr/share/Modules/init/sh
  module unload netcdf gcc hdf 
  module load gcc/4.7.2
fi 

# cmor-ize 
echo "Output written to ${OUTPATH}" 
echo "Namelist written to ${OUTPATH}/noresm2cmor.in" 
echo "Log written to ${OUTPATH}/noresm2cmor.log" 
$CMORHOME/bin/noresm2cmor noresm2cmor.in >& $OUTPATH/noresm2cmor.log 

# change group permissions 
chmod g+w ${OUTPATH} *
