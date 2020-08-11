#!/bin/bash -x

#### logfile compress & move


## environment

HOST_NAME=`hostname -s`

APACHE_LOGDIR=/usr/local/apache2/logs
APACHE_BACKUP_LOGDIR=/nas/backup/dapi_logs/$HOST_NAME/apache

TOMCAT_LOGDIR=/usr/local/tomcat/logs
TOMCAT_BACKUP_LOGDIR=/nas/backup/dapi_logs/$HOST_NAME/tomcat

LOG_APACHE=/root/maintenance/compress.log.apache
TARGET_LIST_APACHE=/root/maintenance/list.out.apache

LOG_TOMCAT=/root/maintenance/compress.log.tomcat
TARGET_LIST_TOMCAT=/root/maintenance/list.out.tomcat

### apache

## logfile compress target check
/bin/find $APACHE_LOGDIR -mtime +6 -print  > $TARGET_LIST_APACHE
#count=`wc -l $TARGET_LIST_APACHE | cut -c-2`
count=`cat $TARGET_LIST_APACHE | grep "log" | grep -v "httpd.pid" | wc -l`

if [ $count -eq 0 ]; then
	echo "There are no such compress target! "
	exit 0
fi


## logfile compress start
/usr/bin/ionice -c3 /bin/find $APACHE_LOGDIR -name "*log*" -mtime +6 -print -exec gzip {} \; > $LOG_APACHE

RETVAL=$?

if [ $RETVAL -ne 0 ]; then
	echo "apache log compress failed!"
	exit 1
fi

## logfile mv start
ionice -c3 /usr/bin/ionice -c3 mv $APACHE_LOGDIR/*gz $APACHE_BACKUP_LOGDIR

RETVAL=$?

if [ $RETVAL -ne 0 ]; then
	echo "apache log mv failed!"
	exit 1
fi

## complete message
echo "apache log file compress & mv complete!"

exit 0
