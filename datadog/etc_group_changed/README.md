# Check if /etc/group has been changed

## Description
The purpose of this playbook is to copy the `directory.yaml` file to all hosts. However, if the file already exists then it will just append the instance to the yaml file.

Execute the command below to run the playbook:
```
cd datadog/etc_group_changed
ansible-playbook group.yml -i ../inventory/hosts
```

#### Jira ticket:
https://fullspeed.atlassian.net/browse/AJBC-954
