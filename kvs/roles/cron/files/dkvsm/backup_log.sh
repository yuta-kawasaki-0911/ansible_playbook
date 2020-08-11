#!/bin/bash

ROOT="/etc/fsdkvs"
. $ROOT/bin/lib-daily.sh

log_to_tar $ROOT/logs 7 DEL
tar_delete $ROOT/logs 31
