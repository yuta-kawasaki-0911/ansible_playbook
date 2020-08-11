#!/bin/sh

## 実行変数 ##
TODAY=`date +"%Y-%m-%d"`
TOMORROW=`date -d "1 days" +"%Y-%m-%d"`
BID_LOG_DIR=/var/app/fs/dsp/data/bid/
BID_INVENTORY_LOG_DIR=/var/app/fs/dsp/data/bidinventory/
SERVER_IP=`/sbin/ifconfig | grep 'inet addr' | awk '{print $2;}' | cut -d: -f2 | grep 192.168.`
USER=tomcat

## CONFIG ファイル作成 ## 
CONFIG=" 
settings{ \n 
        logfile = \"/var/log/lsyncd/lsyncd.log\", \n
        statusFile = \"/tmp/lsyncd.stat\", \n
        statusInterval = 1, \n 
        delay = 1, \n
        maxProcesses = 2, \n
        inotifyMode = \"CloseWrite or Modify\", \n
} \n
\n
sync{ \n 
        default.rsync, \n
        source = \"${BID_LOG_DIR}${TODAY}\", \n
        target = \"/nas/app/${SERVER_IP}/fs/dsp/data/bid/${TODAY}\", \n 
        rsync  = { \n 
                archive = true, \n
                verbose = false, \n
                _extra = {\"--append\"} \n
        } \n 
} \n 
\n
sync{ \n
        default.rsync, \n
        source = \"${BID_LOG_DIR}${TOMORROW}\", \n
        target = \"/nas/app/${SERVER_IP}/fs/dsp/data/bid/${TOMORROW}\", \n
        rsync  = { \n
                archive = true, \n
                verbose = false, \n
                _extra = {\"--append\"} \n
        } \n
} \n
\n
sync{ \n
        default.rsync, \n
        source = \"${BID_INVENTORY_LOG_DIR}${TODAY}\", \n
        target = \"/nas/app/${SERVER_IP}/fs/dsp/data/bidinventory/${TODAY}\", \n
        rsync  = { \n
                archive = true, \n
                verbose = false, \n
                _extra = {\"--append\"} \n
        } \n
} \n
\n
sync{ \n
        default.rsync, \n
        source = \"${BID_INVENTORY_LOG_DIR}${TOMORROW}\", \n                                                                                                            
        target = \"/nas/app/${SERVER_IP}/fs/dsp/data/bidinventory/${TOMORROW}\", \n
        rsync  = { \n
                archive = true, \n
                verbose = false, \n
                _extra = {\"--append\"} \n
        } \n
}
"
## LOG
echo -e "lsyncd_rotate.sh...\n"
echo "today:[${TODAY}] tomorrow:[${TOMORROW}]"
## CONIFG ファイルPUT
echo "create lsyncd config file. [/etc/lsyncd.conf]"
echo -e ${CONFIG} > /etc/lsyncd.conf

## 未来日付のファイルを作成しておく
echo -e "create tomorrow bidlog dir [${BID_LOG_DIR}${TOMORROW}]\n"
mkdir -p ${BID_LOG_DIR}${TOMORROW}
chown ${USER}:${USER} ${BID_LOG_DIR}${TOMORROW}
echo -e "create tomorrow bidlog dir [${BID_INVENTORY_LOG_DIR}${TOMORROW}]\n"
mkdir -p ${BID_INVENTORY_LOG_DIR}${TOMORROW}
chown ${USER}:${USER} ${BID_INVENTORY_LOG_DIR}${TOMORROW}

## lsyncd をreloadする
echo -e "reload lsyncd...\n"
result=`/etc/init.d/lsyncd reload`

echo ${result} | grep "失敗" 
if [ $? -eq 0 ]; then
  echo "lsyncd reload...failed.."
  exit 1
fi
echo "lsyncd reload...success.."
exit 0

