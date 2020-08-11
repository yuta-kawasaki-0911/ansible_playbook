## toc
* [全体概要](#全体概要)
* [事前準備](#事前準備)
* [dapi構築Playbook設計思想](#dapi構築Playbook設計思想)
* [dapi構築手順](#dapi構築手順の使い方)
* [parted_disks.ymlの使い方](#parted_disks.ymlの使い方)
* [update_ssl_dapi.ymlの使い方](#update_ssl_dapi.ymlの使い方)
* [update_apache_config.ymlの使い方](#update_apache_config.ymlの使い方)
* [update_tomcat_config.ymlの使い方](#update_tomcat_config.ymlの使い方)

## 全体概要
* ディレクトリ構造とプログラム一覧
	* トップディレクトリ
		* `/home/ansible/dapi`

```
.
├── README.md
├── build.yml
├── build_centos7.yml
├── hosts
├── inventory
│   └── hosts
├── parted_disks.yml
├── roles
│   ├── apache_tomcat
│   │   ├── files
│   │   │   ├── cron
│   │   │   │   ├── apache_log_compress.sh
│   │   │   │   ├── backup.sh
│   │   │   │   ├── cups
│   │   │   │   ├── dapi_error_log_size_check.sh
│   │   │   │   ├── error_log_count.sh
│   │   │   │   ├── lsyncd_rotate.sh
│   │   │   │   ├── response_delay_check.sh
│   │   │   │   ├── tmpwatch
│   │   │   │   └── tomcat_log_compress.sh
│   │   │   ├── httpd-ssl.conf
│   │   │   ├── httpd.conf
│   │   │   ├── limits.conf
│   │   │   ├── logrotate.d
│   │   │   │   ├── cups
│   │   │   │   ├── dracut
│   │   │   │   ├── lsyncd
│   │   │   │   ├── syslog
│   │   │   │   ├── td-agent
│   │   │   │   └── yum
│   │   │   ├── lsyncd
│   │   │   ├── lsyncd_rotate.sh
│   │   │   ├── static-routes
│   │   │   └── sysctl.conf
│   │   ├── tasks
│   │   │   └── main.yml
│   │   └── templates
│   │       └── env.default.yml.j2
│   ├── common
│   │   ├── files
│   │   │   ├── centos6.7
│   │   │   │   ├── CentOS-Base.repo
│   │   │   │   └── CentOS-Vault.repo
│   │   │   ├── fullspeed.repo
│   │   │   └── sysctl.conf
│   │   └── tasks
│   │       └── main.yml
│   ├── dapi
│   │   ├── files
│   │   │   ├── mark.html
│   │   │   └── sysops
│   │   └── tasks
│   │       └── main.yml
│   ├── hadoop_client
│   │   ├── files
│   │   │   ├── core-site.xml
│   │   │   ├── hdfs-site.xml
│   │   │   ├── mapred-site.xml
│   │   │   ├── repos
│   │   │   │   ├── cloudera-cdh5.repo
│   │   │   │   └── cloudera-gplextras5.repo
│   │   │   └── slf4j-log4j12-1.6.1.jar
│   │   └── tasks
│   │       └── main.yml
│   ├── lsyncd
│   │   ├── files
│   │   │   ├── lsyncd
│   │   │   └── lsyncd_rotate.sh
│   │   └── tasks
│   │       └── main.yml
│   ├── parted_disks
│   │   └── tasks
│   │       ├── main.yml
│   │       └── main.yml.bk
│   ├── ssl
│   │   ├── files
│   │   │   ├── JPRS_DVCA.cer.20180323
│   │   │   ├── bidding-dsp.ad-m.asia.cer.20180323
│   │   │   ├── bidding-dsp.ad-m.asia.key.20180323
│   │   │   ├── data-dsp.ad-m.asia.cer.20180323
│   │   │   ├── data-dsp.ad-m.asia.key.20180323
│   │   │   ├── optout-dsp.ad-m.asia.cer.20180323
│   │   │   └── optout-dsp.ad-m.asia.key.20180323
│   │   └── tasks
│   │       └── main.yml
│   ├── ssl_bidding-dsp.ad-m.asia
│   │   ├── files
│   │   │   ├── JPRS_DVCA_G2_PEM.cer.to20200331
│   │   │   ├── JPRS_DVCA_G3_PEM.cer.to20210331
│   │   │   ├── bidding-dsp.ad-m.asia.cer.to20200331
│   │   │   ├── bidding-dsp.ad-m.asia.cer.to20210331
│   │   │   ├── bidding-dsp.ad-m.asia.key.to20200331
│   │   │   └── bidding-dsp.ad-m.asia.key.to20210331
│   │   └── tasks
│   │       └── main.yml
│   ├── ssl_bidding-dsp.t-ad-m.asia
│   │   ├── files
│   │   │   ├── bidding-dsp.t-ad-m.asia.cer.to20210228
│   │   │   ├── bidding-dsp.t-ad-m.asia.crt.to20210228
│   │   │   └── bidding-dsp.t-ad-m.asia.key.to20210228
│   │   └── tasks
│   │       └── main.yml
│   ├── ssl_data-dsp.ad-m.asia
│   │   ├── files
│   │   │   ├── JPRS_DVCA_G2_PEM.cer.to20200331
│   │   │   ├── JPRS_DVCA_G3_PEM.cer.to20210331
│   │   │   ├── data-dsp.ad-m.asia.cer.to20200331
│   │   │   ├── data-dsp.ad-m.asia.cer.to20210331
│   │   │   ├── data-dsp.ad-m.asia.key.to20200331
│   │   │   └── data-dsp.ad-m.asia.key.to20210331
│   │   └── tasks
│   │       └── main.yml
│   ├── ssl_data-dsp.t-ad-m.asia
│   │   ├── files
│   │   │   ├── data-dsp.t-ad-m.asia.cer.to20210228
│   │   │   ├── data-dsp.t-ad-m.asia.crt.to20210228
│   │   │   └── data-dsp.t-ad-m.asia.key.to20210228
│   │   └── tasks
│   │       └── main.yml
│   ├── ssl_optout-dsp.ad-m.asia
│   │   ├── files
│   │   │   ├── JPRS_DVCA_G2_PEM.cer.to20200331
│   │   │   ├── JPRS_DVCA_G3_PEM.cer.to20210331
│   │   │   ├── optout-dsp.ad-m.asia.cer.to20200331
│   │   │   ├── optout-dsp.ad-m.asia.cer.to20210331
│   │   │   ├── optout-dsp.ad-m.asia.key.to20200331
│   │   │   └── optout-dsp.ad-m.asia.key.to20210331
│   │   └── tasks
│   │       └── main.yml
│   └── ssl_optout-dsp.t-ad-m.asia
│       ├── files
│       │   ├── optout-dsp.t-ad-m.asia.cer.to20210228
│       │   ├── optout-dsp.t-ad-m.asia.crt.to20210228
│       │   └── optout-dsp.t-ad-m.asia.key.to20210228
│       └── tasks
│           └── main.yml
├── update_apache_config.yml
├── update_ssl_bidding-dsp.ad-m.asia.yml
├── update_ssl_bidding-dsp.t-ad-m.asia.yml
├── update_ssl_dapi.yml
├── update_ssl_data-dsp.ad-m.asia.yml
├── update_ssl_data-dsp.t-ad-m.asia.yml
├── update_ssl_optout-dsp.ad-m.asia.yml
├── update_ssl_optout-dsp.t-ad-m.asia.yml
├── update_ssl_staging.yml
├── update_tomcat_config.yml
└── vars
    ├── apache_config.yml
    ├── mount.yml
    ├── ssl_bidding-dsp.ad-m.asia.yml
    ├── ssl_bidding-dsp.t-ad-m.asia.yml
    ├── ssl_data-dsp.ad-m.asia.yml
    ├── ssl_data-dsp.t-ad-m.asia.yml
    ├── ssl_optout-dsp.ad-m.asia.yml
    ├── ssl_optout-dsp.t-ad-m.asia.yml
    ├── tomcat_config.yml
    ├── update_JPRS_DVCA_ssl.yml
    ├── update_bidding-dsp_ssl.yml
    ├── update_data-dsp_ssl.yml
    └── update_optout-dsp_ssl.yml
```

## 事前準備
* ansibleユーザーの作成
* ansibleユーザーにmanagementサーバーのSSH鍵の登録
* /home/ansible/dapi/roles/ssl_xxx/filesに必要な証明書と鍵の格納
	* dapiはapacheなのでssl証明書のみで問題なし
	* ファイル名は証明書名＋to以降に証明書の有効期限をYYYYMMDDで設定 （例）bidding-dsp.ad-m.asia.cer.to20180323

## dapi構築Playbook設計思想
### 構築要素
* `OS`
	* 基本設定
	* マウント
* `MW`
	* apache
	* tomcat
	* java
	* lsyncd
	* hadoop client
	* ruby
* `その他`
	* ssl_bidding-dsp.ad-m.asia
	* ssl_data-dsp.ad-m.asia
	* ssl_optout-dsp.ad-m.asia
	* ユーザ設定
	* グループ設定

### 構築順序
* 基本設定はADMATRIX DSP環境のベース設定となる為、初めに設定を行う。
* SSL証明書の設定はapache / tomcatの設定が完了したのちに行う。

## dapi構築手順
* はじめに
	* 処理順序（CentOS6の場合）
		* build.yml
			* `../common_build/roles/common`
			* `../common_build/roles/java`
			* `apache-tomcat`
			* `../common_build/roles/mount`
			* `dapi`
			* `lsyncd`
			* `hadoop_client`
			*  `ssl_bidding-dsp.ad-m.asia`
			*  `ssl_data-dsp.ad-m.asia`
			*  `ssl_optout-dsp.ad-m.asia`
		* ../operation/create_users.yml
			* `user`
		* ../operation/set_group.yml
	* 処理順序（CentOS7の場合）
		* build_centos7.yml
			* `../common_build/roles/common_centos7`
			* `../common_build/roles/java`
			* `apache-tomcat`
			* `../common_build/roles/mount_centos7`
			* `dapi`
			* `lsyncd`
			* `hadoop_client_centos7`
			*  `ssl_bidding-dsp.ad-m.asia`
			*  `ssl_data-dsp.ad-m.asia`
			*  `ssl_optout-dsp.ad-m.asia`
		* ../operation/create_users.yml
			* `user`
		* ../operation/set_group.yml
* 注意事項
	* update_ssl.ymlは稼働中のサーバを想定して実装している
	* 新規構築の場合、lvsへの組み込みはアプリの設定完了後となるので、外した状態（health.htmlを未作成 or リネーム）にしておく
		* **ここをどちらにすべきか？は開発側と確認して、決定すること**
	* カーネルパラメータの設定において、lNICの名称は`em2`を想定して定義されている
		* `roles/dapi/tasks/main.yml`に該当の処理がある
		* もし環境が異なる場合はplaybookを一時的に修正して実行する
		* **Dell PowerEdge R630をベースにした設定**となっている
			* もし、機種が異なる場合はパラメータ設定に注意が必要
* 処理概要
	* dapiサーバを構築する
* 事前確認事項
	* dapiサーバ群のhostsを反映させる処理が必要
	* `/home/ansible/admatrixDSP_infra_configfiles/`内を最新の状態にpullしておく
	* 内部ネットワークのipとstatic-routesの設定を確認する
	* `dapi/inventory/hosts`の[add]に構築対象のホスト名を記載する
	* `operation/inventories/hosts`の[target]に構築対象のホスト名を記載する
* 実作業
	* 以下のplaybookを実行

		```
		cd dapi
		
		■CentOS6の場合
		ansible-playbook build.yml -i inventory/hosts

		■CentOS7の場合
		ansible-playbook build_centos7.yml -i inventory/hosts
		```

		```
		以下で出力された公開鍵の中身を以下ににペースト
		tomcat@dadmin01:~/.ssh/authorized_keys
		tomcat@dbatch02:~/.ssh/authorized_keys

		TASK [apache_tomcat : 以下をdadmin01/dbatch02の/home/tomcat/.ssh/authorized_keysにコピーする] 	************************************
		ok: [dapi27] => {
   		"id_rsa_pub.stdout": "[[公開鍵の中身]]"
		}
		```

	* 以下のplaybookを実行
		* linuxユーザーの登録を行う。

		```
		cd ../operation
		ansible-playbook create_users.yml -i inventories/hosts
		```
		
		* sysopsグループを設定する。

		```
		ansible-playbook set_group.yml -i inventories/hosts
		```

## parted_disks.ymlの使い方
* はじめに
	* 処理の順序
		* `parted_disks.yml` → `roles/parted_disks/tasks/main.yml`
			* `parted_disks.yml`を実行すると、その中で`main.yml`が呼び出される
* 注意事項
	* `/home/ansible/dapi`に移動してからplaybookを実行すること
* 処理概要
	* dapiサーバのディスクパーティションを構築する
* 事前確認事項
	* inventory/hostsの[add]グループに構築対象のhostsを追記
* 実作業
	* 以下のコマンドで実行

    ```
    ansible-playbook parted_disks.yml -i inventory/hosts
    ```

## update_ssl_dapi.ymlの使い方
* はじめに
	* 処理概要
        1. 対象のサーバーをlvsから外す
        2. （手動で）lvs03 / lvs04で対象のサーバがlvsから外れたかを確認する
        3. 新しい証明書を更新し、正しく更新されているかを確認する
        4. apacheを再起動し、lvsへ組み込む
        5. （手動で）lvs03 / lvs04で対象のサーバがlvsへ組み込まれたことを確認する 
	* プログラムの関連性
		* update_ssl.yml
			* `ssl_bidding-dsp.ad-m.asia`
			* `ssl_data-dsp.ad-m.asia`
			* `ssl_optout-dsp.ad-m.asia`
* 注意事項
	* **表示が失敗したらエンドユーザーに影響が出てしまうサーバなので特に注意して行う事。**
    * **1部更新したら新しい証明書がきちんと更新されているかを確認してから全台行う。また全台の更新は月末月初は避ける**
    * `/home/ansible/dapi`に移動してからplaybookを実行すること
* 処理概要
	* 以下のドメインのSSL証明書を更新する
		* bidding-dsp.ad-m.asia
		* data-dsp.ad-m.asia
		* optout-dsp.ad-m.asia
* 事前確認事項
	* `inventory/hosts`の[target]グループ内に構築対象のhostsを追記
	* 事前に鍵を解除しておく
		* `openssl sha1 xxx.key`を実行して、値が表示されるか確認する
	* 証明書ファイルを配置
	* `dapi/roles/ssl/files/` に配置。その際ファイル名の末尾に現在の日時を追加しておくこと。
	* vars/ssl_***.ymlに更新するssl証明書のファイル名を記載

	```
	（例）
	update_bidding_crt: bidding-dsp.ad-m.asia.cer.to20200331
	update_bidding_key: bidding-dsp.ad-m.asia.key.to20200331
	domain_ca_crt: JPRS_DVCA_G2_PEM.cer.to20200331
	bidding_crt_path: /usr/local/apache2/conf/bidding-dsp.ad-m.asia/bidding-dsp.ad-m.asia.csr
	bidding_key_path: /usr/local/apache2/conf/bidding-dsp.ad-m.asia/bidding-dsp.ad-m.asia.key
	domain_ca_bidding_path: /usr/local/apache2/conf/bidding-dsp.ad-m.asia/JPRS_DVCA.cer
	```

	* インベントリファイル(dapi/inventory/hosts)の `[target]` の中に実行対象のホストを追記
	* dapiは本番稼働しているので、サービスに影響が出ないように1台ずつ実行する。

	```
	[target]
	dapi01
	```

* 実作業
	* dsp_infraチャンネルにSSL証明書更新作業を広報する

    ```
    @here
    【作業広報】dapi01-33のSSL証明書更新（bidding-dsp.ad-m.asia data-dsp.ad-m.asia optout-dsp.ad-m.asia）
    以下の日時で表題の作業を行いますので、ご認識ください。

    日時 ： MM/DD（x）hh:mm - hh:mm
    対象 ： dapi01-33のSSL証明書（bidding-dsp.ad-m.asia data-dsp.ad-m.asia optout-dsp.ad-m.asia）
    ```

	* 以下のコマンドでplaybookを実行する

	```
	サービス稼働中のため一つずつ行う。
	#lvsへ外す
	ansible-playbook -i inventory/hosts update_ssl_dapi.yml --tags remove

	#無事外されたのが確認できたら、新しい証明書一式をコピー
	ansible-playbook -i inventory/hosts update_ssl_dapi.yml --tags setting

	#証明書の確認ができたら、以下のコマンドでapacheの再起動。無事再起動した時lvsに戻すようになっている
	ansible-playbook -i inventory/hosts update_ssl_dapi.yml --tags add
	```

	* インベントリファイルの対象ホストを次のサーバに変えて、再度playbookを実行していく。全台実行する。

	* 作業が完了したら、dsp_infraチャンネルに完了広報を行う。

    ```
    【作業完了広報】dapi01-33のSSL証明書更新（bidding-dsp.ad-m.asia data-dsp.ad-m.asia optout-dsp.ad-m.asia）
    以下の作業が完了しましたので、ご連絡します。

    https://fullspeed.slack.com/archives/C1PFEEAGY/p1536026499000100
    ```

## update_ssl_staging.ymlの使い方
* はじめに
	* 処理概要
        1. 新しい証明書を更新し、正しく更新されているかを確認する
        2. apacheを再起動する
	* プログラムの関連性
		* update_ssl_staging.yml
			* `ssl_bidding-dsp.t-ad-m.asia`
			* `ssl_data-dsp.t-ad-m.asia`
			* `ssl_optout-dsp.t-ad-m.asia`
* 注意事項
    * `/home/ansible/dapi`に移動してからplaybookを実行すること
* 処理概要
	* 以下のドメインのSSL証明書を更新する
		* bidding-dsp.t-ad-m.asia
		* data-dsp.t-ad-m.asia
		* optout-dsp.t-ad-m.asia
* 事前確認事項
	* `inventory/hosts`の[target]グループ内に構築対象のhostsを追記
	* 事前に鍵を解除しておく
		* `openssl sha1 xxx.key`を実行して、値が表示されるか確認する
	* 証明書ファイルを配置
	* `dapi/roles/ssl/files/` に配置。その際ファイル名の末尾に現在の日時を追加しておくこと。
	* vars/ssl_***.t-ad-m.asia.ymlに更新するssl証明書のファイル名を記載
	* 	* `dapi/inventory/hosts`の[target]に構築対象のホスト名を記載する

	```
	（例）
	update_bidding_crt: bidding-dsp.t-ad-m.asia.crt.to20210228
	update_bidding_key: bidding-dsp.t-ad-m.asia.key.to20210228
	update_bidding_cer: bidding-dsp.t-ad-m.asia.cer.to20210228
	bidding_crt_path: /usr/local/apache2/conf/ssl/bidding-dsp.t-ad-m.asia.crt
	bidding_key_path: /usr/local/apache2/conf/ssl/bidding-dsp.t-ad-m.asia.key
	bidding_cer_path: /usr/local/apache2/conf/ssl/bidding-dsp.t-ad-m.asia.cer
	```

	* インベントリファイル(dapi/inventory/hosts)の `[target]` の中に実行対象のホストを追記
	* dapiは本番稼働しているので、サービスに影響が出ないように1台ずつ実行する。

	```
	[target]
	sdapi04
	```

* 実作業
	* dsp_infraチャンネルにSSL証明書更新作業を広報する

    ```
    @here
    【作業広報】sdapi04のSSL証明書更新（bidding-dsp.t-ad-m.asia data-dsp.t-ad-m.asia optout-dsp.t-ad-m.asia）
    以下の日時で表題の作業を行いますので、ご認識ください。

    日時 ： MM/DD（x）hh:mm - hh:mm
    対象 ： sdapi04のSSL証明書（bidding-dsp.t-ad-m.asia data-dsp.t-ad-m.asia optout-dsp.t-ad-m.asia）
    ```

	* 以下のコマンドでplaybookを実行する

	```
	#新しい証明書一式をコピー
	ansible-playbook -i inventory/hosts update_ssl_staging.yml --tags setting

	#証明書の確認ができたら、以下のコマンドでapacheの再起動。
	ansible-playbook -i inventory/hosts update_ssl_staging.yml --tags add
	```

	* インベントリファイルの対象ホストを次のサーバに変えて、再度playbookを実行していく。全台実行する。

	* 作業が完了したら、dsp_infraチャンネルに完了広報を行う。

    ```
    【作業完了広報】sdapi04のSSL証明書更新（bidding-dsp.t-ad-m.asia data-dsp.t-ad-m.asia optout-dsp.t-ad-m.asia）
    以下の作業が完了しましたので、ご連絡します。

    https://fullspeed.slack.com/archives/C1PFEEAGY/p1536026499000100
    ```


## update_ssl_xxx.ymlの使い方
* はじめに
	* 前提事項
		* `update_ssl.yml`は3種類全部を同時に更新する目的で作成。
		* `update_ssl_xxx.yml`は1種類ずつ更新する目的で作成している。
	* 処理概要
		1. 【本番環境のみ】対象のサーバーをlvsから外す
        2. 【本番環境のみ】（手動で）lvs05 / lvs06で対象のサーバがlvsから外れたかを確認する
        3. 新しい証明書を更新し、正しく更新されているかを確認する
        4. apacheを再起動し、【本番環境のみ】lvsへ組み込む
        5. 【本番環境のみ】（手動で）lvs05 / lvs06で対象のサーバがlvsへ組み込まれたことを確認する
	* プログラムの関連
		* update_ssl.yml
			* `ssl_xxx`
		* update_ssl_staging.yml
			* `ssl_xxx`
* 注意事項
	* **【本番環境のみ】表示が失敗したらエンドユーザーに影響が出てしまうサーバなので特に注意して行う事。**
    * **【本番環境のみ】1部更新したら新しい証明書がきちんと更新されているかを確認してから全台行う。また全台の更新は月末月初は避ける**
    * `/home/ansible/dapi`に移動してからplaybookを実行すること
* 処理概要
	* 以下のドメインのSSL証明書を更新する
		* 本番環境
			* bidding-dsp.ad-m.asia
			* data-dsp.ad-m.asia
			* optout-dsp.ad-m.asia
		* ステージング環境
			* bidding-dsp.t-ad-m.asia
			* data-dsp.t-ad-m.asia
			* optout-dsp.t-ad-m.asia
* 事前確認事項
	* `inventory/hosts`の[target]グループ内に構築対象のhostsを追記
	* 事前に鍵を解除しておく
		* `openssl sha1 xxx.key`を実行して、値が表示されるか確認する
	* 証明書ファイルを配置
	* `dapi/roles/ssl/files/` に配置。その際ファイル名の末尾に現在の日時を追加しておくこと。
	* vars/ssl_***.ymlに更新するssl証明書のファイル名を記載

	```
	（例）
	update_bidding_crt: bidding-dsp.ad-m.asia.cer.to20200331
	update_bidding_key: bidding-dsp.ad-m.asia.key.to20200331
	domain_ca_crt: JPRS_DVCA_G2_PEM.cer.to20200331
	bidding_crt_path: /usr/local/apache2/conf/bidding-dsp.ad-m.asia/bidding-dsp.ad-m.asia.csr
	bidding_key_path: /usr/local/apache2/conf/bidding-dsp.ad-m.asia/bidding-dsp.ad-m.asia.key
	domain_ca_bidding_path: /usr/local/apache2/conf/bidding-dsp.ad-m.asia/JPRS_DVCA.cer
	```

	* インベントリファイル(dapi/inventory/hosts)の `[target]` の中に実行対象のホストを追記
	* dapiは本番稼働しているので、サービスに影響が出ないように1台ずつ実行する。

	```
	[target]
	dapi01
	```

* 実作業
	* dsp_infraチャンネルにSSL証明書更新作業を広報する

    ```
    @here
    【作業広報】dapi01-33のSSL証明書更新（xxx）
    以下の日時で表題の作業を行いますので、ご認識ください。

    日時 ： MM/DD（x）hh:mm - hh:mm
    対象 ： dapi01-33のSSL証明書（xxx）
    ```

	* 以下のコマンドでplaybookを実行する

	```
	【本番環境のみ】サービス稼働中のため一つずつ行う。
	#lvsへ外す
	ansible-playbook -i inventory/hosts update_ssl_xxx.yml --tags remove

	#無事外されたのが確認できたら、新しい証明書一式をコピー
	ansible-playbook -i inventory/hosts update_ssl_xxx.yml --tags setting

	#証明書の確認ができたら、以下のコマンドでapacheの再起動。【本番環境のみ】無事再起動した時lvsに戻すようになっている
	ansible-playbook -i inventory/hosts update_ssl_xxx.yml --tags add
	```

	* インベントリファイルの対象ホストを次のサーバに変えて、再度playbookを実行していく。全台実行する。

	* 作業が完了したら、dsp_infraチャンネルに完了広報を行う。

    ```
    【作業完了広報】dapi01-33のSSL証明書更新（xxx）
    以下の作業が完了しましたので、ご連絡します。

    https://fullspeed.slack.com/archives/C1PFEEAGY/p1536026499000100
    ```

## update_apache_config.ymlの使い方
* はじめに
	* 前提事項
		* `update_apache_config.yml`はapacheの設定ファイル（httpd.conf / httpd-ssl.conf）を構成管理領域から配布する目的で作成。
		* 新規構築ではなく、**運用中のサーバに対する処理を実装**。
	* 処理概要
		1. 【本番環境のみ】対象のサーバーをlvsから外す
		2. 【本番環境のみ】（手動で）lvs05 / lvs06で対象のサーバがlvsから外れたかを確認する
		3. 新しい設定ファイルを配布し、正しく配布されているかを確認する
		4. apacheを再起動し、【本番環境のみ】lvsへ組み込む
		5. 【本番環境のみ】（手動で）lvs05 / lvs06で対象のサーバがlvsへ組み込まれたことを確認する
* 注意事項
	* **【本番環境のみ】更新が失敗したらサービスが停止してしまう為、特に注意して行う事。**
    * **【本番環境のみ】1サーバ作業したら正しく起動するかの確認してから全台行う。また全台の更新は月末月初は避ける**
    * `/home/ansible/dapi`に移動してからplaybookを実行すること
* 処理概要
	* 以下のファイルを更新する。
		* `/usr/local/apache2/conf/httpd.conf`
		* `/usr/local/apache2/conf/extra/httpd-ssl.conf`
* 事前確認事項
	* `inventory/hosts`の[target]グループ内に構築対象のhostsを追記
	* 構成管理領域のファイルを最新化する。
		* `https://github.com/FullSpeedInc/admatrix_devops/blob/master/dapi/roles/apache_tomcat/files/httpd.conf`
		* `https://github.com/FullSpeedInc/admatrix_devops/blob/master/dapi/roles/apache_tomcat/files/httpd-ssl.conf`
	* インベントリファイル(dapi/inventory/hosts)の `[target]` の中に実行対象のホストを追記
	* dapiは本番稼働しているので、サービスに影響が出ないように1台ずつ実行する。

	```
	[target]
	dapi01
	```

* 実作業
	* dsp_infraチャンネルにSSL証明書更新作業を広報する

    ```
    @here
    【作業広報】dapi01-33のapache定義ファイル更新
    以下の日時で表題の作業を行いますので、ご認識ください。

    日時 ： MM/DD（x）hh:mm - hh:mm
    対象 ： dapi01-33のapache定義ファイル（httpd.conf / httpd-ssl.conf）
    ```

	* 以下のコマンドでplaybookを実行する

	```
	【本番環境のみ】サービス稼働中のため一つずつ行う。
	#lvsへ外す
	ansible-playbook -i inventory/hosts update_apache_config.yml --tags remove

	#無事外されたのが確認できたら、新しい設定ファイルをコピー
	ansible-playbook -i inventory/hosts update_apache_config.yml --tags setting

	#定義ファイルの確認ができたら、以下のコマンドでapacheの再起動。【本番環境のみ】無事再起動した時lvsに戻すようになっている
	ansible-playbook -i inventory/hosts update_apache_config.yml --tags add
	```

	* インベントリファイルの対象ホストを次のサーバに変えて、再度playbookを実行していく。全台実行する。

	* 作業が完了したら、dsp_infraチャンネルに完了広報を行う。

    ```
    【作業完了広報】dapi01-33のapache定義ファイル更新
    以下の作業が完了しましたので、ご連絡します。

    https://fullspeed.slack.com/archives/C1PFEEAGY/p1536026499000100
    ```

## update_tomcat_config.ymlの使い方
* はじめに
	* 前提事項
		* `update_tomcat_config.yml`はapacheの設定ファイル（server.xml）を構成管理領域から配布する目的で作成。
		* 新規構築ではなく、**運用中のサーバに対する処理を実装**。
	* 処理概要
		1. 【本番環境のみ】対象のサーバーをlvsから外す
		2. 【本番環境のみ】（手動で）lvs05 / lvs06で対象のサーバがlvsから外れたかを確認する
		3. 新しい設定ファイルを配布し、正しく配布されているかを確認する
		4. apacheを再起動し、【本番環境のみ】lvsへ組み込む
		5. 【本番環境のみ】（手動で）lvs05 / lvs06で対象のサーバがlvsへ組み込まれたことを確認する
* 注意事項
	* **【本番環境のみ】更新が失敗したらサービスが停止してしまう為、特に注意して行う事。**
    * **【本番環境のみ】1サーバ作業したら正しく起動するかの確認してから全台行う。また全台の更新は月末月初は避ける**
    * `/home/ansible/dapi`に移動してからplaybookを実行すること
* 処理概要
	* 以下のファイルを更新する。
		* `/usr/local/tomcat/conf/server.xml`
* 事前確認事項
	* `inventory/hosts`の[target]グループ内に構築対象のhostsを追記
	* 構成管理領域のファイルを最新化する。
		* `https://github.com/FullSpeedInc/admatrix_devops/blob/master/dapi/roles/apache_tomcat/files/server.xml`
	* インベントリファイル(dapi/inventory/hosts)の `[target]` の中に実行対象のホストを追記
	* dapiは本番稼働しているので、サービスに影響が出ないように1台ずつ実行する。

	```
	[target]
	dapi01
	```

* 実作業
	* dsp_infraチャンネルにSSL証明書更新作業を広報する

    ```
    @here
    【作業広報】dapi01-33のtomcat定義ファイル更新
    以下の日時で表題の作業を行いますので、ご認識ください。

    日時 ： MM/DD（x）hh:mm - hh:mm
    対象 ： dapi01-33のtomcat定義ファイル（httpd.conf / httpd-ssl.conf）
    ```

	* 以下のコマンドでplaybookを実行する

	```
	【本番環境のみ】サービス稼働中のため一つずつ行う。
	#lvsへ外す
	ansible-playbook -i inventory/hosts update_tomcat_config.yml --tags remove

	#無事外されたのが確認できたら、新しい設定ファイルをコピー
	ansible-playbook -i inventory/hosts update_tomcat_config.yml --tags setting

	#定義ファイルの確認ができたら、手動でtomcatを再起動し、サービスへ戻す
	https://github.com/FullSpeedInc/admatrix_docs_java_backend/blob/master/manuals/server_start_up/dapi/README.md
	```

	* インベントリファイルの対象ホストを次のサーバに変えて、再度playbookを実行していく。全台実行する。

	* 作業が完了したら、dsp_infraチャンネルに完了広報を行う。

    ```
    【作業完了広報】dapi01-33のtomcat定義ファイル更新
    以下の作業が完了しましたので、ご連絡します。

    https://fullspeed.slack.com/archives/C1PFEEAGY/p1536026499000100
    ```