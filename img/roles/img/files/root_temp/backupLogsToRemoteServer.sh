#!/bin/bash -x

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

		#timelineファイル存在チェック
		if [ ! -e $3 ]; then
			rm -f $3
        		touch $3
		fi


		#バックアップ対象ログリスト作成
		find $1 -type f -newer $3 -name "*log*" &> /root/temp/work/list.out
		LISTFILE=/root/temp/work/list.out

		#ログコピー
		if [ -s /root/temp/work/list.out ]; then
               		while read line 
                	do      
                        	cp $line ./
			done < $LISTFILE



               #圧縮して移動
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
		
	fi
		rm -f $LISTFILE


		#本番サーバーのログファイル削除
	        find $1 -name "*log*" -type f -mtime +$2 -exec rm -f {} \;
		#基準ファイルタイムスタンプ更新
		touch $3
	
		cd $current_dir
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
#create_log_archive $APACHE_LOG_DIR $APACHE_LOG_EXPIRE $APACHE_LOG_TIMELINE

#Nginxログのアーカイブを準備
create_log_archive $NGINX_LOG_DIR $NGINX_LOG_EXPIRE $ERROR_LOG_EXPIRE $NGINX_LOG_TIMELINE

#Tomcatログのアーカイブを準備
#create_log_archive $TOMCAT_LOG_DIR $TOMCAT_LOG_EXPIRE $TOMCAT_LOG_TIMELINE

#Appログのアーカイブを準備
#create_log_archive $ACQ_LOG_DIR $ACQ_LOG_EXPIRE $ACQ_LOG_TIMELINE
#create_log_archive $SERVING_LOG_DIR $SERVING_LOG_EXPIRE $SERVING_LOG_TIMELINE
#create_log_archive $OPTOUT_LOG_DIR $OPTOUT_LOG_EXPIRE $OPTOUT_LOG_TIMELINE
#create_log_archive $UNITAG_LOG_DIR $UNITAG_LOG_EXPIRE $UNITAG_LOG_TIMELINE

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
