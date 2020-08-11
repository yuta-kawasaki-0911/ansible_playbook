# DataDog設定ファイル
> # DataDog Configuration Files

## 説明
> ## Description

DataDog設定ファイルを各サーバの`/etc/datadog-agent/`にデプロイします。

> The purpose of this playbook is to copy the datadog configurations to `/etc/datadog-agent/`

#### 個別サーバグループへの適用
> #### One Server Group Affected

DataDogの設定変更やカスタムメトリクスを追加する場合など`conf/files/<servertype>/datadog`のファイルを修正し、サーバにデプロイする必要がある。
下記コマンドは、特定のサーバ種へ設定ファイルをデプロイする。例：SSL証明書有効期限チェックのためPythonスクリプトをutil01にデプロイする。

> So in case there is a need to update those configuration or add custom checks, one must update the files found in `conf/files/<servertype>/datadog` and run the playbook. The command below is advisable if a change will only affect **one** server type, e.g. need to deploy a python script for checking the SSL to util01 only. 

下記で１つのplaybookを適用する
> Execute the command below to run the a **single** playbook:
```
cd maintenance/datadog
ansible-playbook conf/<servertype>.yml -i hosts
```
#### 全サーバグループへの適用
> #### Multiple Server Group Affected

全サーバに適用する場合、`conf/files/<servertype>/datadog`のそれぞれのファイルを修正し、下記**release_all.yml**を実行し、すべてのサーバ種用のplaybookを適用する。
> In a scenario where multiple server is affected, update the files found in `conf/files/<servertype>/datadog` and run the **release_all.yml**. Running the release_all.yml playbook will run all the playbook for all server group.

```
cd maintenance/datadog
ansible-playbook release_all.yml -i hosts
```

### Jira ticket:
https://fullspeed.atlassian.net/browse/AJBC-1829
