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
SCRIPTPATH=`readlink -f $0`
echo "Create $1 if it does not exist"
mkdir -p $1
echo "Change to $1" 
cd $1 

# fetch data
echo "Download grid data" 
BASEURL=http://ns2345k.norstore.uio.no/cmor/griddata
wget -qN $BASEURL/
for FILE in `cat index.html | grep "\.nc" | cut -d"\"" -f8`
do
  wget -c -N $BASEURL/$FILE
done
rm -f index.html 

# create symbolic link 
echo "Placed symbolic link to grid data directory in data directory of noresm2cmor."
cd `dirname $SCRIPTPATH`/../data
rm -rf griddata
ln -sf $1 griddata 
