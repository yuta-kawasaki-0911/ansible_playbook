# Check if too many processes

## Description
The purpose of this playbook is to copy the `process.yaml` file to all hosts. However, if the file already exists then it will just append the instance to the yaml file.

Execute the command below to run the playbook:
```
cd datadog/process_num_check
ansible-playbook process_num_check.yml -i ../inventory/hosts
```

#### Jira ticket:
https://fullspeed.atlassian.net/browse/AJBC-946
