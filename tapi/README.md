## toc
* [全体概要](#全体概要)
* [前提条件](#前提条件)
* [事前準備](#事前準備)
* [tapi構築Playbook設計思想](#tapi構築Playbook設計思想)
* [build.ymlの使い方](#build.ymlの使い方)
* [update_ssl_tapi.ymlの使い方](#update_ssl_tapi.ymlの使い方)
* [update_ssl_admatrix.jp.ymlの使い方](#update_ssl_admatrix.jp.ymlの使い方)
* [update_ssl_sync-dmp.sashare.com.ymlの使い方](#update_ssl_sync-dmp.sashare.com.ymlの使い方)
* [update_ssl_sync-dsp.ad-m.asia.ymlの使い方](#update_ssl_sync-dsp.ad-m.asia.ymlの使い方)
* [update_ssl_sync-dsp.t-ad-m.asia.ymlの使い方](#update_ssl_sync-dsp.t-ad-m.asia.ymlの使い方)
* [update_ssl_t-admatrix.jp.ymlの使い方](#update_ssl_t-admatrix.jp.ymlの使い方)

## 全体概要
* ディレクトリ構造とプログラム一覧
    * トップディレクトリ
        * `/home/ansible/tapi`

```
.
├── README.md
├── build.yml
├── build_centos7.yml
├── check_spec.yml
├── inventory
│   ├── hosts
│   └── stg_hosts
├── roles
│   ├── ssl_sync-dmp.sashare.com
│   │   ├── files
│   │   │   ├── cn_sync-dmp.sashare.com.cer.20180418
│   │   │   ├── cn_sync-dmp.sashare.com.cer.to20200720
│   │   │   ├── cn_sync-dmp.sashare.com.cer.to20210820
│   │   │   ├── sync-dmp.sashare.com.key.20180418
│   │   │   ├── sync-dmp.sashare.com.key.to20200720
│   │   │   └── sync-dmp.sashare.com.key.to20210820
│   │   └── tasks
│   │       └── main.yml
│   ├── ssl_sync-dsp.ad-m.asia
│   │   ├── files
│   │   │   ├── cn_sync-dsp.ad-m.asia.cer.to20190602
│   │   │   ├── cn_sync-dsp.ad-m.asia.cer.to20200702
│   │   │   ├── cn_sync-dsp.ad-m.asia.cer.to20210802
│   │   │   ├── sync-dsp.ad-m.asia.cer
│   │   │   ├── sync-dsp.ad-m.asia.crt.to20200702
│   │   │   ├── sync-dsp.ad-m.asia.csr.to20190602
│   │   │   ├── sync-dsp.ad-m.asia.key.to20190602
│   │   │   ├── sync-dsp.ad-m.asia.key.to20200702
│   │   │   └── sync-dsp.ad-m.asia.key.to20210802
│   │   └── tasks
│   │       └── main.yml
│   ├── ssl_sync-dsp.t-ad-m.asia
│   │   ├── files
│   │   │   ├── cn_sync-dsp.t-ad-m.asia.cer.to20200702
│   │   │   ├── cn_sync-dsp.t-ad-m.asia.cer.to20210802
│   │   │   ├── sync-dsp.t-ad-m.asia.cer
│   │   │   ├── sync-dsp.t-ad-m.asia.crt
│   │   │   ├── sync-dsp.t-ad-m.asia.key.to20200702
│   │   │   └── sync-dsp.t-ad-m.asia.key.to20210802
│   │   └── tasks
│   │       └── main.yml
│   ├── ssl_t-admatrix.jp
│   │   ├── files
│   │   │   ├── cn_t-admatrix.jp.crt.to20191118
│   │   │   ├── t-admatrix.jp.cer
│   │   │   ├── t-admatrix.jp.crt
│   │   │   └── t-admatrix.jp.nopass.key
│   │   └── tasks
│   │       └── main.yml
│   └── tapi
│       ├── files
│       │   ├── authorized_keys
│       │   ├── cron
│       │   │   ├── backupLogsToRemoteServer.sh
│       │   │   ├── setBackupVariables.sh
│       │   │   └── trdads_backup_logs
│       │   ├── dsp.war
│       │   ├── fs_dsp_config
│       │   │   ├── env.yml
│       │   │   └── search_engine.yml
│       │   ├── fsdkvs_conf
│       │   │   ├── client-site.properties
│       │   │   └── manager-site.properties
│       │   ├── limits.conf
│       │   ├── logrote_nginx
│       │   ├── lvs
│       │   │   ├── lvs_add.sh
│       │   │   └── lvs_del.sh
│       │   ├── server.xml
│       │   ├── sync.jsp
│       │   └── tomcat_bin
│       │       ├── catalina.sh
│       │       ├── setenv.sh
│       │       ├── shutdown.sh
│       │       └── startup.sh
│       └── tasks
│           └── main.yml
├── update_ssl_admatrix.jp.yml
├── update_ssl_sync-dmp.sashare.com.yml
├── update_ssl_sync-dsp.ad-m.asia.yml
├── update_ssl_sync-dsp.t-ad-m.asia.yml
├── update_ssl_t-admatrix.jp.yml
├── update_ssl_tapi.yml
└── vars
    ├── mount.yml
    ├── nginx.yml
    ├── ssl_sync-dmp.sashare.com.yml
    ├── ssl_sync-dsp.ad-m.asia.yml
    ├── ssl_sync-dsp.t-ad-m.asia.yml
    └── ssl_t-admatrix.jp.yml
```

## 前提条件
* Dell R410だとスペック不足なので注意すること。

## 事前準備
* ansibleユーザーの作成
* ansibleユーザーにmanagementサーバーのSSH鍵の登録
* `/home/ansible/common_build/roles/nginx/files`に必要な証明書の格納
	* 対象はadmatrix.jp
		* ファイル名は証明書名＋`to`以降に証明書の有効期限を`YYYYMMDD`で設定
			* （例）`admatrix.jp.crt.to20191013`

## tapi構築Playbook設計思想
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
	* ssl_admatrix.jp
	* ssl_sync-dsp.ad-m.asia
	* ssl_sync-dmp.sashare.com

### 構築順序
* 基本設定はADMATRIX DSP環境のベース設定となる為、初めに設定を行う。
* SSL証明書の設定はnginx / tomcatの設定が完了したのちに行う。
	* nginxの設定中に起動する処理があるが、SSL証明書未配置の為、エラーとなる
	* 改修するかどうかは今後検討する

## build.yml / build_centos7.ymlの使い方
* はじめに
    * 処理順序
        * `build.yml` / `build_centos7.yml` → `roles/tapi/tasks/main.yml`
            * `build.yml` / `build_centos7.yml`を実行すると、その中で`main.yml`が呼び出される
* 注意事項
    * `/home/ansible/tapi`に移動してからplaybookを実行すること
* 処理概要
    * tapiサーバを構築する
* 事前確認事項
    * inventory/hostsの[add]グループに構築対象のhostsを追記
* 実作業
    * build.ymlの `vars:`内で、証明書の確認を行う
        * 証明書は `../common_build/roles/nginx/files/`以下で一元管理しているので確認すること
    * 以下のコマンドで実行

    ```
    ■CentOS6の場合
    ansible-playbook build.yml -i inventory/hosts

    ■CentOS7の場合
    ansible-playbook build_centos7.yml -i inventory/hosts
    ```

## update_ssl_tapi.ymlの使い方
* はじめに
    * 処理概要
        1. 対象のサーバーをlvsから外す
        2. （手動で）lvs07 / lvs08で対象のサーバがlvsから外れたかを確認する
        3. 新しい証明書を更新し、正しく更新されているかを確認する
        4. nginxを再起動し、lvsへ組み込む
        5. （手動で）lvs07 / lvs08で対象のサーバがlvsへ組み込まれたことを確認する
    * プログラムの関連性
		* `update_ssl.jp.yml`から以下の順番で`roles`を呼び出す
			* `ssl_sync-dsp.ad-m.asia`
			* `ssl_sync-dmp.sashare.com`
    * ymlファイルの設計ポリシー
        * 作成単位
            * 更新するSSL証明書ごとにymlファイルを作成する
* 注意事項
    * **1部更新したら新しい証明書がきちんと更新されているかを確認してから全台行う。また全台の更新は月末月初は避ける**
    * `/home/ansible/tapi`に移動してからplaybookを実行すること
* 処理概要
	* 以下のドメインのSSL証明書を更新する
		* sync-dsp.ad-m.asia
		* sync-dmp.sashare.com
* 事前確認事項
	*  `inventory/hosts`の[target]グループ内に構築対象のhostsを追記
	* 事前に鍵を解除しておく
        * `openssl sha1 xxx.key`を実行して、値が表示されるか確認する
	* 証明書ファイルを配置
        * `roles/sync-dsp.ad-m.asia/files`と`roles/ssl_sync-dmp.sashare.com/files`に配置する
        * ファイル名の末尾に証明書の有効期限年月日を追加しておくこと
	* vars/ssl_sync-dsp.ad-m.asia.yml / ssl_sync-dmp.sashare.com.ymlに更新するssl証明書のファイル名を記載

	```
	（例）
	update_crt: cn_sync-dsp.ad-m.asia.cer.to20210802
	update_key: sync-dsp.ad-m.asia.key.to20210802
	crt_path: /etc/nginx/conf.d/sync-dsp.ad-m.asia/cn_sync-dsp.ad-m.asia.cer
	key_path: /etc/nginx/conf.d/sync-dsp.ad-m.asia/sync-dsp.ad-m.asia.key
	```
	* インベントリファイル(tapi/inventory/hosts)の `[target]` の中に実行対象のホストを追記する
        * tapiは本番稼働しているので、サービスに影響が出ないように1台ずつ定義する

        ```
        [target]
        tapi01
        ```

* 実作業
    * dsp_infraチャンネルにSSL証明書更新作業を広報する

    ```
    @here
    【作業広報】tapi01-08のSSL証明書更新（sync-dsp.ad-m.asia / sync-dmp.sashare.com）
    以下の日時で表題の作業を行いますので、ご認識ください。
    Nginxの再起動を行う為、アラートが発生します。

    日時 ： 9/4（火）11:00 - 12:30
    対象 ： tapi01-08のSSL証明書更新（sync-dsp.ad-m.asia / sync-dmp.sashare.com） ※1台ずつ作業を行います
    ```
    * 以下のコマンドでplaybookを実行する

    ```
    サービス稼働中のため一つずつ行う。
    #lvsへ外す
    ansible-playbook -i inventory/hosts update_ssl_tapi.yml --tags remove

    #lvs07系から `ipvsadm -L`で外れていることを確認する

    #無事外されたのが確認できたら、新しい証明書一式をコピー
    ansible-playbook -i inventory/hosts update_ssl_tapi.yml --tags setting

    #証明書の確認ができたら、以下のコマンドでnginxの再起動。無事再起動した時lvsに戻すようになっている
    ansible-playbook -i inventory/hosts update_ssl_tapi.yml --tags add

    #lvs07系から `ipvsadm -L`でインされていることを確認する
    ```

    * インベントリファイルの対象ホストを次のサーバに変えて、全台完了するまでplaybookを実行する
    * 全台作業が完了したら、dsp_infraチャンネルに完了広報を行う。

    ```
    【作業完了広報】tapi01-08のSSL証明書更新（sync-dsp.ad-m.asia / sync-dmp.sashare.com）
    以下の作業が完了しましたので、ご連絡します。

    https://fullspeed.slack.com/archives/C1PFEEAGY/p1536026499000100
    ```

* 各サーバの証明書の有効期限確認方法は以下の通り。
	* PCのhostsファイルに以下を登録した状態の場合、lvsを経由しないのでポート番号を明確に指定する必要がある
	* lvs経由の場合は、ポート番号の指定は不要（コマンドの場合は443を指定）

```
#tapi SSL証明書確認用
192.168.134.211 sync-dsp.ad-m.asia
192.168.134.211 sync-dmp.sashare.com
```

```
■Webブラウザで確認する場合
https://sync-dsp.ad-m.asia:444/
https://sync-dmp.sashare.com:445/

■コマンドで確認する場合
openssl s_client -connect sync-dsp.ad-m.asia:444 < /dev/null 2> /dev/null | openssl x509 -text | grep Not
openssl s_client -connect sync-dmp.sashare.com:445 < /dev/null 2> /dev/null | openssl x509 -text | grep Not
```

## update_ssl_admatrix.jp.ymlの使い方
* はじめに
    * 処理概要
        1. 対象のサーバーをlvsから外す
        2. （手動で）lvs07 / lvs08で対象のサーバがlvsから外れたかを確認する
        3. 新しい証明書を更新し、正しく更新されているかを確認する
        4. nginxを再起動し、lvsへ組み込む
        5. （手動で）lvs07 / lvs08で対象のサーバがlvsへ組み込まれたことを確認する
    * プログラムの関連性
		* `update_ssl_admatrix.jp.yml`から以下の順番で`roles`を呼び出す
			* `../common_build/roles/ssl_admatrix.jp`
				* `common_build`領域で共通化された処理
    * ymlファイルの設計ポリシー
        * 作成単位
            * 更新するSSL証明書ごとにymlファイルを作成する
* 注意事項
    * **1部更新したら新しい証明書がきちんと更新されているかを確認してから全台行う。また全台の更新は月末月初は避ける**
    * `/home/ansible/tapi`に移動してからplaybookを実行すること
* 事前確認事項
	*  `inventory/hosts`の[target]グループ内に構築対象のhostsを追記
	* 事前に鍵を解除しておく
        * `openssl sha1 xxx.key`を実行して、値が表示されるか確認する
	* 証明書ファイルを配置
        * `../common_build/roles/ssl_admatrix.jp/files`に配置する
        * ファイル名の末尾に証明書の有効期限年月日を追加しておくこと
	* インベントリファイル(tapi/inventory/hosts)の `[target]` の中に実行対象のホストを追記する
        * tapiは本番稼働しているので、サービスに影響が出ないように1台ずつ定義する

        ```
        [target]
        tapi01
        ```

* 実作業
    * dsp_infraチャンネルにSSL証明書更新作業を広報する

    ```
    @here
    【作業広報】tapi01-08のSSL証明書更新（*.admatrix.jp）
    以下の日時で表題の作業を行いますので、ご認識ください。
    Nginxの再起動を行う為、アラートが発生します。

    日時 ： 9/4（火）11:00 - 12:30
    対象 ： tapi01-08のSSL証明書更新（*.admatrix.jp） ※1台ずつ作業を行います
    ```
    * 以下のコマンドでplaybookを実行する

    ```
    サービス稼働中のため一つずつ行う。
    #lvsへ外す
    ansible-playbook -i inventory/hosts update_ssl_admatrix.jp.yml --tags remove

    #lvs07系から `ipvsadm -L`で外れていることを確認する

    #無事外されたのが確認できたら、新しい証明書一式をコピー
    ansible-playbook -i inventory/hosts update_ssl_admatrix.jp.yml --tags setting

    #証明書の確認ができたら、以下のコマンドでnginxの再起動。無事再起動した時lvsに戻すようになっている
    ansible-playbook -i inventory/hosts update_ssl_admatrix.jp.yml --tags add

    #lvs07系から `ipvsadm -L`でインされていることを確認する
    ```

    * インベントリファイルの対象ホストを次のサーバに変えて、全台完了するまでplaybookを実行する
    * 全台作業が完了したら、dsp_infraチャンネルに完了広報を行う。

    ```
    【作業完了広報】tapi01-08のSSL証明書更新（*.admatrix.jp）
    以下の作業が完了しましたので、ご連絡します。

    https://fullspeed.slack.com/archives/C1PFEEAGY/p1536026499000100
    ```

## update_ssl_sync-dmp.sashare.com.ymlの使い方
* はじめに
    * 処理概要
        1. 対象のサーバーをlvsから外す
        2. （手動で）lvs01で対象のサーバがlvsから外れたかを確認する
        3. 新しい証明書を更新し、正しく更新されているかを確認する
        4. nginxを再起動し、lvsへ組み込む
        5. （手動で）lvs01で対象のサーバがlvsへ組み込まれたことを確認する
    * プログラムの関連性
        * `update_ssl_sync-dmp.sashare.com.yml`を実行し、`roles/ssl_sync-dmp.sashare.com/tasks/main.yml`を呼び出す
            * `roles`で`ssl_sync-dmp.sashare.com`を定義している為
    * ymlファイルの設計ポリシー
        * 作成単位
            * 更新するSSL証明書ごとにymlファイルを作成する
    * SSL証明書の設定ファイル
        * sync-dmp.sashare.com
            * `vars/ssl_sync-dmp.sashare.com.yml`
* 注意事項
    * **sync-dmp.sashare.comは表示が失敗したらエンドユーザーに影響が出てしまうサーバなので特に注意して行う事。**
    * **1部更新したら新しい証明書がきちんと更新されているかを確認してから全台行う。また全台の更新は月末月初は避ける**
    * `/home/ansible/tapi`に移動してからplaybookを実行すること
* 事前確認事項
    * 事前に鍵を解除しておく
        * `openssl sha1 xxx.key`を実行して、値が表示されるか確認する
    * 証明書ファイルを配置
        * `tapi/roles/ssl_sync-dmp.sashare.com/files/`に配置する
        * ファイル名の末尾に証明書の有効期限年月日を追加しておくこと
    * インベントリファイル(tapi/inventory/hosts)の `[target]` の中に実行対象のホストを追記する
        * tapiは本番稼働しているので、サービスに影響が出ないように1台ずつ定義する

        ```
        [target]
        tapi01
        ```

* 実作業
    * dsp_infraチャンネルにSSL証明書更新作業を広報する

    ```
    @here
    【作業広報】tapi01-08のSSL証明書更新（sync-dmp.sashare.com）
    以下の日時で表題の作業を行いますので、ご認識ください。
    Nginxの再起動を行う為、アラートが発生します。

    日時 ： 9/4（火）11:00 - 12:30
    対象 ： tapi01-08のSSL証明書更新（sync-dmp.sashare.com） ※1台ずつ作業を行います
    ```
    
    * 以下のコマンドでplaybookを実行する

    ```
    サービス稼働中のため一つずつ行う。
    #lvsへ外す
    ansible-playbook -i inventory/hosts update_ssl_sync-dmp.sashare.com.yml --tags remove

    #lvs07系から `ipvsadm -L`で外れていることを確認する

    #無事外されたのが確認できたら、新しい証明書一式をコピー
    ansible-playbook -i inventory/hosts update_ssl_sync-dmp.sashare.com.yml --tags setting

    #証明書の確認ができたら、以下のコマンドでnginxの再起動。無事再起動した時lvsに戻すようになっている
    ansible-playbook -i inventory/hosts update_ssl_sync-dmp.sashare.com.yml --tags add

    #lvs01から `ipvsadm -L`でインされていることを確認する
    ```

    * インベントリファイルの対象ホストを次のサーバに変えて、全台完了するまでplaybookを実行する
    * 全台作業が完了したら、dsp_infraチャンネルに完了広報を行う。

    ```
    【作業完了広報】tapi01-08のSSL証明書更新（sync-dmp.sashare.com）
    以下の作業が完了しましたので、ご連絡します。

    https://fullspeed.slack.com/archives/C1PFEEAGY/p1536026499000100
    ```

## update_ssl_sync-dsp.ad-m.asia.ymlの使い方
* はじめに
    * 処理概要
        1. 対象のサーバーをlvsから外す
        2. （手動で）lvs01で対象のサーバがlvsから外れたかを確認する
        3. 新しい証明書を更新し、正しく更新されているかを確認する
        4. nginxを再起動し、lvsへ組み込む
        5. （手動で）lvs01で対象のサーバがlvsへ組み込まれたことを確認する
    * プログラムの関連性
        * `update_ssl_sync-dsp.ad-m.asia.yml`を実行し、`roles/sync-dsp.ad-m.asia/tasks/main.yml`を呼び出す
            * `roles`で`sync-dsp.ad-m.asia`を定義している為
    * ymlファイルの設計ポリシー
        * 作成単位
            * 更新するSSL証明書ごとにymlファイルを作成する
    * SSL証明書の設定ファイル
        * sync-dsp.ad-m.asia
            * `vars/ssl_sync-dsp.ad-m.asia.yml`
* 注意事項
    * **1部更新したら新しい証明書がきちんと更新されているかを確認してから全台行う。また全台の更新は月末月初は避ける**
    * `/home/ansible/tapi`に移動してからplaybookを実行すること
* 事前確認事項
    * 事前に鍵を解除しておく
        * `openssl sha1 xxx.key`を実行して、値が表示されるか確認する
    * 証明書ファイルを配置
        * `tapi/roles/sync-dsp.ad-m.asia.yml/files/`に配置する
        * ファイル名の末尾に証明書の有効期限年月日を追加しておくこと
    * インベントリファイル(tapi/inventory/hosts)の `[target]` の中に実行対象のホストを追記する
        * tapiは本番稼働しているので、サービスに影響が出ないように1台ずつ定義する

        ```
        [target]
        tapi01
        ```

* 実作業
    * dsp_infraチャンネルにSSL証明書更新作業を広報する

    ```
    @here
    【作業広報】tapi01-08のSSL証明書更新（sync-dsp.ad-m.asia）
    以下の日時で表題の作業を行いますので、ご認識ください。
    Nginxの再起動を行う為、アラートが発生します。

    日時 ： 9/4（火）11:00 - 12:30
    対象 ： tapi01-08のSSL証明書更新（sync-dsp.ad-m.asia） ※1台ずつ作業を行います
    ```
    
    * 以下のコマンドでplaybookを実行する

    ```
    サービス稼働中のため一つずつ行う。
    #lvsへ外す
    ansible-playbook -i inventory/hosts update_ssl_sync-dsp.ad-m.asia.yml --tags remove

    #lvs01から `ipvsadm -L`で外れていることを確認する

    #無事外されたのが確認できたら、新しい証明書一式をコピー
    ansible-playbook -i inventory/hosts update_ssl_sync-dsp.ad-m.asia.yml --tags setting

    #証明書の確認ができたら、以下のコマンドでnginxの再起動。無事再起動した時lvsに戻すようになっている
    ansible-playbook -i inventory/hosts update_ssl_sync-dsp.ad-m.asia.yml --tags add

    #lvs01から `ipvsadm -L`でインされていることを確認する
    ```

    * インベントリファイルの対象ホストを次のサーバに変えて、全台完了するまでplaybookを実行する
    * 全台作業が完了したら、dsp_infraチャンネルに完了広報を行う。

    ```
    【作業完了広報】tapi01-08のSSL証明書更新（sync-dsp.ad-m.asia）
    以下の作業が完了しましたので、ご連絡します。

    https://fullspeed.slack.com/archives/C1PFEEAGY/p1536026499000100
    ```

## update_ssl_sync-dsp.t-ad-m.asia.ymlの使い方
* はじめに
    * 処理概要
        1. 新しい証明書を更新し、正しく更新されているかを確認する
        2. nginxを再起動する
    * プログラムの関連性
        * `update_ssl_sync-dsp.t-ad-m.asia.yml`を実行し、`roles/sync-dsp.t-ad-m.asia/tasks/main.yml`を呼び出す
            * `roles`で`sync-dsp.t-ad-m.asia`を定義している為
    * ymlファイルの設計ポリシー
        * 作成単位
            * 更新するSSL証明書ごとにymlファイルを作成する
    * SSL証明書の設定ファイル
        * sync-dsp.t-ad-m.asia
            * `vars/ssl_sync-dsp.t-ad-m.asia.yml`
* 注意事項
    * `/home/ansible/tapi`に移動してからplaybookを実行すること
* 事前確認事項
    * 事前に鍵を解除しておく
        * `openssl sha1 xxx.key`を実行して、値が表示されるか確認する
    * 証明書ファイルを配置
        * `tapi/roles/ssl_sync-dsp.t-ad-m.asia/files/`に配置する
        * ファイル名の末尾に現在の年月日を追加しておくこと
    * インベントリファイル(tapi/inventory/stg_hosts)の `[target]` の中に実行対象のホストを追記する

        ```
        [target]
        stapi01
        ```

* 実作業
    * dsp_infraチャンネルにSSL証明書更新作業を広報する

    ```
    @here
    【作業広報】stapi01のSSL証明書更新（sync-dsp.t-ad-m.asia）
    以下の日時で表題の作業を行いますので、ご認識ください。
    Nginxの再起動を行う為、アラートが発生します。

    日時 ： 9/4（火）11:00 - 12:30
    対象 ： stapi01のSSL証明書更新（sync-dsp.t-ad-m.asia）
    ```
    
    * 以下のコマンドでplaybookを実行する

    ```
    ansible-playbook -i inventory/stg_hosts update_ssl_sync-dsp.t-ad-m.asia.yml --tags setting
    ansible-playbook -i inventory/stg_hosts update_ssl_sync-dsp.t-ad-m.asia.yml --tags add
    ```

    * 全台作業が完了したら、dsp_infraチャンネルに完了広報を行う。

    ```
    【作業完了広報】stapi01のSSL証明書更新（sync-dsp.t-ad-m.asia）
    以下の作業が完了しましたので、ご連絡します。

    https://fullspeed.slack.com/archives/C1PFEEAGY/p1536026499000100
    ```

## update_ssl_t-admatrix.jp.ymlの使い方
* はじめに
    * 処理概要
        1. 新しい証明書を更新し、正しく更新されているかを確認する
        2. nginxを再起動する
    * プログラムの関連性
        * `update_ssl_t-admatrix.jp.yml`を実行し、`roles/ssl_t-admatrix.jp/tasks/main.yml`を呼び出す
            * `roles`で`ssl_t-admatrix.jp`を定義している為
    * ymlファイルの設計ポリシー
        * 作成単位
            * 更新するSSL証明書ごとにymlファイルを作成する
            * `main.yml`は共通で1つ用意する
    * SSL証明書の設定ファイル
        * `vars/ssl_t-admatrix.jp.yml`
* 注意事項
    * `/home/ansible/tapi`に移動してからplaybookを実行すること
* 事前確認事項
    * 事前に鍵を解除しておく
        * `openssl sha1 xxx.key`を実行して、値が表示されるか確認する
    * 証明書ファイルを配置
        * `tapi/roles/ssl_t-admatrix.jp/files/`に配置する
        * ファイル名の末尾に現在の年月日を追加しておくこと
    * インベントリファイル(tapi/inventory/stg_hosts)の `[target]` の中に実行対象のホストを追記する

        ```
        [target]
        stapi01
        ```

* 実作業
    * dsp_infraチャンネルにSSL証明書更新作業を広報する

    ```
    @here
    【作業広報】stapi01のSSL証明書更新（*.t-admatrix.jp）
    以下の日時で表題の作業を行いますので、ご認識ください。
    Nginxの再起動を行う為、アラートが発生します。

    日時 ： 9/4（火）11:00 - 12:30
    対象 ： stapi01のSSL証明書更新（*.t-admatrix.jp）
    ```

    * 以下のコマンドでplaybookを実行する

    ```
    ansible-playbook -i inventory/stg_hosts update_ssl_t-admatrix.jp.yml --tags setting
    ansible-playbook -i inventory/stg_hosts update_ssl_t-admatrix.jp.yml --tags add
    ```

    * 全台作業が完了したら、dsp_infraチャンネルに完了広報を行う。

    ```
    【作業完了広報】stapi01のSSL証明書更新（*.t-admatrix.jp）
    以下の作業が完了しましたので、ご連絡します。

    https://fullspeed.slack.com/archives/C1PFEEAGY/p1536026499000100
    ```