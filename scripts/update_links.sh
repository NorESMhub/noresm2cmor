#!/bin/sh -e 

for ITEM in `find /projects/NS9034K/CMIP6 -name "*.nc"`
do 
        echo "cd `dirname $ITEM`"
	cd `dirname $ITEM`
	FNAME=`basename $ITEM`
	SLINK=`stat -c %N $FNAME | cut -d"‘" -f3 | cut -d"’" -f1`
	echo "ln -sf `echo $SLINK | sed 's%/cmorout%/.cmorout%'` $FNAME"
	ln -sf `echo $SLINK | sed 's%/cmorout%/.cmorout%'` $FNAME
done 
