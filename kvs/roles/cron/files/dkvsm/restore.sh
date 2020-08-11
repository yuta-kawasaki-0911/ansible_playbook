#!/bin/sh
#init

echo "restore start" `date` >> /tmp/date.log

ssh_user=fsdkvs
home=/etc/fsdkvs/bin
save=/etc/fsdkvs/bin/save.sh

sockets="dkvs06#6394 dkvs05#6394 dkvs04#6394 dkvs03#6394 dkvs02#6394 dkvs01#6394 dkvs06#6393 dkvs05#6393 dkvs04#6393 dkvs03#6393 dkvs02#6393 dkvs01#6393 dkvs06#6392 dkvs05#6392 dkvs04#6392 dkvs03#6392 dkvs02#6392 dkvs01#6392 dkvs06#6391 dkvs05#6391 dkvs04#6391 dkvs03#6391 dkvs02#6391 dkvs01#6391 dkvs06#6390 dkvs05#6390 dkvs04#6390 dkvs03#6390 dkvs02#6390 dkvs01#6390 dkvs06#6389 dkvs05#6389 dkvs04#6389 dkvs03#6389 dkvs02#6389 dkvs01#6389 dkvs06#6388 dkvs05#6388 dkvs04#6388 dkvs03#6388 dkvs02#6388 dkvs01#6388 dkvs06#6387 dkvs05#6387 dkvs04#6387 dkvs03#6387 dkvs02#6387 dkvs01#6387 dkvs06#6386 dkvs05#6386 dkvs04#6386 dkvs03#6386 dkvs02#6386 dkvs01#6386 dkvs06#6385 dkvs05#6385 dkvs04#6385 dkvs03#6385 dkvs02#6385 dkvs01#6385 dkvs06#6384 dkvs05#6384 dkvs04#6384 dkvs03#6384 dkvs02#6384 dkvs01#6384 dkvs06#6383 dkvs05#6383 dkvs04#6383 dkvs03#6383 dkvs02#6383 dkvs01#6383 dkvs06#6382 dkvs05#6382 dkvs04#6382 dkvs03#6382 dkvs02#6382 dkvs01#6382 dkvs06#6381 dkvs05#6381 dkvs04#6381 dkvs03#6381 dkvs02#6381 dkvs01#6381 dkvs06#6380 dkvs05#6380 dkvs04#6380 dkvs03#6380 dkvs02#6380 dkvs01#6380 dkvs06#6379 dkvs05#6379 dkvs04#6379 dkvs03#6379 dkvs02#6379 dkvs01#6379"
#sockets="dkvs04#6394"

for socket in $sockets
do
  echo "fsdkvs maintenance ${socket} out -restorable"
  result=`fsdkvs maintenance ${socket} out -restorable`
  if [ "${result}" != "success" ]; then
    echo ${result}
    exit
  fi
  sleep 1

  server=`echo $socket | cut -d"#" -f1`
  port=`echo $socket | cut -d"#" -f2`

  echo "sudo -u ${ssh_user} ssh ${server} ${save} ${port} start"
  sudo -u ${ssh_user} ssh ${server} sudo rm -fr ${home}/end_save
  sudo -u ${ssh_user} ssh ${server} sudo ${save} ${port}

  sleep 5

  echo "fsdkvs restore dmp ${socket} random"
  fsdkvs restore dmp ${socket} random

  num=0
  until [ $num == 1 ]
  do
    sleep 1
    num=`sudo -u ${ssh_user} ssh ${server} "find ${home} -name  end_save | wc -l"`
  done

  sudo -u ${ssh_user} ssh ${server} sudo rm -fr ${home}/end_save

  echo "sudo -u ${ssh_user} ssh ${server} ${save} ${port} end"
  echo "fsdkvs maintenance ${socket} in"
  fsdkvs maintenance ${socket} in
  sleep 5
done

echo "restore end  " `date` >> /tmp/date.log

echo "move start " `date` >> /tmp/date.log
# nas 不整合による一次対応 06のみcronで06からrnasに転送している.
move=/etc/fsdkvs/bin/move.sh
hosts="dkvs05 dkvs04 dkvs03 dkvs02 dkvs01"
for server in $hosts
do
  echo "cp dump ${server}"
  sudo -u ${ssh_user} ssh ${server} sudo ${move}
done

echo "move end " `date` >> /tmp/date.log
