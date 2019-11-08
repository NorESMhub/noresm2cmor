#!/bin/bash
#set -x

IFS=''      # keep leading space

echo ~~~~~~~~~~~~~~~~~~~~~~
echo READ V20190920 VERSION
echo ~~~~~~~~~~~~~~~~~~~~~~
nf=$(cat var_CMIP6_NorESM2_default.nml.20190920 |wc -l)
k=1
while read -r line
do
    echo -ne "$k/$nf lines\r"
    # get table name
    table_tmp=$(echo $line|grep 'table_' |cut -d"_" -f2)
    if [ ! -z $table_tmp ]
    then
        table=$table_tmp
    fi

    # get var names and operator
    ovm=$(echo $line |grep "','" |cut -d"'" -f2 |sed 's/ //g')
    ivm=$(echo $line |grep "','"|cut -d"'" -f4 |sed 's/ //g')
    opt=$(echo $line |grep "','"|cut -d"'" -f6 |sed 's/ //g')
    if [ -z $opt ]
    then
        opt="-"
    fi
    if [ ! -z $ovm ]
    then
        tables1+=($table)
        ovms1+=($ovm)
        ivms1+=($ivm)
        opts1+=($opt)
    fi
    let k+=1
done <var_CMIP6_NorESM2_default.nml.20190920
echo -e "\r"

echo table n ${#tables1[*]}
echo ovms1 n ${#ovms1[*]}
echo ivms1 n ${#ivms1[*]}
echo opts1 n ${#ivms1[*]}

echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo FIND DIFFERENCE with 20191108
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

rm -f var_CMIP6_NorESM2_default_diff.nml
rm -f var_CMIP6_NorESM2_default_comm.nml

nf=$(cat var_CMIP6_NorESM2_default.nml.20191108 |wc -l)
k=1
while read -r line
do
    nc=$(echo "$line" | grep -c "!   ")
    let nc+=$(echo "$line" | grep -c "not available")
    let nc+=$(echo "$line" | grep -c "not implemented")
    if [ $nc -ge 1 ]
    then
        continue
    fi
    echo -ne "$k/$nf lines\r"
    # get table name
    table_tmp=$(echo $line|grep 'table_' |cut -d"_" -f2)
    if [ ! -z $table_tmp ]
    then
        table2=$table_tmp
    fi

    # get var names and operator
    ovm2=$(echo $line |grep "','" |cut -d"'" -f2 |sed 's/ //g')
    ivm2=$(echo $line |grep "','"|cut -d"'" -f4 |sed 's/ //g')
    opt2=$(echo $line |grep "','"|cut -d"'" -f6 |sed 's/ //g')
    if [ -z $opt2 ]
    then
        opt2="-"
    fi
    if [ ! -z $ovm2 ]
    then
        flag=true   # by default, set the target line different to 20190920 version
        for (( i = 0; i < ${#tables1[*]}; i++ )); do
            table1=${tables1[i]}
            ovm1=${ovms1[i]}
            ivm1=${ivms1[i]}
            opt1=${opts1[i]}
            if [ $table2 == $table1 ]
            then
                if [ "${ovm2}${ivm2}${opt2}" == "${ovm1}${ivm1}${opt1}" ]
                then
                    flag=false
                    break
                fi
            fi
        done
        if $flag
        then
            echo "$line" >> var_CMIP6_NorESM2_default_diff.nml
        else
            echo "$line" >> var_CMIP6_NorESM2_default_comm.nml
        fi
    else
        echo "$line" >> var_CMIP6_NorESM2_default_diff.nml
        nc=$(grep -c "$line" var_CMIP6_NorESM2_default.nml.20190920)
        if [ $nc -ge 1 ]
        then
            echo "$line" >> var_CMIP6_NorESM2_default_comm.nml
        fi
    fi
    let k+=1
done <var_CMIP6_NorESM2_default.nml.20191108
echo -e "\r"
