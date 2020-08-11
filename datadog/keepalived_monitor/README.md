# Check if keepalived is running

## Description
The purpose of this playbook is to copy the `conf.yaml` file to hosts with keepalived process running. However, if the file already exists then it will just append the instance to the yaml file.

Execute the command below to run the playbook:
```
cd datadog/keepalived_monitor
ansible-playbook keepalived_monitor.yml -i ../inventory/hosts
```

#### Jira ticket:
https://fullspeed.atlassian.net/browse/AJBC-1640
