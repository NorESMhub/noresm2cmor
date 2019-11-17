# PrePARE QC check
function cmorQC {

local expid version rls cmoroutroot table
#
if [ $# -gt 0 ] && [ $1 == "--help" ] 
 then
     printf "Usage:\n"
     printf "cmorQC -m=[model] -e=[expid] -v=[version]"
     exit 1
 else
     while test $# -gt 0; do
         case "$1" in
             -m=*)
                 model=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
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

if [ -z $model ]; then
    model=NorESM2-LM
fi

# ENV for PrePARE
export PATH=/opt/anaconda3/bin:${PATH}
export CMIP6_CMOR_TABLES=/projects/NS9560K/cmor/noresm2cmor/tables

if [ $(hostname -f |grep 'ipcc') ]
then
    cmoroutroot=/scratch/NS9034K/CMIP6
    source activate /scratch/NS9034K/cmorlib/PrePARE
else
    cmoroutroot=/projects/NS9034K/CMIP6
    source activate /projects/NS9560K/cmor/PrePARE
fi

echo "~~~~~~~~~~~~~~~~~~~~"
echo "PrePARE QC CHECK... "
cdw=$(pwd)
cd ${cmoroutroot}/.cmorout/${model}/${expid}
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
        nf2=$(ls ${version}/*_${table}_*_${rls}_*.nc |wc -l)
        if [ $nf2 -gt 0 ]; then
            echo ${table} >>${version}.QCreport
            PrePARE --max-processes 8 \
                ${version}/*_${table}_*_${rls}_*.nc &>>/tmp/QCreport.txt
            wait
            tail -2 /tmp/QCreport.txt >>${version}.QCreport
            printf %n >>${version}.QCreport
        fi
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
