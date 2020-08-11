#!/bin/bash

ROOT="/var/app/fs/dsp"
. $ROOT/bin/lib-daily.sh

log_to_tar $ROOT/log 7 DEL
tar_delete $ROOT/log 31

log_to_tar $ROOT/data/bid 3 DEL
tar_delete $ROOT/data/bid 31

log_to_tar $ROOT/data/bidinventory 3 DEL
tar_delete $ROOT/data/bidinventory 31

log_to_tar $ROOT/data/bidreq 3 DEL
tar_delete $ROOT/data/bidreq 31

log_to_tar $ROOT/data/mark 7 DEL
tar_delete $ROOT/data/mark 100

log_to_tar $ROOT/data/segment 7 DEL
tar_delete $ROOT/data/segment 100

log_to_tar $ROOT/data/geo 7 DEL
tar_delete $ROOT/data/geo 31

log_to_tar $ROOT/data/geo_uid 7 DEL
tar_delete $ROOT/data/geo_uid 100

DATE=`date --date "31 day ago" +%Y%m%d`
rm -rf $ROOT/data/ami/$DATE*