# Check if cron is running

## Ansible Playbook
The purpose of this playbook is to include the CRON process in the list of processes that needs to be monitored from production servers.

If the `process.yaml` file already exists in the server, a cron instance shall be appended in the file.
Otherwise, `process.yaml` shall be created/copied into the server.

Execute the following command to run the playbook:

```
cd datadog/crond_process_check
ansible-playbook cron.yml -i ../inventory/hosts
```
