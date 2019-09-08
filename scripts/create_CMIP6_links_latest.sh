#!/bin/sh -e 

DRYRUN=0
REPLACE=1 

for ITEM in `find /projects/NS9034K/CMIP6 -name "*.nc" | sort | sed -e '/cmorout/d' -e '/latest/d'`
do 
	DIRNAME=`dirname $ITEM`
	DIRNAME2=`dirname $DIRNAME`
	VERSION=`basename $DIRNAME`
        echo "cd $DIRNAME2"
	cd $DIRNAME2
	if [ ! -e $DIRNAME2/latest -o $REPLACE -eq 1 ] 
	then 
		echo "ln -sf $VERSION latest" 
		if [ $DRYRUN -ne 1 ] 
		then 
			ln -sf $VERSION latest
		fi
	fi
done 
