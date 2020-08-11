#!/bin/bash
# */10 * * * * /var/app/maintenance/monitoring/response_delay_detection.sh >/dev/null 2>&1

MONITORING_ROW_NUM=10000
LIMIT_RESPONSE_TIME=100000
TRANSLATE=1000000
LIMIT_RATIO_PERCENTAGE=5
RESULT_FILE="delay.txt"
YYYYMMDD=`date +"%Y-%m-%d"`
HOST_NAME=`hostname`
OTHER_LOG_FILENAME=access_log
GOOGLE_LOG_FILENAME=ssl_request_log
PIDFILE=/var/app/maintenance/monitoring/check.pid
HEALTH_FILE=/usr/local/apache2/htdocs/health.html_

#lvs check
if test -f ${HEALTH_FILE}; then
   exit
fi

if test -f ${PIDFILE}; then
   echo pid exit
   exit
else
   touch ${PIDFILE}
fi

function response_check() {

average_response_time_sec=`tail -fn1000 /usr/local/apache2/logs/${LOG_FILENAME}.${YYYYMMDD} |grep bid| awk -v LIMIT_RATIO_PERCENTAGE="${LIMIT_RATIO_PERCENTAGE}" -v LIMIT_RESPONSE_TIME="${LIMIT_RESPONSE_TIME}" -v MONITORING_ROW_NUM="${MONITORING_ROW_NUM}" -v TRANSLATE="${TRANSLATE}" '

BEGIN {
    row_cnt = 0
    response_time_sum = 0
    limit_over_row_num = 0
}

{
    response_time_sum += $NF
    row_cnt++
    
    if($NF > LIMIT_RESPONSE_TIME){
        limit_over_row_num++
    }
    if(row_cnt >= MONITORING_ROW_NUM){
        exit
    }
}

END {
    average_response_time = response_time_sum/MONITORING_ROW_NUM
    average_response_time_sec = average_response_time/TRANSLATE
    #print average_response_time
    print average_response_time_sec
}'`

echo $average_response_time_sec
}

LOG_FILENAME=${OTHER_LOG_FILENAME}
other_response=`response_check`
LOG_FILENAME=${GOOGLE_LOG_FILENAME}
google_response=`response_check`





#個別設定
host_end=6
groups_end=`expr $host_end - 2`
hostname=`hostname | cut -c 1-${host_end}`.ad-m.asia
groups=`hostname | cut -c 1-${groups_end}`

currenttime=$(date +%s)

function post_datadog {
curl  -X POST -H "Content-type: application/json" \
-d "{ \"series\" :
         [{\"metric\":\"$title\",
          \"points\":[[$currenttime, $count]],
          \"type\":\"gauge\",
          \"host\":\"$hostname\",
          \"tags\":[\"groups:$groups\"]}]
    }" \
'https://app.datadoghq.com/api/v1/series?api_key=0710f2e8e084bce4dc47dabd4364929b'
}
echo $other_response
echo $google_response

title=ssp.other.avg.response.time.sec
count=$other_response
post_datadog
title=ssp.google.avg.response.time.sec
count=$google_response
post_datadog

rm -f ${PIDFILE}
