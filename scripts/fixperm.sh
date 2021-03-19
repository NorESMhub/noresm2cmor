#!/bin/bash

logfile=/tmp/fixperm-$(date +%Y-%m-%d).log
models=(NorESM2-LM NorESM2-MM NorESM2-MH NorESM1-F)
for model in $(echo ${models[*]})
do
    echo $model
    # add folder group writeable permission
    find /projects/NS9034K/CMIP6/.cmorout/$model -type d -user $USER -name '[[:alnum:]]*' ! -perm 2775 -ls -exec chmod g+w {} \; | tee -a $logfile

    # change group of files and folders to ns034k
    find /projects/NS9034K/CMIP6/.cmorout/$model -user $USER ! -group ns9034k -ls -exec chown $USER:ns9034k {} \; | tee -a $logfile

    folders=$(find /projects/NS9034K/CMIP6/.cmorout/$model -type d -name "v20*")
    for folder in $(echo ${folders[*]})
    do
        echo ${folder}
        # add file group write permission
        find $folder -type f -name "*.nc" -user $USER ! -perm -g=w -ls -exec chmod g+w {} \; |tee -a $logfile

    done
done

echo "--------------------"
echo "     DONE           "
echo "--------------------"
