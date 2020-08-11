# Get all running processes

## Description
The purpose of this playbook is to copy the `processes_running.yaml` and `processes_running.py` files to all hosts.

Execute the command below to run the playbook:
```
cd datadog/processes_running/
ansible-playbook -i ../inventory/hosts processes_running.yml
```

#### Jira ticket:
https://fullspeed.atlassian.net/browse/AJBC-945

