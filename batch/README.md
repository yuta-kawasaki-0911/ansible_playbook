## toc
* [全体概要](#全体概要)
* [前提条件](#前提条件)
* [事前準備](#事前準備)
* [batch01構築手順](#batch01構築手順)
* [batch02構築手順](#batch02構築手順)
* [batch03構築手順](#batch03構築手順)
* [batch05構築手順](#batch05構築手順)
* [azkabanサーバの起動](#azkabanサーバの起動)
* [新規マウント手順](#新規マウント手順)
* [fstabファイルのバックアップについて](#fstabファイルのバックアップについて)

## 全体概要
* ディレクトリ構成とプログラム一覧
	* トップディレクトリ
		* `/home/ansible/batch`

```
.
├── README.md
├── build_batch01.yml
├── build_batch02.yml
├── build_batch03.yml
├── build_batch05.yml
├── check_status.yml
├── group_vars
│   ├── batch_01.yml
│   └── batch_03.yml
├── hosts
├── mount.yml
├── roles
│   ├── activemq
│   │   ├── files
│   │   │   ├── batch02
│   │   │   │   └── activemq.xml
│   │   │   └── batch05
│   │   │       └── activemq.xml
│   │   └── tasks
│   │       └── main.yml
│   ├── apache_tomcat
│   │   ├── files
│   │   │   ├── server.xml
│   │   │   └── sudoers_tomcat
│   │   └── tasks
│   │       └── main.yml
│   ├── azkaban
│   │   ├── files
│   │   │   ├── azkaban-executor-server-2.5.0.tar.gz
│   │   │   ├── azkaban-executor-shutdown.sh
│   │   │   ├── azkaban-executor-start.sh
│   │   │   ├── azkaban-jobtype-2.5.0-rc3.tar.gz
│   │   │   ├── azkaban-sql-script-2.5.0.tar.gz
│   │   │   ├── azkaban-web-server-2.5.0.tar.gz
│   │   │   ├── azkaban-web-shutdown.sh
│   │   │   ├── azkaban-web-start.sh
│   │   │   ├── azkaban.properties
│   │   │   ├── commonprivate.properties
│   │   │   ├── global.properties
│   │   │   └── mysql-connector-java-5.1.28.tar.gz
│   │   ├── tasks
│   │   │   └── main.yml
│   │   └── templates
│   │       └── azkaban.properties.j2
│   ├── batch01
│   │   ├── files
│   │   │   ├── sysctl_for_01_03.yml
│   │   │   ├── sysctl_for_02_05.yml
│   │   │   └── sysops
│   │   └── tasks
│   │       └── main.yml
│   ├── batch02
│   │   └── tasks
│   │       └── main.yml
│   ├── batch03
│   │   ├── files
│   │   │   ├── lp_marklist.sh
│   │   │   ├── ssh_cmd_main.sh
│   │   │   └── sysops
│   │   └── tasks
│   │       └── main.yml
│   ├── batch05
│   │   └── sysops
│   ├── mysql
│   │   ├── files
│   │   │   ├── create-all-sql-2.5.0_for_batch01.sql
│   │   │   └── my.cnf
│   │   ├── tasks
│   │   │   └── main.yml
│   │   └── templates
│   │       └── init_my.cnf.j2
│   ├── ruby
│   │   └── tasks
│   │       └── main.yml
│   └── sqoop
│       ├── files
│       │   └── mysql-connector-java-5.1.21.jar
│       └── tasks
│           └── main.yml
└── vars
    ├── mount_for_batch01.yml
    ├── mount_for_batch02.yml
    ├── mount_for_batch03.yml
    └── mount_for_batch05.yml
```

## 事前準備
* ansibleユーザーの作成
* ansibleユーザーにmanagementサーバーのSSH鍵の登録

## batch01構築手順
* はじめに
	* 処理順序
		* build_batch01.yml
			* `../common_build/roles/common`
			* `batch01`
			* `../common_build/roles/java`
			* `mysql`
			* `../common_build/roles/hadoop_client`
			* `sqoop`
			* `azkaban`
			* `ruby`
			* `../common_build/roles/mount`
		* ../operation/set_group_batch01.yml
		* ../operation/create_users.yml
			* `user`
* 注意事項
	* リプレースの場合、別のホスト名で本番稼働することがある為、hostsの最新化と配布を忘れないようにすること
	* `azkaban`の設定はバックエンドT側で実施する場合があるので、**事前の作業分担調整**を忘れないこと
* 処理概要
	* batch01サーバを構築する
* 事前確認事項
	* batchサーバ群のhostsを反映させる処理が必要
	* `/home/ansible/admatrixDSP_infra_configfiles/`内を最新の状態にpullしておく
	* 内部ネットワークのipとstatic-routesの設定を確認
* 実作業
	* hostsの[add]グループに対象ホストを記載
	* 以下のplaybookを実行

	```
	ansible-playbook build_batch01.yml -i hosts
	```

	* azkaban用ssl証明書を手動で作成

	```
	$ keytool -keystore keystore -alias jetty -genkey -keyalg RSA

	キーストアのパスワードを入力してください:
	新規パスワードを再入力してください:
	姓名を入力してください。
 	 [Unknown]:  admatrix.jp
	組織単位名を入力してください。
	  [Unknown]:  admatrix
	組織名を入力してください。
 	 [Unknown]:  fullspeed
	都市名または地域名を入力してください。
 	 [Unknown]:  tokyo
	都道府県名を入力してください。
	  [Unknown]:  tokyo
	この単位に該当する 2 文字の国番号を入力してください。
 	 [Unknown]:  JP
	CN=admatrix.jp, OU=admatrix, O=fullspeed, L=tokyo, ST=tokyo, C=JP でよろ
しいですか?
	  [no]:  y

	<jetty> の鍵パスワードを入力してください。

	$ keytool -certreq -alias jetty -keystore keystore -file jetty.csr

	```

* [azkabanサーバを起動する](#azkabanサーバの起動)

* 上記完了後にユーザ/sysopsグループの作成を行う。

```
cd /home/ansible/operation
inventories/hosts にユーザを作成したいホスト名を記載
ansible-playbook create_users.yml -i inventories/hosts
ansible-playbook set_group.yml -i inventories/hosts
```

## batch02構築手順
* hostsの[add]グループに対象ホストを記載
* 以下のplaybookを実行

```
ansible-playbook build_batch02.yml -i hosts

```

* 上記完了後にユーザ/sysopsグループの作成を行う。

```
cd /home/ansible/operation
inventories/hosts にユーザを作成したいホスト名を記載
ansible-playbook create_users.yml -i inventories/hosts
ansible-playbook set_group.yml -i inventories/hosts
```

## batch03構築手順
* hostsの[add]グループに対象ホストを記載
* 以下のplaybookを実行

```
ansible-playbook build_batch03.yml -i hosts
```

* batch01同様に鍵の設定を行う
* [azkabanサーバを起動する](#azkabanサーバの起動)

* 上記完了後にユーザ/sysopsグループの作成を行う。

```
cd /home/ansible/operation
inventories/hosts にユーザを作成したいホスト名を記載
ansible-playbook create_users.yml -i inventories/hosts
ansible-playbook set_group.yml -i inventories/hosts
```

## batch05構築手順
* hostsの[add]グループに対象ホストを記載
* 以下のplaybookを実行

```
ansible-playbook build_batch05.yml -i hosts
```

* 上記完了後にユーザ/sysopsグループの作成を行う。

```
cd /home/ansible/operation
inventories/hosts にユーザを作成したいホスト名を記載
ansible-playbook create_users.yml -i inventories/hosts
ansible-playbook set_group.yml -i inventories/hosts
```

## azkabanサーバの起動
* azkabanサーバを起動する
	* 実際に作業を行うのは**バックエンドTになるので、インフラ側で作業を行うことはない**と想定される

```
# web server
cd /usr/local/azkaban
./bin/azkaban-web-start.sh

# executor server
cd /usr/local/azkaban
./bin/azkaban-executor-start.sh
```

* 備考
	* 起動時にJobtypeに関するエラーが出た場合は、/usr/local/azkaban/plugins/jobtypes配下からエラーメッセージに該当するディレクトリを削除またはtarやzipなどで固める。
	* 例えば、`"Failed to get jobtype propertiesCould not find variable substitution for variable(s) [hive.aux.jar.path->hive.home]"`と出た場合は、hiveディレクトリが処理対象となる。

## 新規マウント手順
* group_vars/の対象hostsにマウント情報を追記する。
	* デバイスやマウントポイント、ファイルタイプなど
* mount.ymlの `hosts: `に対象hostsを記載する。
* mount.ymlの `vars: `に実行対象のmount情報の変数が参照されるように記載する。
* 以下のコマンドでplaybookを実行する。

```
ansible-playbook -i hosts mount.yml
```

## fstabファイルのバックアップについて
* `roles/mount/files/`に取得される。
* mount.yml実行時、mountモジュールが実行される前に上記の場所にバックアップが取られる仕様になっている。