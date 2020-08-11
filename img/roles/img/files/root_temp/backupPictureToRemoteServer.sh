#!/bin/bash -x

#機能
#画像データを、リモート（NAS）サーバーに格納する
#
#前提
#1.本サーバーからリモート（NAS）サーバーがマウント出来ていること
#2.同リモートサーバーに$LOG_COPY_DESTINATION_DIRが存在していること

HOSTNAME=`hostname -s`
BACKUP_SRC_DIR=/usr/local/apache2/htdocs
CURRENT_DATE=`date +'%Y%m%d'`
PIC_WORK_DIR=/root/temp/work_pic/picture/$CURRENT_DATE
LOG_COPY_DESTINATION_DIR=/nas/backup/picture/$CURRENT_DATE

#作業用ディレクトリ作成
if [ -d $PIC_WORK_DIR ]; then
	rm -r $PIC_WORK_DIR
fi
mkdir $PIC_WORK_DIR

#作業用ディレクトリに移動
cd $PIC_WORK_DIR

#バックアップディレクトリ作成
mkdir $HOSTNAME

#クリエイティブデータのアーカイブを準備
cp -r $BACKUP_SRC_DIR $PIC_WORK_DIR/$HOSTNAME 

#nas側に日付ディレクトリがなければ作成
if [ ! -d $LOG_COPY_DESTINATION_DIR ]; then
       mkdir $LOG_COPY_DESTINATION_DIR 
fi


#準備したデータ（$HOSTNAMEディレクトリ配下）をNASサーバーに移動
if [ -d $LOG_COPY_DESTINATION_DIR/$HOSTNAME ]; then
	mv -f $HOSTNAME/* $LOG_COPY_DESTINATION_DIR/$HOSTNAME
else
	mv $HOSTNAME $LOG_COPY_DESTINATION_DIR
fi

cd /root/temp/work_pic/picture

#データ移動が成功したら、通常終了
if [ $? == 0 ]; then
	rm -rf $PIC_WORK_DIR
	exit 0
else
	exit 1
fi
