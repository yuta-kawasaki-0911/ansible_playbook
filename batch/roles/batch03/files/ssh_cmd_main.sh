#!/bin/bash

user="root"
pass="sysdev"
ssh_cmd="ls -la /home"
server="batch02"

cmd="/home/honda/ssh_cmd.sh ${user} ${pass} ${server} '${ssh_cmd}' > /home/honda/ssh_cmd.txt"
echo "${cmd}"
eval ${cmd}
