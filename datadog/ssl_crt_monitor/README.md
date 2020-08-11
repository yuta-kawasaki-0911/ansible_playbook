# SSL/TSL Expiration Monitor Plugin for DataDog
SSL/TSL証明書の有効期限を監視するためのDataDogスクリプトと、それをデプロイするためのAnsible playbookです。

This directory contains DataDog custom check script to monitor expiration of SSL/TSL certificates, and Ansible playbooks to deploy the script.

## Ansible Playbook
The purpose of this playbook is to copy the python file and yaml file to several hosts as well as restart the datadog agent afterwards.

Execute the following command to run the playbook:

```
cd datadog/ssl_crt_monitor
ansible-playbook ssldomain.yml -i../inventory/hosts
```
