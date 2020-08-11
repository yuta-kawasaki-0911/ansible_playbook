# Check if Java is using 90% of the cpu

## Description
The purpose of this playbook is to copy the `process.yaml` file to hosts that have java installed. However, if the file already exists then it will just append the instance to the yaml file.

Execute the command below to run the playbook:
```
cd datadog/java_process_check
ansible-playbook java_process.yml -i ../inventory/hosts
```

#### Jira ticket:
https://fullspeed.atlassian.net/browse/AJBC-1592