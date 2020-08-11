## toc
* [全体概要](#全体概要)
* [relay構築手順](#relay構築手順)
* [update_ssl_relay-dsp.ad-m.asia.ymlの使い方](#update_ssl_relay-dsp.ad-m.asia.ymlの使い方)

## 全体概要
* ディレクトリ構造とプログラム一覧
	* トップディレクトリ
		* `/home/ansible/relay`

```
.
├── README.md
├── build.yml
├── check.yml
├── inventory
│   └── hosts
├── roles
│   ├── relay
│   │   ├── files
│   │   │   ├── error_log_count.sh
│   │   │   ├── nginx_errorlog_count.sh
│   │   │   ├── relay_backup_logs
│   │   │   ├── root_temp
│   │   │   │   ├── backupLogsToRemoteServer.sh
│   │   │   │   ├── exe_cmd.sh
│   │   │   │   ├── setBackupVariables.sh
│   │   │   │   └── trdads_backup_logs
│   │   │   ├── sysctl.conf
│   │   │   └── sysops
│   │   └── tasks
│   │       └── main.yml
│   ├── ssl
│   │   ├── files
│   │   │   ├── cn_relay-dsp.ad-m.asia_20180518.crt
│   │   │   ├── relay-dsp.ad-m.asia_20180518.key
│   │   │   └── relay-dsp.ad-m.asia_20180518.pem
│   │   └── tasks
│   │       └── main.yml
│   ├── ssl_relay-dsp.ad-m.asia
│   │   ├── files
│   │   │   ├── cn_relay-dsp.ad-m.asia.crt.to20200617
│   │   │   ├── cn_relay-dsp.ad-m.asia.crt.to20210718
│   │   │   ├── cn_relay-dsp.ad-m.asia_20180518.crt
│   │   │   ├── relay-dsp.ad-m.asia.key.to20200617
│   │   │   ├── relay-dsp.ad-m.asia.key.to20210718
│   │   │   ├── relay-dsp.ad-m.asia_20180518.key
│   │   │   └── relay-dsp.ad-m.asia_20180518.pem
│   │   └── tasks
│   │       └── main.yml
│   └── ssl_relay-dsp.t-ad-m.asia
│       ├── files
│       │   ├── cn_relay-dsp.t-ad-m.asia.crt.to20210228
│       │   ├── relay-dsp.t-ad-m.asia.cer
│       │   ├── relay-dsp.t-ad-m.asia.crt
│       │   └── relay-dsp.t-ad-m.asia.key.to20210228
│       └── tasks
│           └── main.yml
├── update_ssl.yml
├── update_ssl_relay-dsp.ad-m.asia.yml
├── update_ssl_relay-dsp.t-ad-m.asia.yml
└── vars
    ├── mount.yml
    ├── nginx.yml
    ├── ssl_relay-dsp.ad-m.asia.yml
    └── ssl_relay-dsp.t-ad-m.asia.yml
```

## relay構築手順
* はじめに
	* 処理順序
		* `build.yml`から以下の順番で`roles`を呼び出す
			* `../common_build/roles/common`
			* `../common_build/roles/java`
			* `../common_build/roles/nginx`
			* `relay`
			* `ssl_relay-dsp.ad-m.asia`
			* `../common_build/roles/mount`
* 注意事項
	* 新規構築の場合、lvsへの組み込みはアプリの設定完了後となるので、外した状態にしておく
* 処理概要
	*  relayサーバを構築する
* 事前確認事項
	* `inventory/hosts`の[production]グループ内に構築対象のhostsを追記
	* build.ymlの `vars:`内に証明書の情報を記載する
		* relayはnginxなので、ssl証明書の下に中間証明書の中身を貼り付けて結合する
* 実作業
	1. 以下のコマンドでplaybookを実行
		```
		ansible-playbook build.yml -i inventory/hosts
		```
	2. lvsへの追加
		* lvs05,06の`/etc/keepalived.conf`内に以下の設定を追記する。

		```
		real_server [[ipアドレス]] 80 {
		weight 1
		inhibit_on_failure
		HTTP_GET {
		url {
		path /health.html
		status_code 200
		}
		connect_port 80
		connect_timeout 10
		}
		}

		real_server [[ipアドレス]] 443 {
		weight 1
		inhibit_on_failure
		SSL_GET {
		url {
		path /health.html
		status_code 200
		}
		connect_port 443
		connect_timeout 10
		}
		}
		```

		* [[ipアドレス]]:192.168.199.~の方のipを記入する

## update_ssl_relay-dsp.ad-m.asia.ymlの使い方
* はじめに
	* 処理概要
        1. 対象のサーバーをlvsから外す
        2. （手動で）lvs05 / lvs06で対象のサーバがlvsから外れたかを確認する
        3. 新しい証明書を更新し、正しく更新されているかを確認する
        4. nginxを再起動し、lvsへ組み込む
        5. （手動で）lvs05 / lvs06で対象のサーバがlvsへ組み込まれたことを確認する
	* プログラムの関連性
		* `update_ssl_relay-dsp.ad-m.asia.yml`から以下の順番で`roles`を呼び出す
			* `ssl_relay-dsp.ad-m.asia`
* 注意事項
	* **1部更新したら新しい証明書がきちんと更新されているかを確認してから全台行う。また全台の更新は月末月初は避ける**
	* `/home/ansible/relay`に移動してからplaybookを実行すること
* 事前確認事項
	* `inventory/hosts`の[target]グループ内に構築対象のhostsを追記
		* relayは本番稼働しているので、サービスに影響が出ないように1台ずつ定義する
	* 事前に鍵を解除しておく
		* `openssl sha1 xxx.key`を実行して、値が表示されるか確認する
	* 証明書ファイルを配置
	* `vars/ssl_relay-dsp.ad-m.asia.yml`をコピーする証明書のファイル名に修正
* 実作業
	* dsp_infraチャンネルにSSL証明書更新作業を広報する

    ```
    @here
    【作業広報】relay01-04のSSL証明書更新（relay-dsp.ad-m.asia）
    以下の日時で表題の作業を行いますので、ご認識ください。

    日時 ： MM/DD（x）hh:mm - hh:mm
    対象 ： relay01-04のSSL証明書更新（relay-dsp.ad-m.asia）
    ```

    * 以下のコマンドでplaybookを実行する

    ```
    #lvsへ外す
    ansible-playbook -i inventory/hosts update_ssl_relay-dsp.ad-m.asia.yml --tags remove

    #lvs05から `ipvsadm -L`で外れていることを確認する

    #無事外されたのが確認できたら、新しい証明書一式をコピー
    ansible-playbook -i inventory/hosts update_ssl_relay-dsp.ad-m.asia.yml --tags setting

    #証明書の確認ができたら、以下のコマンドでnginxの再起動
    #無事再起動した時にlvsに戻す処理となっている
    ansible-playbook -i inventory/hosts update_ssl_relay-dsp.ad-m.asia.yml --tags add

    #ブラウザから証明書を確認
    #lvs05から `ipvsadm -L`でインされていることを確認する
    ```

    * インベントリファイルの対象ホストを次のサーバに変えて、全台完了するまでplaybookを実行する
    * 全台作業が完了したら、dsp_infraチャンネルに完了広報を行う。

    ```
    【作業完了広報】relay01-04のSSL証明書更新（relay-dsp.ad-m.asia）
    以下の作業が完了しましたので、ご連絡します。

    https://fullspeed.slack.com/archives/C1PFEEAGY/p1536026499000100
    ```
    
## update_ssl_relay-dsp.t-ad-m.asia.ymlの使い方
* はじめに
	* 処理概要
        1. 新しい証明書を更新し、正しく更新されているかを確認する
        2. nginxを再起動する
	* プログラムの関連性
		* `update_ssl_relay-dsp.t-ad-m.asia.yml`から以下の順番で`roles`を呼び出す
			* `ssl_relay-dsp.t-ad-m.asia`
* 注意事項
	* `/home/ansible/relay`に移動してからplaybookを実行すること
* 事前確認事項
	* `inventory/hosts`の[target]グループ内に構築対象のhostsを追記
	* 事前に鍵を解除しておく
		* `openssl sha1 xxx.key`を実行して、値が表示されるか確認する
	* 証明書ファイルを配置
	* `vars/ssl_relay-dsp.t-ad-m.asia.yml`をコピーする証明書のファイル名に修正
* 実作業
	* dsp_infraチャンネルにSSL証明書更新作業を広報する

    ```
    @here
    【作業広報】srelay01-02のSSL証明書更新（relay-dsp.t-ad-m.asia）
    以下の日時で表題の作業を行いますので、ご認識ください。

    日時 ： MM/DD（x）hh:mm - hh:mm
    対象 ： srelay01-02のSSL証明書更新（relay-dsp.t-ad-m.asia）
    ```

    * 以下のコマンドでplaybookを実行する

    ```
    #新しい証明書一式をコピー
    ansible-playbook -i inventory/hosts update_ssl_relay-dsp.t-ad-m.asia.yml --tags setting

    #証明書の確認ができたら、以下のコマンドでnginxの再起動
    ansible-playbook -i inventory/hosts update_ssl_relay-dsp.t-ad-m.asia.yml --tags add

    #ブラウザから証明書を確認
    ```

    * インベントリファイルの対象ホストを次のサーバに変えて、全台完了するまでplaybookを実行する
    * 全台作業が完了したら、dsp_infraチャンネルに完了広報を行う。

    ```
    【作業完了広報】srelay01-02のSSL証明書更新（relay-dsp.t-ad-m.asia）
    以下の作業が完了しましたので、ご連絡します。

    https://fullspeed.slack.com/archives/C1PFEEAGY/p1536026499000100
    ```