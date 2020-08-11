#!/bin/bash

export EXE_CMD_DIR="/home/honda/temp/"
export WORK_DIR="work"

export NGINX_DIR="/var/log"
export TOMCAT_DIR="/usr/local/tomcat"
export TOMCAT_DMP_DIR="/usr/local/tomcat-dmp"
export APP_DIR="/var/app"

export LOG_DIR_NAME="logs"
export NGINX_LOG_DIR_NAME="nginx"

export NGINX_LOG_DIR="$NGINX_DIR/$NGINX_LOG_DIR_NAME"
export TOMCAT_LOG_DIR="$TOMCAT_DIR/$LOG_DIR_NAME"
export TOMCAT_DMP_LOG_DIR="$TOMCAT_DMP_DIR/$LOG_DIR_NAME"

export NGINX_LOG_TIMELINE="$NGINX_DIR/$NGINX_LOG_DIR_NAME/timeline"
export TOMCAT_LOG_TIMELINE="$TOMCAT_DIR/$LOG_DIR_NAME/timeline"
export TOMCAT_DMP_LOG_TIMELINE="$TOMCAT_DMP_DIR/$LOG_DIR_NAME/timeline"

export DATE_FORMAT='%Y%m%d'
export CURRENT_DATE=$(date "+$DATE_FORMAT")
export SERVER_NAME=${HOSTNAME%%.*}
export BASE_DIR="$CURRENT_DATE/$SERVER_NAME"

export NFS_MOUNT_DIR="/nas"
export BASE_DESTINATION_DIR="$NFS_MOUNT_DIR/backup"
export LOG_COPY_DESTINATION_DIR="$BASE_DESTINATION_DIR/$LOG_DIR_NAME"

export NGINX_LOG_EXPIRE=7
export TOMCAT_LOG_EXPIRE=7
export ERROR_LOG_EXPIRE=14

