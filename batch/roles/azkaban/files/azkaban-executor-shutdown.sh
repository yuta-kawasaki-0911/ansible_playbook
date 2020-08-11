#!/bin/bash

# Azkaban common setting
SH_DIR=`dirname $0`
source ${SH_DIR}/../conf/global.properties
azkaban_dir=${AZKABAN_BASE_DIR}
base_dir=${azkaban_dir}
tmpdir=${base_dir}/tmp
pid_dir=${base_dir}/pid

executorport=`cat ${base_dir}/conf/azkaban.properties | grep executor.port | cut -d = -f 2`
echo "Shutting down current running AzkabanExecutorServer at port $executorport" 
proc=`cat ${pid_dir}/azkaban-exe.pid`
kill $proc

#cat /dev/null > ${pid_dir}/azkaban-exe.pid
rm -fr ${pid_dir}/azkaban-exe.pid
