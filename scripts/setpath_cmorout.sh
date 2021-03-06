#!/bin/sh -e 

# print help information if input arguments are incorrect 
if [[ ! $1 || `echo $1 | head -1c` == '-' ]] 
then 
  echo "Usage: $0 <absolute path to folder where CMOR output should be stored>"
  echo 
  echo "Example: $0 /work/${USER}/cmorout"
  echo 
  exit
fi 

# create folder and link
SCRIPTPATH=`readlink -f $0`
if [ ! -e $1 ] 
then 
  echo "Creating $1" 
  mkdir -p $1
  chmod g+w $1
fi
echo "Placed symbolic link cmorout in data directory `dirname $SCRIPTPATH`/../data"
mkdir -p `dirname $SCRIPTPATH`/../data
cd `dirname $SCRIPTPATH`/../data
ln -sf $1 cmorout
