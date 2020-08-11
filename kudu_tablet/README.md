## toc
* [全体概要](#全体概要)
* [事前準備](#事前準備)

## 全体概要
* ディレクトリ構造とプログラム一覧
	* トップディレクトリ
		* `/home/ansible/kudu_tablet`

```
.
├── README.md
├── build.yml
├── inventory
│   ├── hosts
│   └── hosts.bk
├── modify_network_files.yml
├── parted_disks.yml
├── roles
│   ├── agentupdate
│   │   ├── files
│   │   │   └── cloudera-manager.repo
│   │   └── tasks
│   │       └── main.yml
│   ├── common
│   │   ├── files
│   │   │   ├── centos6.8
│   │   │   │   ├── CentOS-Base.repo
│   │   │   │   └── CentOS-Vault.repo
│   │   │   ├── fullspeed.repo
│   │   │   ├── kudu-tserver.conf
│   │   │   └── sysctl.conf
│   │   └── tasks
│   │       └── main.yml
│   ├── mount
│   │   └── tasks
│   │       └── main.yml
│   ├── parted_disks
│   │   └── tasks
│   │       └── main.yml
│   ├── service
│   │   ├── files
│   │   │   └── cloudera-manager.repo
│   │   └── tasks
│   │       └── main.yml
│   └── yumrepo
│       ├── files
│       │   └── cloudera-manager.repo
│       └── tasks
│           └── main.yml
└── vars
    └── mount.yml
```

## 事前準備
* ansibleユーザーの作成
* ansibleユーザーにmanagementサーバーのSSH鍵の登録

## 備考
* kudu playbookに関してはリサーチ管轄の別リポジトリで管理している
