# link cmorized files and calculate sha256sum
function cmorQC {

local expid version rls cmoroutroot table
#
if [ $# -gt 0 ] && [ $1 == "--help" ] 
 then
     printf "Usage:\n"
     printf "runcmor -e=[expid] -v=[version]"
     exit 1
 else
     while test $# -gt 0; do
         case "$1" in
             -e=*)
                 expid=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             -v=*)
                 version=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             * )
                 echo "ERROR: option $1 not allowed."

                 echo "*** EXITING THE SCRIPT"
                 exit 1
                 ;;
         esac
     done
 fi

if [ $(hostname -f |grep 'ipcc') ]
then
    cmoroutroot=/scratch/NS9034K/CMIP6
else
    cmoroutroot=/projects/NS9034K/CMIP6
fi

echo "~~~~~~~~~~~~~~~~~~~~"
echo "PrePARE QC CHECK... "
cdw=$(pwd)
cd ${cmoroutroot}/.cmorout/NorESM2-LM/${expid}
rm -f /tmp/QCreport.txt
rm -f ${version}.QCreport
nf=$(ls ${version}/*${rls}*.nc 2>/dev/null |wc -l)
echo "$nf files           "
echo "                    "
for rls in $(ls ${version}/*.nc 2>/dev/null |cut -d"_" -f5 |sort -u --version-sort)
do
    nf=$(ls ${version}/*${rls}*.nc 2>/dev/null |wc -l)
    echo ${rls}: $nf files >>${version}.QCreport
    for table in $(ls ${version}/* 2>/dev/null |cut -d"_" -f2 |sort -u)
    do
        echo ${table} >>${version}.QCreport
        /projects/NS9560K/cmor/PrePARE/bin/PrePARE_wrapper --max-processes 8 \
            ${version}/*_${table}_*_${rls}_*.nc &>>/tmp/QCreport.txt
        wait
        tail -2 /tmp/QCreport.txt >>${version}.QCreport
        printf %n >>${version}.QCreport
    done
done

wait

grep 'Error' ${version}.QCreport &>/dev/null

# check if error in QC report
if [ $? -eq 0 ]
then
    echo "ERROR in ${version}.QCreport, EXIT..."
    exit
else
    echo "         "
    echo "QC DONE  "
    echo "~~~~~~~~~"
    echo "         "
fi

# change directory back
cd $cdw

}
