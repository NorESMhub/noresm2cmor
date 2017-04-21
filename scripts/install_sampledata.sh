#!/bin/sh -e 

# print help information if input arguments are incorrect 
if [[ ! $1 || `echo $1 | head -1c` == '-' ]] 
then 
  echo "Usage: $0 <absolute path to folder where sample data can be stored"
  echo 
  echo "Example: $0 /work/${USER}/cmor/sampledata"
  echo 
  exit
fi 

# create folder and cd 
SCRIPTPATH=`readlink -f $0`
echo "Create $1 if it does not exist"
mkdir -p $1
echo "Change to $1" 
cd $1 

# fetch data
echo "Download sample data"
TARFILE=N20TRAERCN_f19_g16_01.tar.gz
wget -c -N http://ns2345k.norstore.uio.no/cmor/sampledata/$TARFILE

# unpack tar file
echo "Unpack tar file"
tar xf $TARFILE
rm $TARFILE

# create symbolic link 
echo "Placed symbolic link to sample data directory in data directory of noresm2cmor."
cd `dirname $SCRIPTPATH`/../data
ln -sf $1 sampledata 
