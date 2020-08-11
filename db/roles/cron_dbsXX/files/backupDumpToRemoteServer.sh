#!/bin/bash

#機能概要
#DBバンプファイルを作成して、その結果を圧縮して、リモート（NAS）サーバーに格納する
#
#前提
#1.本サーバーからリモート（NAS）サーバーがマウント出来ていること
#2.リモートサーバーに$DUMP_COPY_DESTINATION_DIRが存在していること
#
#引数・入力
#なし

export ERR

terminate () {
	echo $ERR
	exit 1
}

create_dump_archive () {
	if [ $1 ]; then 
		local current_dir=$(pwd)
        cd $BASE_DIR
                
		#ダンプデータを準備
                mysql -u root -psysdev -e 'SHOW SLAVE STATUS\G' > slave.stat
#		mysqldump -u root -psysdev --databases dsp > $1
                DUMPOPT='--events --quote-names --single-transaction --hex-blob --dump-slave=2 --apply-slave-statements --include-master-host-port'
#		mysqldump -u root -psysdev $DUMPOPT --databases dsp > $1
                mysqldump -u root -psysdev $DUMPOPT --all-databases > $1
		#touch $1 #dummy data
		
		#DBダンプを圧縮
		gzip $1

		cd $current_dir
	fi
}

#TEST=ON

#export USAGE="Usage: $0 REMOTE_SERVER USERNAME"
#if [ $# != 2 ]; then
#	ERR="Wrong execution/usage. $USAGE"
#	terminate
#fi

OTHER_SCRIPT_DIR=.

source $OTHER_SCRIPT_DIR/setBackupVariables.sh

if [ $TEST ]; then
	$OTHER_SCRIPT_DIR/testVariables.sh
fi

#作業用ディレクトリ作成
if [ -d $WORK_DIR ]; then
	rm -r $WORK_DIR
fi
mkdir $WORK_DIR

#作業用ディレクトリに移動
cd $WORK_DIR

#ベースディレクトリ作成
mkdir $CURRENT_DATE
mkdir $BASE_DIR

#ダンプアーカイブ先ディレクトリ作成
if [ ! -d $DUMP_COPY_DESTINATION_DIR/$CURRENT_DATE ]; then
        mkdir $DUMP_COPY_DESTINATION_DIR/$CURRENT_DATE
fi

#MySqlダンプのアーカイブを準備
create_dump_archive $MYSQL_DUMP_FILE

#準備したデータ（$CURRENT_DATEディレクトリ配下）をNASサーバーに移動
#if [ -d $DUMP_COPY_DESTINATION_DIR/$CURRENT_DATE ]; then
	cp -rf $CURRENT_DATE/* $DUMP_COPY_DESTINATION_DIR/$CURRENT_DATE/
#else
#	mv $CURRENT_DATE $DUMP_COPY_DESTINATION_DIR
#fi

#scp -r $CURRENT_DATE $2@$1:$DUMP_COPY_DESTINATION_DIR

##データ移動が成功したら、通常終了
#if [ $? == 0 ]; then
#	#rm -rf $CURRENT_DATE
#	exit 0
#else
#	exit 1
#fi

#データのmvに成功したら、１ヶ月以上前のダンプファイルを削除する
if [ $? == 0 ]; then
	find $DUMP_COPY_DESTINATION_DIR -mtime +31 -type d | xargs rm -rf {} \;
	exit 0
else
	exit 1
fi
