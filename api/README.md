## toc
* [全体概要](#全体概要)
* [前提条件](#前提条件)
* [事前準備](#事前準備)
* [api構築Playbook設計思想](#api構築Playbook設計思想)
* [build.ymlの使い方](#build.ymlの使い方)
* [parted_disks.ymlの使い方](#parted_disks.ymlの使い方)
* [update_ssl_XXX.ymlの使い方](#update_ssl_XXX.ymlの使い方)
* [update_ssl_t-admatrix.jp.ymlの使い方](#update_ssl_t-admatrix.jp.ymlの使い方)

## 全体概要
* ディレクトリ構造とプログラム一覧
	* トップディレクトリ
		* `/home/ansible/api`

```
.
├── README.md
├── build.yml
├── build_centos7.yml
├── inventory
│   ├── hosts
│   └── stg_hosts
├── parted_disks.yml
├── roles
│   ├── api
│   │   ├── files
│   │   │   ├── apache-tomcat-8.0.26.tar.gz
│   │   │   ├── api01_limits.conf
│   │   │   ├── beacon.gif
│   │   │   ├── cron
│   │   │   │   ├── cups
│   │   │   │   ├── logrotate
│   │   │   │   ├── makewhatis.cron
│   │   │   │   ├── tmpwatch
│   │   │   │   └── trdads_backup_logs
│   │   │   ├── limits.conf
│   │   │   ├── logrote_nginx
│   │   │   ├── lsyncd_logrote
│   │   │   ├── ruby-2.0.0-p353.tar.gz
│   │   │   ├── server.xml
│   │   │   ├── setenv.sh
│   │   │   ├── sysctl.conf
│   │   │   └── temp
│   │   │       ├── backupLogsToRemoteServer.sh
│   │   │       └── garbage
│   │   │           ├── README.md
│   │   │           ├── old
│   │   │           │   ├── backupLogsToRemoteServer.sh
│   │   │           │   ├── backupLogsToRemoteServer.sh.20131016
│   │   │           │   ├── setBackupVariables.sh
│   │   │           │   └── setBackupVariables.sh.20131016
│   │   │           ├── script.tar
│   │   │           └── setBackupVariables.sh
│   │   ├── tasks
│   │   │   └── main.yml
│   │   └── templates
│   │       ├── lsyncd.conf.j2
│   │       └── rc.local.j2
│   ├── parted_disks
│   │   └── tasks
│   │       ├── main.yml
│   │       └── main.yml.bk
│   └── ssl_t-admatrix.jp
│       ├── files
│       │   ├── cn_t-admatrix.jp.crt.to20191118
│       │   ├── t-admatrix.jp.cer
│       │   ├── t-admatrix.jp.crt
│       │   └── t-admatrix.jp.nopass.key
│       └── tasks
│           └── main.yml
├── update_ssl_admatrix.jp.yml
├── update_ssl_t-admatrix.jp.yml
└── vars
    ├── mount.yml
    ├── nginx.yml
    └── ssl_t-admatrix.jp.yml
```

## 事前準備
- ansibleユーザーの作成
- ansibleユーザーにmanagementサーバーのSSH鍵の登録
- `/home/ansible/common_build/roles/nginx/files`に必要な証明書と鍵の格納
	- 対象はadmatrix.jp
	- apiはnginxなので、ssl証明書の下に中間証明書の中身を貼り付けて結合する
	- ファイル名は証明書名＋`to`以降に証明書の有効期限を`YYYYMMDD`で設定
      （例）`admatrix.jp.crt.to20191013`

## api構築Playbook設計思想
### 構築要素
* `OS`
	* 基本設定
	* マウント
* `MW`
	* nginx
	* tomcat
	* java
	* lsyncd
	* hadoop client
	* ruby
* `その他`
	* ssl_bidding-dsp.ad-m.asia
	* ssl_data-dsp.ad-m.asia
	* ssl_optout-dsp.ad-m.asia

### 構築順序
* 基本設定はADMATRIX DSP環境のベース設定となる為、初めに設定を行う。
* SSL証明書の設定はnginx / tomcatの設定が完了したのちに行う。
	* nginxの設定中に起動する処理があるが、SSL証明書未配置の為、エラーとなる
	* 改修するかどうかは今後検討する

## build.yml / build_centos7.ymlの使い方
* はじめに
	* 処理順序
		* CentOS6の場合、`build.yml`から以下の順番で`roles`を呼び出す
			* `../common_build/roles/common`
			* `./common_build/roles/java`
			* `../common_build/roles/tomcat`
			* `../common_build/roles/ruby`
			* `api`
			* `../common_build/roles/nginx`
			* `../common_build/roles/mount`
			* `../common_build/roles/hadoop_client`
		* CentOS7の場合、`build_centos7.yml`から以下の順番で`roles`を呼び出す
			* `../common_build/roles/common_centos7`
			* `./common_build/roles/java`
			* `../common_build/roles/tomcat`
			* `../common_build/roles/ruby`
			* `api`
			* `../common_build/roles/nginx_centos7`
			* `../common_build/roles/mount_centos7`
			* `../common_build/roles/hadoop_client_centos7`
* 注意事項
	* `../common_build/roles/ruby`は正しく動作しない場所あり
		* 現時点では、`../common_build/roles/hadoop_client`で導入されるrubyを利用する為、スキップしても良い
	* `/home/ansible/api`に移動してからplaybookを実行すること
* 処理概要
	* apiサーバを構築する
* 事前確認事項
	* `inventory/hosts`の [add]グループ内に構築対象のhostsを追記
* 実作業
	1. build.yml / build_centos7.ymlの `hosts:`を対象のhostsグループを指定
	2. build.yml / build_centos7.ymlの `vars:`で定義されている変数に関して、該当のものを設定
		* gb_interface: em2  # global ipを設定しているインターフェース名
		* ssl_cer: admatrix.jp.crt.to20201112  # 有効なssl証明書のファイル名
		* ssl_key: admatrix.jp.key.to20201112  # 有効なssl証明書の鍵ファイル名 
	3. playbookを実行（dry-run）
	     
	   ```
	   ■CentOS6の場合
      ansible-playbook build.yml -i inventory/hosts --check

	   ■CentOS7の場合
      ansible-playbook build_centos7.yml -i inventory/hosts --check
      ```
      
	4. playbookを実行
	
	   ```
	   ■CentOS6の場合
      ansible-playbook build.yml -i inventory/hosts

	   ■CentOS7の場合
      ansible-playbook build_centos7.yml -i inventory/hosts
      ```
      
	5. hadoop-clientのインストールは以下を参照し、作業する
      `https://redmine.fs-site.net/projects/dsp_tps/wiki/Servingacq_API_ver2`
      → `4.Hadoop のクライアント設定`の動作確認方法
	6. `/home/ansible/operation/inventories/hosts`に対象ホストを記入し、以下のplaybookを実行する
      `/home/ansible/operation/create_user.yml`
      `/home/ansible/operation/set_group.yml` 
	7. 構築対象のサーバの内部ネットワークを設定する
		* `/etc/sysconfig/network-scripts/ifcfg-em1`に以下の設定を追加
			* 内部IPアドレス（172.17.xxx.xxx）
			* ONBOOT=yes
			* BOOTPROTO=none
		* 疎通確認として、api0Xからpingが通ることを確認

## parted_disks.ymlの使い方
* はじめに
	* 処理順序
		* `parted_disks.yml` → `roles/parted_disks/tasks/main.yml`
            * `parted_disks.yml`を実行すると、その中で`main.yml`が呼び出される
* 注意事項
	* `/home/ansible/api`に移動してからplaybookを実行すること
* 処理概要
	* apiサーバのディスクパーティションを構築する
* 事前確認事項
	* inventory/hostsの[add]グループに構築対象のhostsを追記
* 実作業
	* 以下のコマンドで実行

    ```
    ansible-playbook parted_disks.yml -i inventory/hosts
    ```

## update_ssl_admatrix.jp.ymlの使い方
* はじめに
	* 処理概要
		1. 対象のサーバーをlvsから外す
       2. （手動で）lvs01 / lvs02で対象のサーバがlvsから外れたかを確認する
       3. 新しい証明書を更新し、正しく更新されているかを確認する
       4. nginxを再起動し、lvsへ組み込む
       5. （手動で）lvs01 / lvs02で対象のサーバがlvsへ組み込まれたことを確認する
    * プログラムの関連性
		* `update_ssl_admatrix.jp.yml`から以下の順番で`roles`を呼び出す
			* `../common_build/roles/ssl_admatrix.jp`
				* `common_build`領域で共通化された処理
* 注意事項
	* **1部更新したら新しい証明書がきちんと更新されているかを確認してから全台行う。また全台の更新は月末月初は避ける**
	* `/home/ansible/api`に移動してからplaybookを実行すること
* 処理概要
	* admatrix.jpのSSL証明書を更新する
* 事前確認事項
	* `inventory/hosts`の[target]グループ内に構築対象のhostsを追記
	* 事前に鍵を解除しておく
		* `openssl sha1 xxx.key`を実行して、値が表示されるか確認する
	* 証明書ファイルをmanagementサーバに配置
	* imgは本番稼働しているので、サービスに影響が出ないように1台ずつ定義する

        ```
        [target]
        api01
        ```

* 実作業
	* dsp_infraチャンネルにSSL証明書更新作業を広報する

    ```
    @here
    【作業広報】api01-08のSSL証明書更新（*.admatrix.jp）
    以下の日時で表題の作業を行いますので、ご認識ください。

    日時 ： MM/DD（x）hh:mm - hh:mm
    対象 ： api01-08のSSL証明書（*.admatrix.jp）
    ```

    * 以下のコマンドでplaybookを実行する

	```
    サービス稼働中のため一つずつ行う。
    #lvsへ外す
    ansible-playbook -i inventory/hosts update_ssl_admatrix.jp.yml --tags remove

    #lvs01から `ipvsadm -L`で外れていることを確認する

    #無事外されたのが確認できたら、新しい証明書一式をコピー
    ansible-playbook -i inventory/hosts update_ssl_admatrix.jp.yml --tags setting

    #証明書の確認ができたら、以下のコマンドでnginxの再起動。無事再起動した時lvsに戻すようになっている
    ansible-playbook -i inventory/hosts update_ssl_admatrix.jp.yml --tags add

    #lvs01系`ipvsadm -L`でインされていることを確認する
    ```

    * インベントリファイルの対象ホストを次のサーバに変えて、全台完了するまでplaybookを実行する
    * 全台作業が完了したら、dsp_infraチャンネルに完了広報を行う。

    ```
    【作業完了広報】api01-08のSSL証明書更新（*.admatrix.jp）
    以下の作業が完了しましたので、ご連絡します。

    https://fullspeed.slack.com/archives/C1PFEEAGY/p1536026499000100
    ```

## update_ssl_t-admatrix.jp.ymlの使い方
* はじめに
	* 処理概要
		* 新しい証明書を更新し、正しく更新されているかを確認する
	* プログラムの関連性
		* `update_ssl_t-admatrix.jp.yml`から以下の順番で`roles`を呼び出す
			* `ssl_t-admatrix.jp`
* 注意事項
	* `/home/ansible/stg`に移動してからplaybookを実行すること
* 処理概要
	* t.admatrix.jpのSSL証明書を更新する
* 事前確認事項
	* `inventory/stg_hosts`の[staging]グループ内に構築対象のhostsを追記
	* 事前に鍵を解除しておく
		* `openssl sha1 xxx.key`を実行して、値が表示されるか確認する
	* 証明書ファイルを配置
	* `roles/ssl_t-admatrix.jp/tasks/main.yml`をコピーする証明書のファイル名に修正

        ```
        [target]
        sapi01
        ```

* 実作業
	* dsp_infraチャンネルにSSL証明書更新作業を広報する
		* 本件はステージング環境なので、共有は任意

    ```
    @here
    【作業広報】sapi01のSSL証明書更新（t-admatrix.jp）
    以下の日時で表題の作業を行いますので、ご認識ください。

    日時 ： MM/DD（x）hh:mm - hh:mm
    対象 ： sapi01のSSL証明書（t-admatrix.jp）
    ```

    * 以下のコマンドでplaybookを実行する

    ```
    ansible-playbook -i inventory/stg_hosts update_ssl_t-admatrix.jp.yml --tags setting
    ansible-playbook -i inventory/stg_hosts update_ssl_t-admatrix.jp.yml --tags add
    ```

    * インベントリファイルの対象ホストを次のサーバに変えて、全台完了するまでplaybookを実行する
    * 全台作業が完了したら、dsp_infraチャンネルに完了広報を行う。

    ```
    【作業完了広報】sapi01のSSL証明書更新（t-admatrix.jp）
    以下の作業が完了しましたので、ご連絡します。

    https://fullspeed.slack.com/archives/C1PFEEAGY/p1536026499000100
    ```