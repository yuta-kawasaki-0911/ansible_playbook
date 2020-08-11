#!/bin/sh

## 実行変数 ##
TODAY=`date +"%Y-%m-%d"`
TOMORROW=`date -d "1 days" +"%Y-%m-%d"`
BID_LOG_DIR=/var/app/fs/dsp/data/bid/
BID_INVENTORY_LOG_DIR=/var/app/fs/dsp/data/bidinventory/
BID_PROCESS_LOG_DIR=/var/app/fs/dsp/data/bidprocess/
SERVER_IP=`/sbin/ifconfig | grep 'inet addr' | awk '{print $2;}' | cut -d: -f2 | grep 192.168.`
USER=tomcat

## 未来日付のファイルを作成しておく
echo -e "create tomorrow bidlog dir [${BID_LOG_DIR}${TOMORROW}]\n"
mkdir -p ${BID_LOG_DIR}${TOMORROW}
chown ${USER}:${USER} ${BID_LOG_DIR}${TOMORROW}
echo -e "create tomorrow bidlog dir [${BID_INVENTORY_LOG_DIR}${TOMORROW}]\n"
mkdir -p ${BID_INVENTORY_LOG_DIR}${TOMORROW}
chown ${USER}:${USER} ${BID_INVENTORY_LOG_DIR}${TOMORROW}
echo -e "create tomorrow bidprocess dir [${BID_PROCESS_LOG_DIR}${TOMORROW}]\n"
mkdir -p ${BID_PROCESS_LOG_DIR}${TOMORROW}
chown ${USER}:${USER} ${BID_PROCESS_LOG_DIR}${TOMORROW}

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
sync{ \n
        default.rsync, \n
        source = \"${BID_PROCESS_LOG_DIR}${TODAY}\", \n
        target = \"/nas/app/${SERVER_IP}/fs/dsp/data/bidprocess/${TODAY}\", \n
        rsync  = { \n
                archive = true, \n
                verbose = false, \n
                _extra = {\"--append\"} \n
        } \n
} \n
\n
sync{ \n
        default.rsync, \n
        source = \"${BID_PROCESS_LOG_DIR}${TOMORROW}\", \n
        target = \"/nas/app/${SERVER_IP}/fs/dsp/data/bidprocess/${TOMORROW}\", \n
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

## lsyncd をreloadする
echo -e "reload lsyncd...\n"
result=`/etc/init.d/lsyncd reload`

## /etc/init.d/lsyncd reloadを実行した場合、コマンド実行に成功（reloadに失敗していても、コマンドが成功している）した結果が返却されるため、reloadに失敗していても $? = 0 となる。
## そのため、reloadに失敗していることを確認するために、処理結果の中に 失敗 の文字があることを確認する。
## 実行例)
## $ /etc/init.d/lsyncd reload
## lsyncd を再読み込み中:                                     [失敗]
## $ echo $?
## 0
echo ${result} | grep "失敗"

if [ $? -eq 0 ]; then
  echo "lsyncd reload...failed.."

# send mail.
MAIL_FROM=`hostname`
MAIL_TO=dsp_dev@craid-inc.com
MAIL_SUBJECT=${MAIL_FROM}"でlsyncdのリロードに失敗"
MAIL_BOUNDARY=`date +%Y%m%d%H%M%N`

sendmail -t << EOF
From: ${MAIL_FROM}
To: ${MAIL_TO}
Subject: ${MAIL_SUBJECT}
MIME-Version: 1.0
Content-type: multipart/mixed; boundary=${MAIL_BOUNDARY}
Content-Transfer-Encoding: base64

--${MAIL_BOUNDARY}
Content-type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64

lsyncdのリロードに失敗しました。
EOF
# send mail finish.
  exit 1
fi
echo "lsyncd reload...success.."
exit 0
