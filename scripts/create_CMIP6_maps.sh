#!/bin/sh -e 

PROJECT=CMIP6
ESGFROOT=/esg/gridftp_root/esg_dataroot/cmor/$PROJECT
NIRDROOT=/projects/NS9034K/$PROJECT

for MIP in `ls $NIRDROOT`
do 
	if [ $MIP == "cmorout" -o $MIP == "test" ] 
	then
		continue
	fi
	for INS in `ls $NIRDROOT/$MIP`
	do
		for MOD in `ls $NIRDROOT/$MIP/$INS`
		do
			for EXP in `ls $NIRDROOT/$MIP/$INS/$MOD`
			do
				for RIP in `ls $NIRDROOT/$MIP/$INS/$MOD/$EXP`
				do
					if [ ! -d $NIRDROOT/$MIP/$INS/$MOD/$EXP/${RIP} -o ! -e $NIRDROOT/$MIP/$INS/$MOD/$EXP/${RIP}.sha256sum ]
					then 
						continue
					fi
					MAPFILE=$NIRDROOT/$MIP/$INS/$MOD/$EXP/${RIP}.map
					echo $MAPFILE
					rm -f $MAPFILE
					for ITEM in `sed 's/\ \ /%/g' $NIRDROOT/$MIP/$INS/$MOD/$EXP/${RIP}.sha256sum`
					do
						SHASUM=`echo $ITEM | cut -d"%" -f1`
                                                RELPATH=`echo $ITEM | cut -d"%" -f2`
						NIRDPATH=$NIRDROOT/$MIP/$INS/$MOD/$EXP/$RELPATH
						ESGFPATH=$ESGFROOT/$MIP/$INS/$MOD/$EXP/$RELPATH
						MTIME=`stat -Lc %Y $NIRDPATH`.0 
						FSIZE=`stat -Lc %s $NIRDPATH`
						TABLE=`echo $RELPATH | cut -d'/' -f2`
						FIELD=`echo $RELPATH | cut -d'/' -f3`
						GRID=`echo $RELPATH | cut -d'/' -f4`
						VERSION=`echo $RELPATH | cut -d'/' -f5 | cut -d'v' -f2`
                                                DATASET="${PROJECT}.${MIP}.${INS}.${MOD}.${EXP}.${RIP}.${TABLE}.${FIELD}.${GRID}#${VERSION}"
 						MAPENTRY="$DATASET | $ESGFPATH | $FSIZE | mod_time=$MTIME | checksum=$SHASUM | checksum_type=SHA256"
						echo $MAPENTRY >> $MAPFILE
					done
					chmod g+w $MAPFILE
				done
			done
		done 
	done
done
echo SUCCESS 
