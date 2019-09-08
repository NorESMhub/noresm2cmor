#!/bin/sh -e

for ITEM in `find /projects/NS9034K/CMIP6 -name "latest"`
do 
  if [ -d $ITEM ]
  then 
    echo $ITEM
    rm -rf $ITEM
  fi
done 
