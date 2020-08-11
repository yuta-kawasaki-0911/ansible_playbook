# Check if rsyslogd is not running

## Ansible Playbook
The purpose of this playbook is to include the rsyslogd process in the list of processes that needs to be monitored from production servers.

If the `process.yaml` file already exists in the server, a rsyslogd instance shall be appended in the file.
Otherwise, `process.yaml` shall be created/copied into the server.

Execute the following command to run the playbook:

```
cd datadog/rsyslogd_is_not_running/
ansible-playbook -i ../inventory/hosts, rsyslogd.yml
```

