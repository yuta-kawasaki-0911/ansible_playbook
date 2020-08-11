#!/bin/sh
# Make sure you replace the API and/or APP key below
# with the ones for your account


# PIDFILEcheck start
PIDFILE=/var/app/maintenance/monitoring/daily_budget.pid
if test -f ${PIDFILE}; then
   echo pid exit
   exit
else
   touch ${PIDFILE}
fi

currenttime=$(date +%s)

# 送信関数
function send_slack(){
    curl -XPOST -d 'token=xoxb-182032991362-07GOIK7zCbJ1kFC2ZMp5ocMj' -d 'channel=datadog-cost-check' -d "text=${1}" -d 'username=ajb-kpt-bot' 'https://slack.com/api/chat.postMessage'
}

date_ymd=`date +"%Y-%m-%d"`
count=`grep "ON" /var/app/fs/dsp/log/${date_ymd}/log.DailyBudgetControlUpdate4RportService.txt|wc -l`
if [ "$count" == 0 ]; then
  message="adgroup_reportを元に日予算は更新されませんでした."
else
  message="adgroup_reportを元にAM3:00に${count}件日予算が更新されました."
fi

send_slack ${message}

# PIDFILEcheck end
rm -f ${PIDFILE}
