#!/bin/bash

export WORK_DIR="work"

export APACHE_DIR="/usr/local/apache2"
export TOMCAT_DIR="/usr/local/tomcat"
export APP_DIR="/var/app"
export SERVING_APP_DIR="/var/app/serving"
export ACQ_APP_DIR="/var/app/acq"
export OPTOUT_APP_DIR="/var/app/optout"
export UNITAG_APP_DIR="/var/app/unitag"

export LOG_DIR_NAME="logs"
export DBDUMP_DIR_NAME="dbdump"

export APACHE_LOG_DIR="$APACHE_DIR/$LOG_DIR_NAME"
export TOMCAT_LOG_DIR="$TOMCAT_DIR/$LOG_DIR_NAME"
export SERVING_LOG_DIR="$SERVING_APP_DIR/$LOG_DIR_NAME"
export ACQ_LOG_DIR="$ACQ_APP_DIR/$LOG_DIR_NAME"
export OPTOUT_LOG_DIR="$OPTOUT_APP_DIR/$LOG_DIR_NAME"
export UNITAG_LOG_DIR="$UNITAG_APP_DIR/$LOG_DIR_NAME"

export MYSQL_DUMP_FILE="mysqldump.sql"

export DATE_FORMAT='%Y%m%d'
export CURRENT_DATE=$(date "+$DATE_FORMAT")
export SERVER_NAME=${HOSTNAME%%.*}
export BASE_DIR="$CURRENT_DATE/$SERVER_NAME"

export NFS_MOUNT_DIR="/nas"
export BASE_DESTINATION_DIR="$NFS_MOUNT_DIR/backup"
export LOG_COPY_DESTINATION_DIR="$BASE_DESTINATION_DIR/$LOG_DIR_NAME"
export DUMP_COPY_DESTINATION_DIR="$BASE_DESTINATION_DIR/$DBDUMP_DIR_NAME"
