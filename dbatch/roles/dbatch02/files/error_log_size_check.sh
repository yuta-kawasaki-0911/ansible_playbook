#!/bin/sh
# Make sure you replace the API and/or APP key below
# with the ones for your account

# 入力変数
h_name=`hostname | cut -c-8`
host_name="${h_name}.dsp.admatrix.jp"
directory="/var/app/fs/*/log/*/error.*"

# PIDFILEcheck start
PIDFILE=/var/app/maintenance/monitoring/error_log_size_check.pid
if test -f ${PIDFILE}; then
   echo pid exit
   exit
else
   touch ${PIDFILE}
fi

# 送信関数
function send_error_log_size(){

        echo "file = ${1}" "size = ${2}" "date = ${3} host = ${4}"

        curl  -X POST -H "Content-type: application/json" \
        -d "{ \"series\" :
                 [{\"metric\":\"error.log.size\",
                  \"points\":[[${3}, ${2}]],
                  \"type\":\"gauge\",
                  \"host\":\"${4}\",
                  \"tags\":[\"log:${1}\"]}]
            }" \
        'https://app.datadoghq.com/api/v1/series?api_key=0710f2e8e084bce4dc47dabd4364929b'

}

currenttime=$(date +%s)

# 実行
ls -l --time-style='+%s %H:%M' ${directory}|while read line
do

        echo ${line}

        # ファイル名を取得(ディレクトリ含む)
        file_name_d=`echo "${line}" | awk '{ print $8 }' | cut -c12-`

        # サイズを取得(byte)
        file_size_b=`echo "${line}" | awk '{ print $5 }'`

        # ファイル作成日時を取得(unixtime)
        file_date_ut=`echo "${line}" | awk '{ print $6 }'`

        difference=`expr ${currenttime} - ${file_date_ut}`
        if test ${difference} -gt 3600 ; then
                continue
        fi

        # datadogへ送信
        send_error_log_size ${file_name_d} ${file_size_b} ${file_date_ut} ${host_name}

	# 表示
	echo $'\n' "---------------------------------------"
	file_name=`echo "${file_name_d}" | awk -F "error." '{ print $2 }'`
	echo "ファイル名=${file_name}"
	file_date=`echo "${line}" | awk '{ print $7 }'`
	echo "更新日時=${file_date}"
	file_size=`printf "%'d\n" ${file_size_b}`
	echo "サイズ=${file_size}" $'\n' "---------------------------------------"

done

# PIDFILEcheck end
rm -f ${PIDFILE}
