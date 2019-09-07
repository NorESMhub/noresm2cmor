#!/bin/sh -e 

# Purpose: hide .sha256sum and .map files by adding . at beginning

for ITEM in `find /projects/NS9034K/CMIP6 -name "*.sha256sum"`
do 
	FNAME=`basename $ITEM`
	if [ "${FNAME}" = ".sha256sum" ] 
	then 
		echo "rm $ITEM"
 		rm $ITEM
	elif [ "`echo ${FNAME} | head -c1`" = "r" ]
	then
		echo "mv $ITEM `dirname $ITEM`/.$FNAME" 
 		mv $ITEM `dirname $ITEM`/.$FNAME
	fi
done 

for ITEM in `find /projects/NS9034K/CMIP6 -name "*.map"`
do
        FNAME=`basename $ITEM`
        if [ "${FNAME}" = ".map" ]
        then
                echo "rm $ITEM"
                rm $ITEM
        elif [ "`echo ${FNAME} | head -c1`" = "r" ]
        then
                echo "mv $ITEM `dirname $ITEM`/.$FNAME" 
                mv $ITEM `dirname $ITEM`/.$FNAME
        fi
done
