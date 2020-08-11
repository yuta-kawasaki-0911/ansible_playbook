# Playbooks of Operation
* [全体概要](#全体概要)
* [前提条件](#前提条件)
* [VPNアカウント作成手順](#VPNアカウント作成手順)
* [構築・運用作業Playbook](#構築・運用作業用Playbook)
	* [Linuxユーザ作成](#Linuxユーザ作成)
	* [データベースユーザ作成](#データベースユーザ作成)
	* [グループ設定](#グループ設定)
	* [hostsファイル配布](#hostsファイル配布)
	* [ユーザへのsudo許可設定](#ユーザへのsudo許可設定)
	* [OMSAインストール](#OMSAインストール)
	* [keepalivedリロード](#keepalivedリロード)
	* [apacheサービスイン・アウト](#apacheサービスイン・アウト)
	* [nginxサービスイン・アウト](#nginxサービスイン・アウト)
	* [SSL証明書発行用CSR作成](#SSL証明書発行用CSR作成)
* [構成管理作業用Playbook](#構成管理作業用Playbook)
	* [apacheバージョン確認](#apacheバージョン確認)
	* [コア数チェック](#コア数チェック)
	* [CPU情報確認](#CPU情報確認)
	* [Hadoopバージョン確認](#Hadoopバージョン確認)
	* [javaバージョン確認](#javaバージョン確認)
	* [機器情報確認](#機器情報確認)
	* [メモリ情報確認](#メモリ情報確認)
	* [MySQLバージョン確認](#MySQLバージョン確認)
	* [nginxバージョン確認](#nginxバージョン確認)
	* [OSバージョン確認](#OSバージョン確認)
	* [rubyバージョン確認](#rubyバージョン確認)
	* [tomcatバージョン確認](#tomcatバージョン確認)
	* [稼働時間確認](#稼働時間確認)

## 全体概要
* ディレクトリ構造とプログラム一覧
	* トップディレクトリ
		* `/home/ansible/operation`

```
.
├── README.md
├── apache_lvs_change.yml
├── check_apache_ver.yml
├── check_cores.yml
├── check_cpu_spec.yml
├── check_hadoop_ver.yml
├── check_java_ver.yml
├── check_machine_spec.yml
├── check_memory_spec.yml
├── check_mysql_ver.yml
├── check_nginx_ver.yml
├── check_os_ver.yml
├── check_ruby_ver.yml
├── check_tomcat_ver.yml
├── check_uptime.yml
├── create_dbusers.yml
├── create_users.yml
├── create_vpn_account
│   └── README.md
├── delete_user.yml
├── export_routes.yml
├── generate_csr
│   ├── README.md
│   ├── created_files
│   │   ├── fullspeed.co.jp_20180723.csr
│   │   ├── fullspeed.co.jp_20180723.pem
│   │   ├── relay-dsp.ad-m.asia_20180419.csr
│   │   └── relay-dsp.ad-m.asia_20180419.pem
│   ├── generate_bidding-dsp_csr.yml
│   ├── generate_fullspeedcojp.yml
│   └── generate_relay-dsp.yml
├── give_hosts.yml
├── group_vars
│   ├── all.yml
│   └── databases.yml
├── hardware_check.yml
├── install_omsa.yml
├── inventories
│   ├── databases
│   ├── hosts
│   ├── production
│   ├── staging
│   ├── stg_databases
│   └── verification
├── lvs_reload.yml
├── manage_authorized_keys
│   ├── README.md
│   ├── group_vars
│   │   ├── api.yml
│   │   ├── bidresult_01.yml
│   │   ├── cal_03.yml
│   │   ├── dadmin_01.yml
│   │   ├── dapi.yml
│   │   ├── hsn_01.yml
│   │   ├── iapi.yml
│   │   └── relay_01.yml
│   ├── hosts
│   ├── roles
│   │   └── copy_file
│   │       ├── files
│   │       │   ├── api_authorized_keys
│   │       │   ├── bidresult01_authorized_keys
│   │       │   ├── cal03_authorized_keys
│   │       │   ├── dadmin01_authorized_keys
│   │       │   ├── dapi_authorized_keys
│   │       │   ├── iapi_authorized_keys
│   │       │   └── relay_authorized_keys
│   │       └── tasks
│   │           └── main.yml
│   └── set_authorized_key.yml
├── nginx_lvs_change.yml
├── roles
│   ├── add_user
│   │   └── tasks
│   │       └── main.yml
│   ├── dbuser
│   │   └── tasks
│   │       └── main.yml
│   ├── give_hosts
│   │   └── tasks
│   │       └── main.yml
│   ├── sudoers
│   │   ├── files
│   │   │   └── build01
│   │   └── tasks
│   │       └── main.yml
│   └── user
│       └── tasks
│           └── main.yml
├── set_group.yml
├── set_group_batch01.yml
└── set_sudoers_build01.yml
```

## 前提条件
* `operation`領域は各サーバ共通で処理を行うために用意したplaybookを管理している。
* ユーザやグループ関連の設定はセブ開発者向けのもの。
	* セブ開発者は個人ユーザで作業を行う為、**セブ環境VPN作成**の依頼が来た際に合わせて対応する必要がある
	* セブ開発者は東京環境とセブ環境でパスワードが異なる
	* 本領域で管理しているのは`東京環境`のパスワードである

## VPNアカウント作成手順
* 作業を行う機会が少ない為、手順を記録している。
* 詳細は以下を参照すること。
	* [VPNクライアント作成について](create_vpn_account/README.md)

## 構築・運用作業用Playbook
### Linuxユーザ作成
#### 事前準備
* 登録したいユーザ情報を決めておき、`group_vars/all.yml`にユーザ名とパスワードを記載する。

```
users_info:
  - { name: hogehoge, pass: hogehoge }
```

* インベントリファイルに`servers`グループを定義して、実行対象サーバのホスト名を記入する。
* コマンドラインで`-iオプション`を使用してインベントリファイルを指定する。 
	* `all` / `production` / `staging`

#### 実行コマンド

```
ansible-playbook create_users.yml -i <hosts_file>
```

### データベースユーザ作成
#### 事前準備
* 登録したいユーザ情報を決めておき、ユーザーリストファイル（`group_vars/ databases.yml、stg_databases.yml`）にユーザ名とパスワードを記載する。
* インベントリファイルに`database`グループを定義して、実行対象サーバのホスト名を記入する。
* コマンドラインで`-iオプション`を使用してインベントリファイルを指定する。

#### 注意事項
* **※masterとslave両方に処理を行うとDB停止を招く為、片方のみ実行するようにすること**
	* `slaveのみにユーザ登録を行いたい`という要件がない限り、`master`のみに実行すること
		* 現状、master / slave両方に同じユーザ設定がされている
* **※dbm02のみ~/.my.cnfがないためansibleでユーザ設定が行えないので、手動で設定する**

```
CREATE USER '[[username]]'@'%' IDENTIFIED BY '[[pass]]';
CREATE USER '[[username]]'@'localhost' IDENTIFIED BY '[[pass]]';
GRANT SELECT ON *.* TO '[[username]]'@'%' IDENTIFIED BY '[[pass]]';
GRANT SELECT ON *.* TO '[[username]]'@'localhost' IDENTIFIED BY '[[pass]]';
```

#### 実行コマンド

```
ansible-playbook create_dbusers.yml -i <hosts_file>
```

### グループ設定
#### 事前準備
* グループに追加したいメンバがいる場合、以下のファイルを予め更新しておくこと。
	* セブ開発者のVPN作成を行った場合、**漏れなく追加を行う**こと

```
vim group_vars/all.yml
```

#### 実行コマンド

```
ansible-playbook set_group.yml -i inventories/production
```

#### 備考
* セブエンジニアに関しては、特定の個人にsudoを付与するようなことはせず、devops_cebuやsysopsグループなどに所属させ、グループごとにsudoを実行できる権限を最小限に絞っている形で運用している。
	* sysops、devopsの権限の設定内容はサーバによって異なるので、必要に応じて整理する
* batch01に関しては以下のように定義している。

```
ansible-playbook -i inventory/production set_group_batch01.yml
```

* 所属ユーザーの設定を行うplaybookの作成と運用フローは別途、検討が必要。

* devops、sysopsグループに関しての設定は[server設定記録](https://docs.google.com/spreadsheets/d/10KchDPhj4vvgszfAptaxEkJHXjTU_jnK5tz0jYgHl9g/edit?usp=sharing)を参照。
	* 基本的には**各サーバの構築playbookにrolesを作成し、そこでsudoersの設定などを行っている**。

### hostsファイル配布
#### 事前準備
* あるサーバの構築が決まった際に`事前作業`を行っておくこと。
	* 基本設定のplaybookの中でhostsファイルの最新化を行う為

#### 事前作業
* hostsファイルに追加したいサーバがある場合、以下のファイルを予め更新しておくこと。

```
cd ~/admatrixDSP_infra_configfiles
git pull origin master
```

#### 注意事項
* ステージング環境のhostsファイルはバックエンドTが管理している為、**ステージング環境に対するhostsファイル配布処理は行わない**。
	* ステージング環境専用の名前解決をしており、二重管理と二重配布をうまくできないと判断
	* [JIRAチケット：【構成管理改善】ステージング環境のhostsファイル構成管理方式検討](https://fullspeed.atlassian.net/browse/SITB-1402)

### 実行コマンド

```
ansible-playbook -i inventories/production give_hosts.yml
```

### ユーザへのsudo許可設定
#### 事前準備
* 必要に応じて、`roles/sudoers/files/[[host name]]`を変更する。
	* sudoersによってロードされる `/etc/sudoers.d/sudoers`ファイルを置き換える処理を行う
* 基本的には**各サーバの構築playbookにrolesを作成し、そこでsudoersの設定などを行っている**。
	* `build01`はサーバ構築のplaybookが未作成の為、本領域で管理している

#### 実行コマンド

```
ansible-playbook set_sudoers_[[host name]].yml -i [production or staging]
```

### OMSAインストール
#### 実行コマンド

```
ansible-playbook -i inventories/production install_omsa.yml
```

### keepalivedリロード
#### 前提条件
* 通常、managementサーバのconfigでlvsに対して、playbookは実行できないようになっている。
* managementサーバのconfigにlvsのサーバ種別設定を追記する。

```
[ansible@management ~]$ vi ~/.ssh/config

host lvs*    # 該当するファイル名を書く。lvs01 - lvs08は全て*で含められる
StrictHostKeyChecking no
IdentityFile ~/.ssh/to_ansible_client    # 秘密鍵を指定
```

#### 実行コマンド

```
ansible-playbook -i inventories/production lvs_reload.yml
```

### apacheサービスイン・アウト
#### 前提条件
* inventory/hostsの[target]グループに構築対象のhostsを記載する。

#### 実行コマンド

```
■サービスアウト
ansible-playbook -i inventories/production apache_lvs_change.yml --tags remove

■サービスイン
ansible-playbook -i inventories/production apache_lvs_change.yml --tags add
```

### nginxサービスイン・アウト
#### 前提条件
* inventory/hostsの[target]グループに構築対象のhostsを記載する。

#### 実行コマンド

```
■サービスアウト
ansible-playbook -i inventories/production nginx_lvs_change.yml --tags remove

■サービスイン
ansible-playbook -i inventories/production nginx_lvs_change.yml --tags add
```

### SSL証明書発行用CSR作成
* 詳細は`generate_csr`領域を参照すること。
	* 前任者が作成したPlaybookで実行実績は無い為、利用する場合は注意すること

## 構成管理作業用Playbook
### apacheバージョン確認
#### 事前準備
* inventory/hostsの[target]グループに構築対象のhostsを記載する。

#### 実行コマンド

```
ansible-playbook check_apache_ver.yml -i inventory/hosts
```

### コア数チェック
#### 事前準備
* inventory/hostsの[target]グループに構築対象のhostsを記載する。

### 実行コマンド

```
ansible-playbook check_cores.yml -i inventory/hosts
```

### CPU情報確認
#### 事前準備
* inventory/hostsの[target]グループに構築対象のhostsを記載する。

### 実行コマンド

```
ansible-playbook check_cpu_spec.yml -i inventory/hosts
```

### Hadoopバージョン確認
#### 事前準備
* inventory/hostsの[target]グループに構築対象のhostsを記載する。

#### 実行コマンド

```
ansible-playbook check_hadoop_ver.yml -i inventory/hosts
```

### javaバージョン確認
#### 事前準備
* inventory/hostsの[target]グループに構築対象のhostsを記載する。

#### 実行コマンド

```
ansible-playbook check_java_ver.yml -i inventory/hosts
```

### 機器情報確認
#### 事前準備
* inventory/hostsの[target]グループに構築対象のhostsを記載する。

#### 実行コマンド

```
ansible-playbook check_machine_spec.yml -i inventory/hosts
```

### メモリ情報確認
#### 事前準備
* inventory/hostsの[target]グループに構築対象のhostsを記載する。

#### 実行コマンド

```
ansible-playbook check_memory_spec.yml -i inventory/hosts
```

### MySQLバージョン確認
#### 事前準備
* inventory/hostsの[target]グループに構築対象のhostsを記載する。

#### 実行コマンド

```
ansible-playbook check_mysql_ver.yml -i inventory/hosts
```

### nginxバージョン確認
#### 事前準備
* inventory/hostsの[target]グループに構築対象のhostsを記載する。

#### 実行コマンド

```
ansible-playbook check_nginx_ver.yml -i inventory/hosts
```

### OSバージョン確認
#### 事前準備
* hostsファイルの[target]グループに確認対象のホスト名を記載する。

#### 実行コマンド

```
ansible-playbook check_os_ver.yml -i <hosts_file> 
```

### rubyバージョン確認
#### 事前準備
* hostsファイルの[target]グループに確認対象のホスト名を記載する。

#### 実行コマンド

```
ansible-playbook check_ruby_ver.yml -i <hosts_file> 
```

### tomcatバージョン確認
#### 事前準備
* hostsファイルの[target]グループに確認対象のホスト名を記載する。

#### 実行コマンド

```
ansible-playbook check_tomcat_ver.yml -i <hosts_file> 
```

### 稼働時間確認
#### 事前準備
* hostsファイルの[target]グループに確認対象のホスト名を記載する。

#### 実行コマンド

```
ansible-playbook check_uptime.yml -i <hosts_file> 
```