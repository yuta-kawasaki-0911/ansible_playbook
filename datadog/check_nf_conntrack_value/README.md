# Check if idle nf_conntrack is less than 10%

## Description
The purpose of this playbook is to copy the `check_nf_conntrack_count.yaml` and `check_nf_conntrack_count.py` files to all hosts.

Execute the command below to run the playbook:
```
ansible-playbook -i ../inventory/hosts check_nf_conntrack.yml
```

#### Jira ticket:
https://fullspeed.atlassian.net/browse/AJBC-959

