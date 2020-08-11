## toc
* [全体概要](#全体概要)
* [事前準備](#事前準備)
* [構築手順](#構築手順)

## 全体概要
* ディレクトリ構造とプログラム一覧
	* トップディレクトリ
		* `/home/ansible/dbatch`

```
.
├── README.md
├── build_dbatch01.yml
├── build_dbatch02.yml
├── build_dbatch03.yml
├── inventory
│   └── hosts
├── roles
│   ├── dbatch02
│   │   ├── files
│   │   │   ├── daily_budget_control_check.sh
│   │   │   ├── error_log_size_check.sh
│   │   │   ├── imp_check.sh
│   │   │   └── sysops
│   │   └── tasks
│   │       └── main.yml
│   ├── dbatch03
│   │   ├── files
│   │   │   └── sysops
│   │   └── tasks
│   │       └── main.yml
│   └── nginx
│       ├── files
│       │   └── dbatch01
│       │       ├── cron
│       │       │   ├── logrotate
│       │       │   └── makewhatis.cron
│       │       ├── default.conf
│       │       ├── logrotate_nginx
│       │       ├── mime.types
│       │       └── nginx.conf
│       └── tasks
│           └── main.yml
└── vars
    ├── dbatch01_nginx.yml
    ├── dbatch01_ubu_cron.yml
    ├── dbatch01_ubu_mount.yml
    └── mount_dbatch03.yml
```

## 事前準備
* ansibleユーザーの作成。
* ansibleユーザーにmanagementサーバーのSSH鍵の登録。
* [【参考】新しくサーバを追加するときの手順](https://qiita.com/hogepiyo/items/e698036e52661c333f4c)

## 構築手順
### dbatch01
* hostsの[add]グループに対象ホストを記載。
* 以下のplaybookを実行。
	* 共通設定のみ実施

```
ansible-playbook build_dbatch01.yml -i hosts
```

* 上記完了後にユーザ/sysopsグループの作成を行う。

```
cd /home/ansible/operation
inventories/hosts にユーザを作成したいホスト名を記載
ansible-playbook create_users.yml -i inventories/hosts
ansible-playbook set_group.yml -i inventories/hosts
```

* SSL証明書のパスは以下の通り。

```
※例はsweb01
worker@sweb01-ubuntu:~/deploy/shared/nginx/ssl$ pwd
/home/worker/deploy/shared/nginx/ssl
worker@sweb01-ubuntu:~/deploy/shared/nginx/ssl$ ls
server.crt  server.key
```


### dbatch02
* hostsの[add]グループに対象ファイルを記入。
* 以下のコマンドを実行。

```
ansible-playbook build_dbatch02.yml -i inventory/hosts
```

* 上記完了後にユーザ/sysopsグループの作成を行う。

```
cd /home/ansible/operation
inventories/hosts にユーザを作成したいホスト名を記載
ansible-playbook create_users.yml -i inventories/hosts
ansible-playbook set_group.yml -i inventories/hosts
```

* rootユーザ / tomcatユーザの`authorized_keys`を以下で管理しているので、ホームディレクトリ配下の`.ssh`下に格納すること。（オーナーは各ユーザ、権限は600）
	* [dbatch02_authorized_keys](https://github.com/FullSpeedInc/admatrix_docs_infrastructure/tree/master/configuration_management/dbatch/dbatch02)

### dbatch03
* hostsの[add]グループに対象ファイルを記入。
* 以下のコマンドを実行。

```
ansible-playbook build_dbatch02.yml -i inventory/hosts
```

* 上記完了後にユーザ/sysopsグループの作成を行う。

```
cd /home/ansible/operation
inventories/hosts にユーザを作成したいホスト名を記載
ansible-playbook create_users.yml -i inventories/hosts
ansible-playbook set_group.yml -i inventories/hosts
```

* rootユーザ / tomcatユーザの`authorized_keys`を以下で管理しているので、ホームディレクトリ配下の`.ssh`下に配置すること。
	* オーナーは各ユーザ、権限は600）
	* [dbatch03_authorized_keys](https://github.com/FullSpeedInc/admatrix_docs_infrastructure/tree/master/configuration_management/dbatch/dbatch03)