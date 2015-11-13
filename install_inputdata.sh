#!/bin/sh -e 

# print help information if input arguments are incorrect 
if [[ ! $1 || `echo $1 | head -1c` == '-' ]] 
then 
  echo "Usage: $0 <absolute path to folder where sample input data can be stored"
  echo 
  echo "Example: $0 /work/${USER}/cmor/inputdata"
  echo 
  exit
fi 

# create folder and cd 
PWDDIR=`pwd`
echo "Create $1 if it does not exist"
mkdir -p $1
echo "Change to $1" 
cd $1 

# fetch data
echo "Download input data sample" 
wget -N http://ns2345k.norstore.uio.no/cmor/inputdata/N20TRAERCN_f19_g16_01.tar

# unpack tar file
echo "Unpack tar file"
tar xf N20TRAERCN_f19_g16_01.tar
rm N20TRAERCN_f19_g16_01.tar

# create symbolic link 
echo "Place symbolic link to input data directory in run directory"
cd $PWDDIR/run
ln -sf $1 inputdata 
echo completed
