## toc
* [全体概要](#全体概要)
* [前提条件](#前提条件)
* [事前準備](#事前準備)
* [SSL証明書の有効期限確認プラグイン設定](#SSL証明書の有効期限確認プラグイン設定)

## 全体概要
* ディレクトリ構造とプログラム一覧
	* トップディレクトリ
		* `/home/ansible/datadog`

```
datadog/
├── README.md
├── blackswan
│   ├── README.md
│   ├── blackswan_count.yml
│   └── roles
│       └── blackswancount
│           ├── files
│           │   └── conf.yaml
│           └── tasks
│               └── main.yml
├── check_datadog_start_script.yml
├── check_nf_conntrack_value
│   ├── README.md
│   ├── check_nf_conntrack.yml
│   └── roles
│       └── conntrack
│           ├── files
│           │   ├── check_nf_conntrack_count.py
│           │   └── check_nf_conntrack_count.yaml
│           └── tasks
│               └── main.yml
├── crond_process_check
│   ├── README.md
│   ├── cron.yml
│   └── roles
│       └── cron
│           ├── files
│           │   └── process.yaml
│           └── tasks
│               └── main.yml
├── datadog-agent
├── etc_group_changed
│   ├── README.md
│   ├── group.yml
│   └── roles
│       └── group
│           ├── files
│           │   └── conf.yaml
│           └── tasks
│               └── main.yml
├── etc_passwd_changed
│   ├── README.md
│   ├── passwd.yml
│   └── roles
│       └── passwd
│           ├── files
│           │   └── conf.yaml
│           └── tasks
│               └── main.yml
├── inventory
│   ├── hosts
│   └── testhosts
├── java_process_check
│   ├── README.md
│   ├── java_process.yml
│   └── roles
│       └── javaprocess
│           ├── files
│           │   └── conf.yaml
│           └── tasks
│               └── main.yml
├── keepalived_monitor
│   ├── README.md
│   ├── keepalived_monitor.yml
│   └── roles
│       └── keepalived
│           ├── files
│           │   └── conf.yaml
│           └── tasks
│               └── main.yml
├── nginx_response_time
│   ├── README.md
│   ├── nginx_response_time.yml
│   └── roles
│       ├── api0x
│       │   ├── files
│       │   │   ├── log_file_helper.sh
│       │   │   ├── nginx_response_time.py
│       │   │   └── nginx_response_time.yaml
│       │   └── tasks
│       │       └── main.yml
│       ├── bidresult
│       │   ├── files
│       │   │   ├── log_file_helper.sh
│       │   │   ├── nginx_response_time.py
│       │   │   └── nginx_response_time.yaml
│       │   └── tasks
│       │       └── main.yml
│       ├── capi
│       │   ├── files
│       │   │   ├── log_file_helper.sh
│       │   │   ├── nginx_response_time.py
│       │   │   └── nginx_response_time.yaml
│       │   └── tasks
│       │       └── main.yml
│       ├── iapi
│       │   ├── files
│       │   │   ├── log_file_helper.sh
│       │   │   ├── nginx_response_time.py
│       │   │   └── nginx_response_time.yaml
│       │   └── tasks
│       │       └── main.yml
│       ├── img
│       │   ├── files
│       │   │   ├── log_file_helper.sh
│       │   │   ├── nginx_response_time.py
│       │   │   └── nginx_response_time.yaml
│       │   └── tasks
│       │       └── main.yml
│       ├── relay
│       │   ├── files
│       │   │   ├── log_file_helper.sh
│       │   │   ├── nginx_response_time.py
│       │   │   └── nginx_response_time.yaml
│       │   └── tasks
│       │       └── main.yml
│       └── tapi
│           ├── files
│           │   ├── log_file_helper.sh
│           │   ├── nginx_response_time.py
│           │   └── nginx_response_time.yaml
│           └── tasks
│               └── main.yml
├── process_num_check
│   ├── README.md
│   ├── process_num_check.yml
│   └── roles
│       └── process
│           ├── files
│           │   └── process.yaml
│           └── tasks
│               └── main.yml
├── processes_running
│   ├── README.md
│   ├── processes_running.yml
│   └── roles
│       └── processes_running
│           ├── files
│           │   ├── processes_running.py
│           │   └── processes_running.yaml
│           └── tasks
│               └── main.yml
├── rsyslogd_is_not_running
│   ├── README.md
│   ├── roles
│   │   └── rsyslogd
│   │       ├── files
│   │       │   └── process.d
│   │       │       └── conf.yaml
│   │       └── tasks
│   │           └── main.yml
│   └── rsyslogd.yml
├── ssh_check
│   ├── README.md
│   ├── roles
│   │   ├── generate_ssh_keys
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   ├── reporting_server
│   │   │   ├── files
│   │   │   │   └── conf.yaml
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   └── target_server
│   │       └── tasks
│   │           └── main.yml
│   └── ssh_check.yml
├── ssl_crt_monitor
│   ├── README.md
│   ├── deletessl.yml
│   ├── roles
│   │   ├── delete
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   └── domainssl
│   │       ├── files
│   │       │   ├── domain_ssl_cert_months_left.py
│   │       │   └── domain_ssl_cert_months_left.yaml
│   │       └── tasks
│   │           └── main.yml
│   └── ssldomain.yml
├── tomcat_count
│   ├── README.md
│   ├── roles
│   │   └── tomcat
│   │       ├── files
│   │       │   └── conf.yaml
│   │       └── tasks
│   │           └── main.yml
│   └── tomcat_process.yml
└── version_up
    ├── README.md
    ├── disable_apiv2.yml
    ├── hosts
    ├── roles
    │   ├── disableapiv2
    │   │   └── tasks
    │   │       └── main.yml
    │   ├── subversionup
    │   │   └── tasks
    │   │       └── main.yml
    │   └── versionsix
    │       └── tasks
    │           └── main.yml
    ├── versionsix.yml
    └── versionup.yml
```

## 前提条件
* 本領域は**セブ側のエンジニアが作成したPlaybookを管理**している。
	* 基本的に**インフラテクノロジー開発部で作成・修正・削除を行うことはない**
* セブ側の依頼によって、Playbookを適用することがある。
	* ただし、現時点ではセブ側にPlaybook実行の権限を付与しているので、基本的には依頼も発生しない想定

## 事前準備
* ansibleユーザーの作成。
* ansibleユーザーにmanagementサーバーのSSH鍵の登録。
	* [【参考】新しくサーバを追加するときの手順](https://qiita.com/hogepiyo/items/e698036e52661c333f4c)

## SSL証明書の有効期限確認プラグイン設定
### 前提条件
* util01から`datadog-agent`を利用して監視している設定が存在する。
* util01再構築を行った際には、再設定を行う必要がある。
* 参考となるJIRAチケットは以下のもの。
	* [[再実行]SSL/TSL Expiration Monitor Plugin for DataDog](https://fullspeed.atlassian.net/browse/SITB-1898)

### 実行コマンド

```
cd datadog/ssl_crt_monitor
ansible-playbook -i../inventory/hosts ssldomain.yml
```