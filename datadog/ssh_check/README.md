# Description
DataDog標準のサーバヘルスチェックだとダウンしていないのにダウンと検出されることがしばしばある。代替手段としてsshの接続可否によりヘルスチェックを行う。   
> We need to monitor the server's health in a more reliable manner. Using the ssh_check provided by datadog solves this issue.

Execute the command below to run the playbook:
```
cd datadog/ssh_check
ansible-playbook ssh_check.yml -i ../inventory/hosts
```

# References
* https://dev.classmethod.jp/cloud/aws/datadog-monitoring-ssh/
* https://fullspeed.atlassian.net/browse/AJBC-583
