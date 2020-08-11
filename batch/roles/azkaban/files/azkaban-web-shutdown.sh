#!/bin/bash

# Azkaban common setting
SH_DIR=`dirname $0`
source ${SH_DIR}/../conf/global.properties
azkaban_dir=${AZKABAN_BASE_DIR}
base_dir=${azkaban_dir}
tmpdir=${base_dir}/tmp
pid_dir=${base_dir}/pid

proc=`cat ${pid_dir}/azkaban-web.pid`
echo "killing AzkabanWebServer"
kill $proc

#cat /dev/null > ${pid_dir}/azkaban-web.pid
rm -fr ${pid_dir}/azkaban-web.pid
