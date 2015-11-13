#!/bin/sh -e 

# print help information if input arguments are incorrect 
if [[ ! $1 || `echo $1 | head -1c` == '-' ]] 
then 
  echo "Usage: $0 <absolute path to folder where the grid data can be stored"
  echo 
  echo "Example: $0 /work/${USER}/cmor/griddata"
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
echo "Download grid data" 
wget -N http://ns2345k.norstore.uio.no/cmor/griddata/wget_all.sh 
chmod +x wget_all.sh
./wget_all.sh

# remove wget script
rm wget_all.sh

# create symbolic link 
echo "Place symbolic link to grid data directory in run directory"
cd $PWDDIR/run
ln -sf $1 griddata 
echo completed
