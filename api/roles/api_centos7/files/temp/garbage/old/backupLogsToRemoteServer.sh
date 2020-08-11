#!/bin/bash

#機能
#ログファイルをアーカイブ・圧縮して、リモート（NAS）サーバーに格納する
#
#前提
#1.本サーバーからリモート（NAS）サーバーがマウント出来ていること
#2.同リモートサーバーに$LOG_COPY_DESTINATION_DIRが存在していること
#
#引数・入力
#なし

export ERR

terminate () {
	echo $ERR
	exit 1
}

create_log_archive () {
	#引数のログフォルダが存在する場合は、本関数を実行する
	if [ $1 ] && [ -d $1 ]; then
		local current_dir=$(pwd)

		IFS='/'
		array=($1)
		IFS=''

		cd $BASE_DIR

		for SUBDIR in ${array[@]}
		do
			if [ $SUBDIR ]; then
				if [ ! -d $SUBDIR ]; then mkdir $SUBDIR
				fi
				cd $SUBDIR
			fi
		done

		#ログファイルの有無を確認
		ls $1/*log* &> temp.out

		#ログファイルがあれば、アーカイブを作成
		local copyResult=1
		if [ $? == 0 ] ; then
			cp -r $1/*log* .
			copyResult=$?

			for FILE in ./*log*
			do
				tar czf $FILE.tar.gz $FILE
				if [ -f $FILE ]; then 
					rm $FILE
				elif [ -d $FILE ]; then
					rm -rf $FILE
				fi
			done
		fi
		rm temp.out

		#元ログファイルがコピーできる場合、元ログファイルを削除
		#if [ $copyResult == 0 ]; then
		#	rm -rf $1/*log*
		#fi
		
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

#Apacheログのアーカイブを準備
#create_log_archive $APACHE_LOG_DIR

#Tomcatログのアーカイブを準備
#create_log_archive $TOMCAT_LOG_DIR

#Appログのアーカイブを準備
#create_log_archive $ACQ_LOG_DIR
#create_log_archive $SERVING_LOG_DIR
create_log_archive $OPTOUT_LOG_DIR
create_log_archive $UNITAG_LOG_DIR

#準備したデータ（$CURRENT_DATEディレクトリ配下）をNASサーバーに移動
if [ -d $LOG_COPY_DESTINATION_DIR/$CURRENT_DATE ]; then
	mv -f $CURRENT_DATE/* $LOG_COPY_DESTINATION_DIR/$CURRENT_DATE
else
	mv $CURRENT_DATE $LOG_COPY_DESTINATION_DIR
fi

#scp -r $CURRENT_DATE $2@$1:$LOG_COPY_DESTINATION_DIR

#データ移動が成功したら、通常終了
if [ $? == 0 ]; then
	#rm -rf $CURRENT_DATE
	exit 0
else
	exit 1
fi

