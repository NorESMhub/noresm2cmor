#!/bin/sh -e 

PROJECT=CMIP6
ESGFROOT=/esg/data/cmor/$PROJECT
NIRDROOT=/projects/NS9034K/$PROJECT

if [ $VERSION ] 
then 
  VTAG=_v$VERSION
else
  VTAG=
fi

for MIP in `ls $NIRDROOT`
do 
	if [ $MIP1 ] && [ ! "$MIP1" == "$MIP" ] 
	then 
		continue
	fi

	for INS in `ls "$NIRDROOT/$MIP"`
	do
		if [ $INS1 ] && [ ! "$INS1" == "$INS" ] 
		then 
			continue
		fi

		for MOD in `ls "$NIRDROOT/$MIP/$INS"`
		do
			if [ $MOD1 ] && [ ! "$MOD1" == "$MOD" ] 
			then 
				continue
			fi

			for EXP in `ls "$NIRDROOT/$MIP/$INS/$MOD"`
			do
				if [ $EXP1 ] && [ ! "$EXP1" == "$EXP" ] 
				then 
					continue
				fi

				for RIP in `ls "$NIRDROOT/$MIP/$INS/$MOD/$EXP"`
				do
					if [ $RIP1 ] && [ ! "$RIP1" == "$RIP" ] 
					then 
						continue
					fi

					if [ ! -d "$NIRDROOT/$MIP/$INS/$MOD/$EXP/${RIP}" -o ! -e "$NIRDROOT/$MIP/$INS/$MOD/$EXP/.${RIP}.sha256sum${VTAG}" ]
					then 
						continue
					fi
					MAPFILE="$NIRDROOT/$MIP/$INS/$MOD/$EXP/.${RIP}.map${VTAG}"
					echo "$MAPFILE"
                                        if [ -e "$MAPFILE" ] 
                                        then
						if [ $REPLACE_EXISTING ] 
						then
							echo "backing up existing map to ${MAPFILE}_`date -r $MAPFILE +%Y%m%d`"
							mv $MAPFILE ${MAPFILE}_`date -r $MAPFILE +%Y%m%d`
						else 
							echo "skipping existing $MAPFILE (define REPLACE_EXISTING=1 to force replacement)" 
							continue
						fi
                                        fi 
                                        echo "create new $MAPFILE"  
					rm -f "$MAPFILE"
					for ITEM in `sed 's/\ \ /%/g' "$NIRDROOT/$MIP/$INS/$MOD/$EXP/.${RIP}.sha256sum${VTAG}" | sort -u`
					do
						SHASUM=`echo $ITEM | cut -d"%" -f1`
                                                RELPATH=`echo $ITEM | cut -d"%" -f2`
						NIRDPATH="$NIRDROOT/$MIP/$INS/$MOD/$EXP/$RELPATH"
						ESGFPATH="$ESGFROOT/$MIP/$INS/$MOD/$EXP/$RELPATH"
						MTIME=`stat -Lc %Y "$NIRDPATH"`.0 
						FSIZE=`stat -Lc %s "$NIRDPATH"`
						TABLE=`echo $RELPATH | cut -d'/' -f2`
						FIELD=`echo $RELPATH | cut -d'/' -f3`
						GRID=`echo $RELPATH | cut -d'/' -f4`
						VERSION=`echo $RELPATH | cut -d'/' -f5 | cut -d'v' -f2`
                                                DATASET="${PROJECT}.${MIP}.${INS}.${MOD}.${EXP}.${RIP}.${TABLE}.${FIELD}.${GRID}#${VERSION}"
 						MAPENTRY="$DATASET | $ESGFPATH | $FSIZE | mod_time=$MTIME | checksum=$SHASUM | checksum_type=SHA256"
						echo "$MAPENTRY" >> "$MAPFILE"
					done
					chmod g+w "$MAPFILE"
				done
			done
		done 
	done
done
echo SUCCESS 
