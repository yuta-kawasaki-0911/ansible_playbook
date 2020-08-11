#!/bin/sh
#init

echo "start"

#####初期値設定
#DB
dbname=dsp
hostname=dbs02

#基本作業ディレクトリ
wkdirBase=/home/yokoi

#アカウントID
ACCOUNT_ID=722

#取得期間を設定(実行日7日前～実行日前日) ######
STARTDATE=`date -d '7 days ago' '+%Y%m%d'`
ENDDATE=`date -d '1 days ago' '+%Y%m%d'`

#メール送信先(カンマ区切りで複数宛先可)
MAIL_TO=saito@fullspeed.co.jp
CC=dsp_dev@fullspeed.co.jp
BCC=

#メール本文ファイル
MAIL_FILE=${wkdirBase}/mail_body.txt

#メール題名
SUBJECT=LPマークリスト抽出結果

#メール送信元
MAIL_FROM=dsptmp_uto@fullspeed.co.jp


####引数存在チェック
if [ $# -gt 0 ]; then
  if [ $# -lt 3 ]; then
    echo "引数を指定する場合、引数１～３は必須です。"
    echo "引数１：アカウントID"
    echo "引数２：対象期間（開始）YYYYMMDD形式"
    echo "引数３：対象期間（終了）YYYYMMDD形式"
    echo "引数４(任意)：メールアドレス"
    echo " 実行例1(引数未指定)：sh ip_marklist.sh"
    echo " 実行例2(宛先メールアドレス未指定)：sh ip_marklist.sh 722 20160721 20160728"
    echo " 実行例3(宛先メールアドレス指定)：sh ip_marklist.sh 722 20160721 20160728 dsp_dev@fullspeed.co.jp"
    echo "end"
    exit 1
  fi
fi


#####引数設定
#アカウントID
if [ -n "$1" ]; then
  ACCOUNT_ID=$1
fi 

#対象期間（開始）
if [ -n "$2" ]; then
  STARTDATE=$2
fi 

#対象期間（終了）
if [ -n "$3" ]; then
  ENDDATE=$3
fi 

#メールアドレス"#
if [ -n "$4" ]; then
  MAIL_TO=$4
fi 

echo "・アカウントID:"${ACCOUNT_ID}
echo "・対象期間:"${STARTDATE}"～"${ENDDATE}
echo "・送信先メールアドレス:"${MAIL_TO}
echo ""


#作業ディレクトリ
wkdir=${wkdirBase}/"lp_marklist_wk_"${ACCOUNT_ID}_${STARTDATE}_${ENDDATE}
mkdir ${wkdir}


######HDFSから抽出######
hdfsFilename=${wkdir}/tmp_lpmarklist.txt

CURRENTDATE=$STARTDATE
while [ 1 ] ; do

  cmd="sudo -u hdfs hdfs dfs -text /user/hdfs/account/${ACCOUNT_ID}/${CURRENTDATE}/raw/nodisplay-inflow_${ACCOUNT_ID}_*"
  echo "${cmd}"
  eval ${cmd} >> ${hdfsFilename}

  if [ ${CURRENTDATE} = ${ENDDATE} ] ; then
      break
  fi

  CURRENTDATE=`date -d "${CURRENTDATE} 1day" "+%Y%m%d"`
done


######IPアドレスを連結した文字列を生成######
ipaddressFilename=${wkdir}/tmp_ipaddress.txt

while read line
do

  line=`echo ${line} | tr -d ' '`
  dbInfoArray=(`echo ${line} | sed -e 's/%#/ /g'`)

  if [ "-" = ${dbInfoArray[7]} ]; then
    continue
  fi

  echo ${dbInfoArray[10]} >> ${ipaddressFilename}

done < ${hdfsFilename}


if [ -e ${ipaddressFilename} ]; then
  ipaddressArray=( `awk '!a[$0]++' ${ipaddressFilename}` )
fi
printf -v ipaddressStr '"%s",' ${ipaddressArray[@]}



#####DB接続から取得。結果をファイル出力#####
dbResultFilename=${wkdir}/tmp_db_result_list.txt
sqlStr="select ip,company_code,org_name,org_address from m_ip_info where ip in ("${ipaddressStr%,}")"

mysql -h ${hostname} -u root -psysdev ${dbname} -e "${sqlStr}"  > ${dbResultFilename}


#####DB抽出結果からCSV生成#####
csvFilenameUtf8=${wkdir}/"LP_リスト_"${STARTDATE}"_"${ENDDATE}_utf8.csv
csvFilename=${wkdir}/"LP_リスト_"${STARTDATE}"_"${ENDDATE}.csv

#ヘッダ行
echo "IPアドレス,企業コード,企業名,住所" > ${csvFilenameUtf8}

linesNumber=`cat ${dbResultFilename} | wc -l`

if [ ${linesNumber} -eq 0 ]; then

  echo "該当情報なし" > ${csvFilename}

else

  cat ${dbResultFilename} | while read line
  do

    IFS="$(echo -e '\t' )"
    dbRowArray=(${line})

    #1列目がIPアドレス以外の行、対象外
    ROW_CHECK=$(echo ${dbRowArray[0]} | egrep "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}")
    if [ ! "${ROW_CHECK}" ] ; then
      continue
    fi

    #企業コード(2列目)が NULL または 1 の行は対象外
    if [ "NULL" = ${dbRowArray[1]} ]; then
      continue
    fi
    if [ "1" = ${dbRowArray[1]} ]; then
      continue
    fi

    #企業名がNULLの場合"-"表示
    org_name=${dbRowArray[2]}
    if [ "NULL" = ${org_name} ]; then
      org_name="-"
    fi

    #住所がNULLの場合"-"表示
    org_address=${dbRowArray[3]}
    if [ "NULL" = ${org_address} ]; then
      org_address="-"
    fi

    #CSV出力
    echo "${dbRowArray[0]},${dbRowArray[1]},${org_name},${org_address}" >> ${csvFilenameUtf8}

  done

fi

unset IFS

#文字コード変換(UTF8->SJIS)
iconv -f UTF8 -t SHIFT-JIS ${csvFilenameUtf8} > ${csvFilename}


#####メール送信処理#####
sendMail() {
    from="$1"
    to="$2"
    cc="$3"
    bcc="$4"
    subject="$5"
    contents="$6"
    attachFile="$7"

    inputEncoding="utf-8"
    outputEncoding="iso-2022-jp"
    subjectHead="=?$outputEncoding?B?"
    subjectBody="`echo "$subject" | iconv -f $inputEncoding -t $outputEncoding | base64 | tr -d '\n'`"
    subjectTail="?="
    fullSubject="$subjectHead$subjectBody$subjectTail"

    echo "$contents" | mailx -a $attachFile -s "$fullSubject" -c "$cc" -b "$bcc" -r "$from" "$to"

    return $?
}


# mail
MAIL_OUT_FILE=${wkdir}/tmp_send_mail.txt

if [ -e $MAIL_FILE ]; then
  `tr -d "\r" <$MAIL_FILE> "$MAIL_OUT_FILE"`

  sendMail "$MAIL_FROM" "$MAIL_TO" "$CC" "$BCC" "$SUBJECT" "`cat $MAIL_OUT_FILE`" "${csvFilename}"
else
  echo "$MAIL_FILE NOT found."
fi


######一時ファイル削除######
rm -rf ${wkdir}


exit $status

