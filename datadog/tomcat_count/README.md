# Check if too there are multiple tomcat process

## Description
The purpose of this playbook is to copy the `process.yaml` file to the selected hosts where tomcat is running. However, if the file already exists then it will just append the instance to the yaml file.

Execute the command below to run the playbook:
```
cd datadog/tomcat_count
ansible-playbook tomcat_process.yml -i ../inventory/hosts
```

#### Jira ticket:
https://fullspeed.atlassian.net/browse/AJBC-1599