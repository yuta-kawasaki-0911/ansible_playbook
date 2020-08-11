## toc
* [全体概要](#全体概要)
* [前提条件](#前提条件)
* [事前準備](#事前準備)
* [bidresult構築Playbook設計思想](#bidresult構築Playbook設計思想)
* [bidresult構築手順](#bidresult構築手順)
* [update_ssl_bidresult-dsp.ad-m.asia.ymlの使い方](#update_ssl_bidresult-dsp.ad-m.asia.ymlの使い方)

## 全体概要
* ディレクトリ構造とプログラム一覧
	* トップディレクトリ
		* `/home/ansible/bidresult`

```
.
├── README.md
├── build.yml
├── build_centos7.yml
├── inventory
│   └── hosts
├── roles
│   ├── bidresult
│   │   ├── files
│   │   │   └── iptables
│   │   └── tasks
│   │       └── main.yml
│   ├── ssl_bidresult-dsp.ad-m.asia
│   │   ├── files
│   │   │   ├── bidresult-dsp.ad-m.asia.cer
│   │   │   ├── bidresult-dsp.ad-m.asia.crt
│   │   │   ├── bidresult-dsp.ad-m.asia.crt.20180219
│   │   │   ├── bidresult-dsp.ad-m.asia.crt.20180222_gs
│   │   │   ├── bidresult-dsp.ad-m.asia.crt.to20200325
│   │   │   ├── bidresult-dsp.ad-m.asia.key.20180219
│   │   │   ├── bidresult-dsp.ad-m.asia.key.20180222_gs
│   │   │   └── bidresult-dsp.ad-m.asia.key.to20200325
│   │   └── tasks
│   │       └── main.yml
│   └── tomcat
│       ├── files
│       │   ├── cron
│       │   │   ├── backup.sh
│       │   │   ├── error_log_count.sh
│       │   │   └── nginx_errorlog_count.sh
│       │   ├── limits.conf
│       │   ├── static-routes
│       │   └── sysctl.conf
│       ├── tasks
│       │   └── main.yml
│       └── templates
│           └── env.default.yml.j2
├── update_ssl_bidresult-dsp.ad-m.asia.yml
└── vars
    ├── mount.yml
    ├── nginx.yml
    └── ssl_bidresult-dsp.ad-m.asia.yml

14 directories, 28 files
```

## 事前準備
* ansibleユーザーの作成
* ansibleユーザーにmanagementサーバーのSSH鍵の登録
* `/home/ansible/bidresult/roles/ssl/files`に必要な証明書と鍵の格納
	* 対象はbidresult-dsp.ad-m.asia
	* ファイル名は証明書名＋`to`以降に証明書の有効期限を`YYYYMMDD`で設定
      （例）`bidresult-dsp.ad-m.asia.crt.to20190223`

## bidresult構築Playbook設計思想
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
	* ssl_bidresult-dsp.ad-m.asia

### 構築順序
* 基本設定はADMATRIX DSP環境のベース設定となる為、初めに設定を行う。
* SSL証明書の設定はnginx / tomcatの設定が完了したのちに行う。
	* nginxの設定中に起動する処理があるが、SSL証明書未配置の為、エラーとなる
	* 改修するかどうかは今後検討する

## bidresult構築手順
* はじめに
	* 処理順序
		* `buid.yml` / `build_centos7.yml`から以下の順番で`roles`を呼び出す
			* `../common_build/roles/common`
			* `./common_build/roles/java`
			* `../common_build/roles/nginx`
			* `ssl_bidresult-dsp.ad-m.asia`
			* `bidresult`
			* `../common_build/roles/mount`
			* `tomcat`
* 注意事項
	* 新規構築の場合、lvsへの組み込みはアプリの設定完了後となるので、外した状態にしておく
* 処理概要
	*  bidresultサーバを構築する
* 事前確認事項
	* `inventory/hosts`の[production]グループ内に構築対象のhostsを追記
	* build.ymlの `vars:`内に証明書の情報を記載する
		* bidresultはnginxなので、ssl証明書の下に中間証明書の中身を貼り付けて結合する
* 実作業
	1. 以下のコマンドでplaybookを実行
		```
		■CentOS6の場合
		ansible-playbook build.yml -i inventory/hosts

		■CentOS7の場合
		ansible-playbook build_centos7.yml -i inventory/hosts
		```
	2. lvsへの追加
		* lvs03,04の `/etc/keepalived.conf`内に以下の設定を追記する。

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

## update_ssl_bidresult-dsp.ad-m.asia.ymlの使い方
* はじめに
	* 処理概要
        1. 対象のサーバーをlvsから外す
        2. （手動で）lvs05 / lvs06で対象のサーバがlvsから外れたかを確認する
        3. 新しい証明書を更新し、正しく更新されているかを確認する
        4. nginxを再起動し、lvsへ組み込む
        5. （手動で）lvs05 / lsv06で対象のサーバがlvsへ組み込まれたことを確認する
	* プログラムの関連性
		* `update_ssl_bidresult-dsp.ad-m.asia.yml`から以下の順番で`roles`を呼び出す
			* `ssl_bidresult-dsp.ad-m.asia`
* 注意事項
	* **1部更新したら新しい証明書がきちんと更新されているかを確認してから全台行う。また全台の更新は月末月初は避ける**
	* `/home/ansible/bidresult`に移動してからplaybookを実行すること
* 処理概要
	* bidresult-dsp.ad-m.asiaのSSL証明書を更新する
* 事前確認事項
	* `inventory/hosts`の[target]グループ内に構築対象のhostsを追記
		* bidresultは本番稼働しているので、サービスに影響が出ないように1台ずつ定義する
	* 事前に鍵を解除しておく
		* `openssl sha1 xxx.key`を実行して、値が表示されるか確認する
	* 証明書ファイルを配置
	* `vars/ssl_bidresult-dsp.ad-m.asia.yml`をコピーする証明書のファイル名に修正
* 実作業
	* dsp_infraチャンネルにSSL証明書更新作業を広報する

    ```
    @here
    【作業広報】bidresult01-04のSSL証明書更新（bidresult-dsp.ad-m.asia）
    以下の日時で表題の作業を行いますので、ご認識ください。

    日時 ： MM/DD（x）hh:mm - hh:mm
    対象 ： bidresult01-04のSSL証明書更新（bidresult-dsp.ad-m.asia）
    ```

    * 以下のコマンドでplaybookを実行する

    ```
    #lvsへ外す
    ansible-playbook -i inventory/hosts update_ssl_bidresult-dsp.ad-m.asia.yml --tags remove

    #lvs01から `ipvsadm -L`で外れていることを確認する

    #無事外されたのが確認できたら、新しい証明書一式をコピー
    ansible-playbook -i inventory/hosts update_ssl_bidresult-dsp.ad-m.asia.yml --tags setting

    #証明書の確認ができたら、以下のコマンドでnginxの再起動
    #無事再起動した時にlvsに戻す処理となっている
    ansible-playbook -i inventory/hosts update_ssl_bidresult-dsp.ad-m.asia.yml --tags add

    #ブラウザから証明書を確認
    #lvs01から `ipvsadm -L`でインされていることを確認する
    ```

    * インベントリファイルの対象ホストを次のサーバに変えて、全台完了するまでplaybookを実行する
    * 全台作業が完了したら、dsp_infraチャンネルに完了広報を行う。

    ```
    【作業完了広報】bidresult01-04のSSL証明書更新（bidresult-dsp.ad-m.asia）
    以下の作業が完了しましたので、ご連絡します。

    https://fullspeed.slack.com/archives/C1PFEEAGY/p1536026499000100
    ```