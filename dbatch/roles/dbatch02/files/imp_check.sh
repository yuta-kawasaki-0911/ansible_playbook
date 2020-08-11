#!/bin/sh
# Make sure you replace the API and/or APP key below
# with the ones for your account

# 入力変数
h_name=`hostname | cut -c-8`
host_name="${h_name}.dsp.admatrix.jp"

# PIDFILEcheck start
PIDFILE=/var/app/maintenance/monitoring/imp_check.pid
DONEFILE=/var/app/maintenance/monitoring/imp_check_done
CHECKFILE=/var/app/fs/dsp/data/check/impCheck

if test -f ${PIDFILE}; then
   echo pid exit
   exit
else
   touch ${PIDFILE}
fi

beforeimptime=`cat ${DONEFILE}`
currentimptime=`ls -l --time-style='+%s %H:%M' ${CHECKFILE}|awk '{print $6}'`

if [ "${beforeimptime}" = "${currentimptime}" ]; then
   echo same time
   rm -f ${PIDFILE}
   exit
fi

# 送信関数
function send_imp_metrix(){

        #echo "ssp = ${1}" "number = ${2}"
        curl  -X POST -H "Content-type: application/json" \
        -d "{ \"series\" :
                 [{\"metric\":\"ssp.imp\",
                  \"points\":[[${currentimptime}, ${2}]],
                  \"type\":\"gauge\",
                  \"host\":\"${host_name}\",
                  \"tags\":[\"imp:${1}\"]}]
            }" \
        'https://app.datadoghq.com/api/v1/series?api_key=0710f2e8e084bce4dc47dabd4364929b'

}
function convert_ssp(){
  case "$1" in
     1 ) echo "google" ;;
     2 ) echo "microad" ;;
     3 ) echo "openx" ;;
     4 ) echo "geniee" ;;
     5 ) echo "fluct" ;;
     6 ) echo "kauli" ;;
     7 ) echo "test" ;;
     8 ) echo "fluctMobile" ;;
     9 ) echo "yieldone" ;;
    10 ) echo "adstir" ;;
    11 ) echo "googlemobile" ;;
    12 ) echo "xrost" ;;
    13 ) echo "openxmobile" ;;
    14 ) echo "xrostMobile" ;;
    15 ) echo "genieeMobile" ;;
    16 ) echo "aol" ;;
    17 ) echo "aolMobile" ;;
    18 ) echo "bidswitch" ;;
    19 ) echo "bidswitchMobile" ;;
    20 ) echo "pubmatic" ;;
    21 ) echo "pubmaticMobile" ;;
    22 ) echo "microadMobile" ;;
    23 ) echo "profitx" ;;
    24 ) echo "polyMobile" ;;
    25 ) echo "rubicon" ;;
    26 ) echo "rubiconMobile" ;;
    27 ) echo "googleapp" ;;
    28 ) echo "gmo" ;;
    30 ) echo "microadMobileNative" ;;
    31 ) echo "googlePcNative" ;;
    32 ) echo "googleMobileNative" ;;
    33 ) echo "gmoPc" ;;
    *) echo other $1 ;;
  esac
}

# 実行
cat ${CHECKFILE} |while read line
do
    ssp=`echo ${line}|awk -F"," '{print $1}'`
    bid=`echo ${line}|awk -F"," '{print $2}'`
    ssp=`convert_ssp ${ssp}` 
    send_imp_metrix ${ssp} ${bid}
done

# PIDFILEcheck end
rm -f ${PIDFILE}
