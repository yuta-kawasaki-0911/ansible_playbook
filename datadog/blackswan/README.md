# Monitor "brand safe data count" and "query candidate count"

## Description
The purpose of this playbook is to copy the `conf.yaml` file to the specified hosts. However, if the file already exists then it will just append the queries/query to the yaml file. This configuration will enable datadog to execute mysql query to the database to get the "brand safe data count" and "query candidate count".

Execute the command below to run the playbook:
```
cd datadog/blackswan
ansible-playbook blackswan_count.yml -i ../inventory/hosts
```

#### Jira ticket:
https://fullspeed.atlassian.net/browse/AJBC-1718
