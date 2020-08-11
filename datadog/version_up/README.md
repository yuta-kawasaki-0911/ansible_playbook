# Description
This playbook will update datadog-agent to version 6.x. The playbook includes running the one-step installation script and importing custom checks to the new directory. 

Execute the command below to run the playbook for datadog version up 6.0:
```
cd datadog/version_up
ansible-playbook versionsix.yml -i ../inventory/hosts
```
Execute the command below to run the playbook for subversion up:
```
cd datadog/version_up
ansible-playbook versionup.yml -i ../inventory/hosts
```
Execute the command below to run the playbook to disable the usage of api_v2:
```
cd datadog/version_up
ansible-playbook disable_apiv2.yml -i ../inventory/hosts
```

# References
* https://github.com/DataDog/datadog-agent/blob/master/docs/agent/upgrade.md#one-step-install
* https://github.com/DataDog/datadog-agent/blob/master/docs/agent/upgrade.md#enable-desired-custom-checks-optional
