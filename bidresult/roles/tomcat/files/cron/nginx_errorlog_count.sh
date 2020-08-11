#!/bin/sh
# Make sure you replace the API and/or APP key below
# with the ones for your account
# クーロンで毎分実行する設定が必要
# ファイルは必ず存在するため、dummyは廃止
# metricの名前
metric_name="nginx.errorlog.count"

# PIDFILEcheck start
PIDFILE=/var/app/maintenance/monitoring/nginx_errorlog_count.pid
if test -f ${PIDFILE}; then
   echo "pid exit"
   exit
else
   touch ${PIDFILE}
fi

# ex)2017-11-16 ex)2017-11-16 09:45(1分前)
# date_ymd=`date +"%Y-%m-%d"`
#date_ymdHM=`date +"%Y-%m-%d %H:%M" -d "10 minute ago"`
# 1日間隔にするために変更（一旦）
date_ymdHM_delete_one_digit=`date +"%Y/%m/%d %H" -d "1 hour ago"`
# 現在時刻(UNIXtime)  ex)1511252187
currenttime=$(date +%s)

host=`hostname`
# hostnameの種類に応じてhost_endを設定
case ${host} in
  api* ) host_end=5 ;;
  dapi* ) host_end=6 ;;
  tapi* ) host_end=6 ;;
  relay* ) host_end=7 ;;
  bidresult* ) host_end=11 ;;
  capi* ) host_end=6 ;;
  iapi* ) host_end=6 ;;
esac

groups_end=`expr ${host_end} - 2`
groups=`hostname | cut -c 1-${groups_end}`
# ex)api03,dapi12,bidresult02 ex)api,dapi,bidresult
hostname=`hostname | cut -c 1-${host_end}`
# hostnameXXX◯◯までとDataDogでのhost名が違うので修整する
case ${hostname} in
  api* ) hostname="${hostname}.3pas.admatrix.jp" ;;
  dapi* ) hostname="${hostname}.ad-m.asia" ;;
  tapi* ) hostname="${hostname}.3pas.admatrix.jp" ;;
  relay* ) hostname="${hostname}.dsp.admatrix.jp" ;;
  bidresult* ) hostname="${hostname}.dsp.admatrix.jp" ;;
  capi* ) hostname="${hostname}.ad-m.asia" ;;
  iapi* ) hostname="${hostname}.ad-m.asia" ;;
esac

# /var/log/nginx/配下のlogの取得、送信を行う
# log一覧を取得する
log_file_list=$(ls /var/log/nginx/ -1)

# XXXX.errorlog一覧を取得する
for log_file_name in ${log_file_list}
do
  if test `echo ${log_file_name}|grep "errorlog"` ; then
    error_log_file_list=("${error_log_file_list[@]}" "${log_file_name}")
  fi
done

# エラーログファイル毎に実行する
for error_log_file_name in ${error_log_file_list[@]}
do
  # エラー数を取得（行数）
  error_count=`grep -c "${date_ymdHM_delete_one_digit}" /var/log/nginx/${error_log_file_name}`
  log_type=${error_log_file_name}

  # DataDogへ送信
  curl  -X POST -H "Content-type: application/json" \
  -d "{ \"series\" :
           [{\"metric\":\"${metric_name}\",
            \"points\":[[${currenttime}, ${error_count}]],
            \"type\":\"gauge\",
            \"host\":\"${hostname}\",
            \"tags\":[\"groups:${groups}\",\"logtype:${log_type}\"]}]
      }" \
  'https://app.datadoghq.com/api/v1/series?api_key=0710f2e8e084bce4dc47dabd4364929b'
done

# PIDFILEcheck end
rm -f ${PIDFILE}

