## toc
* [全体概要](#全体概要)
* [前提条件](#前提条件)
* [事前準備](#事前準備)
* [構築手順](#構築手順)

## 全体概要
* ディレクトリ構造とプログラム一覧
	* トップディレクトリ
		* `/home/ansible/dsp_admin`

```
.
├── README.md
├── change_dadmin02_mount.yml
├── dadmin01_sysops
├── group_vars
│   ├── dadmin_02.yml
│   ├── dadmin_02s.yml
│   ├── dadmin_03.yml
│   └── sweb.yml
├── inventories
│   ├── hosts
│   ├── productions
│   └── staging
├── playbooks
│   ├── build_badmin.yml
│   ├── build_dadmin-fi.yml
│   ├── build_dadmin.yml
│   ├── build_sweb.yml
│   ├── common_build_for_ubuntu.yml
│   ├── mount.yml
│   ├── set_cron.yml
│   └── set_keepalived.yml
├── roles
│   ├── badmin
│   │   ├── files
│   │   │   ├── hosts.allow.badmin
│   │   │   ├── rules.v4.fi01
│   │   │   └── rules.v4.fi02
│   │   └── tasks
│   │       └── main.yml
│   ├── common_build
│   │   ├── files
│   │   │   └── set_iptables.sh
│   │   └── tasks
│   │       └── main.yml
│   ├── cron
│   │   ├── files
│   │   │   └── docker_logrotate
│   │   └── tasks
│   │       └── main.yml
│   ├── dadmin
│   │   ├── files
│   │   │   ├── dadmin-fi01
│   │   │   │   ├── hosts.allow
│   │   │   │   └── iptables
│   │   │   ├── dadmin-fi02
│   │   │   │   ├── hosts.allow
│   │   │   │   └── iptables
│   │   │   ├── dadmin02_sysops
│   │   │   ├── hosts.allow.dadmin02
│   │   │   ├── hosts.allow.dadmin03
│   │   │   ├── iptables.dadmin02.20180507
│   │   │   └── iptables.dadmin03.20180507
│   │   └── tasks
│   │       └── main.yml
│   ├── java
│   │   ├── files
│   │   └── tasks
│   │       └── main.yml
│   ├── keepalived
│   │   ├── files
│   │   │   ├── dadmin-fi01_keepalived.conf
│   │   │   ├── dadmin-fi02_keepalived.conf
│   │   │   ├── dadmin02_keepalived.conf
│   │   │   └── dadmin02s_keepalived.conf
│   │   └── tasks
│   │       └── main.yml
│   ├── nginx
│   │   ├── files
│   │   │   ├── dadmin_02
│   │   │   │   ├── default.conf
│   │   │   │   └── nginx.conf
│   │   │   ├── dadmin_02s
│   │   │   │   ├── default.conf
│   │   │   │   └── nginx.conf
│   │   │   ├── dadmin_03
│   │   │   │   ├── default.conf
│   │   │   │   └── nginx.conf
│   │   │   ├── dadmin_fi
│   │   │   │   ├── admatrix.conf
│   │   │   │   └── tsunagu.conf
│   │   │   └── sweb
│   │   │       ├── default.conf
│   │   │       ├── forit.conf
│   │   │       └── nginx.conf
│   │   └── tasks
│   │       └── main.yml
│   ├── ssl_admin-dsp.ad-m.asia
│   │   ├── files
│   │   │   ├── admin-dsp.ad-m.asia.key.to20200222
│   │   │   └── cn_admin-dsp.ad-m.asia.cer.to20200222
│   │   └── tasks
│   │       └── main.yml
│   └── sweb
│       ├── tasks
│       │   └── main.yml
│       └── vars
│           └── main.yml
├── rules.v4_dadmin-fi01_20181120
├── rules.v4_dadmin-fi02_20181120
├── set_nginx_conf.yml
├── update_ssl_admin-dsp.ad-m.asia.yml
└── vars
    ├── badmin01_mount.yml
    ├── dadmin-fi_cron.yml
    ├── dadmin-fi_keepalived.yml
    ├── dadmin-fi_mount.yml
    ├── dadmin-fi_nginx.yml
    ├── dadmin02_mount.yml
    ├── dadmin02_ubu_cron.yml
    ├── dadmin02_ubu_keepalived.yml
    ├── dadmin02_ubu_mount.yml
    ├── dadmin03_ubu_cron.yml
    ├── dadmin03_ubu_mount.yml
    ├── ssl_admin-dsp.ad-m.asia.yml
    ├── sweb01_mount.yml
    ├── sweb01_ubu_cron.yml
    └── sweb01_ubu_mount.yml
```

## 前提条件
### 本管理領域の対象
* 以下の画面チーム管轄のサーバを管理している。
	* dadmin01 / dadmin02-ubu / dadmin02s-ubu / dadmin03-ubu / badmin01
* その他はdbatch01は`dbatch`領域で管理している。

### dadmin02 / dadmin02sの構成
* keepalivedで実施しているが、lvsは利用しておらず、dadmin02 / dadmin02s自体にkeepalivedを立てて、アクティブ / スタンバイの構成を維持している。

## 事前準備
* ansibleユーザーの作成。
* ansibleユーザーにmanagementサーバーのSSH鍵の登録。
* [【参考】新しくサーバを追加するときの手順](https://qiita.com/hogepiyo/items/e698036e52661c333f4c)

## 構築手順
### build.ymlについて
#### nginxの設定ファイルに関して
* role/nginx/files/に各ホスト用のディレクトリを作成し、その中に各種設定ファイルを配置する。
* vars/に `各ホスト_nginx.yml`の名前でファイルを定義する。その中でplaybook実行時にcopyする設定ファイルと配置先のパス、権限を定義する。
* playbook実行時にbuild.ymlの `vars_files:` に該当のファイルを定義する。

### set_nginx_conf.ymlについて
#### 作成した経緯
* サーバによってnginxの設定ファイルの中身が異なるようになり、開発側からも管理・運用できる仕組みが必要になったため作成。

#### 使用方法
* nginxのファイルを管理しているパス: `./roles/nginx/files/`
* 以下のコマンドでplaybookを実行してconfigファイルを撒く

```
$ ansible-playbook -i inventories/[[対象ファイル]] set_nginx_conf.yml
```

### sweb01のiptablesの設定について
* sweb01はsgw01/02でvirtualのglobalipが設定されている
* `DSP管理画面のテスト環境のにてIP許可したい`という依頼が来た時は、sgw01 / sgw02のitablesにglobalIPを許可するように設定する運用をしていたが、**Akamai導入に伴い、sgw01 / sgw02のhttp / httpsのソースIPを全て許可している為、設定作業は不要**となっている。

### その他メモ
* ubuntuサーバのssl証明書のパス。

```
worker@sweb01-ubuntu:~/deploy/shared/nginx/ssl$ pwd
/home/worker/deploy/shared/nginx/ssl
worker@sweb01-ubuntu:~/deploy/shared/nginx/ssl$ ls
server.crt  server.key
※他のサーバも全て同じです
```

### dadmin-fi01, dadmin-fi02の仕様メモ
* [サービスドキュメントフォルダ](https://docs.google.com/presentation/d/1Oh32wtwYc9Rf3T2Pb9NYDJBdCpSQUbcOtE6XAOMHarA/edit#slide=id.g3c2a37cbab_0_0)
* 関連チャンネル: [#dsp_forit](https://fullspeed.slack.com/messages/C95K9ALVD)

### update_ssl_admin-dsp.ad-m.asia.ymlの使い方
* はじめに
	* 今後の作業
		* **Let's Encrypt化を実施した為、Ansible Playbookでの更新作業は不要。**
		* 以下のドキュメントは今後、有償の証明書に戻した際に利用する目的で残す。
	* 処理概要
        1. 新しい証明書を更新し、正しく更新されているかを確認する
        2. nginxを再起動する
	* プログラムの関連性
		* update_ssl_admin-dsp.ad-m.asia.yml
			* `ssl_admin-dsp.ad-m.asia`
* 注意事項
	* **表示が失敗したらエンドユーザーに影響が出てしまうサーバなので特に注意して行う事。**
	* `/home/ansible/dadmin01`に移動してからplaybookを実行する事。
* 処理概要
	* 以下のドメインのSSL証明書を更新する
		* ssl_admin-dsp.ad-m.asia
* 事前確認事項
	* `inventory/hosts`の[target]グループ内に構築対象のhostsを追記
	* 事前に鍵を解除しておく
		* `openssl sha1 xxx.key`を実行して、値が表示されるか確認する
	* 証明書ファイルを配置
	* `dadmin01/roles/ssl_ssl_admin-dsp.ad-m.asia/files/` に配置。その際ファイル名の末尾に現在の日時を追加しておくこと。
	* vars/ssl_ssl_admin-dsp.ad-m.asia.ymlに更新するssl証明書のファイル名を記載

	```
	（例）
	update_crt: cn_admin-dsp.ad-m.asia.cer.to20200222
	update_key: admin-dsp.ad-m.asia.key.to20200222
	crt_path: /etc/nginx/conf.d/cn_admin-dsp.ad-m.asia.cer
	key_path: /etc/nginx/conf.d/admin-dsp.ad-m.asia.key
	```

	* インベントリファイル(dadmin01/inventory/hosts)の `[target]` の中に実行対象のホストを追記

	```
	[target]
	dapi01
	```

* 実作業
	* dsp_infraチャンネルにSSL証明書更新作業を広報する

    ```
    @here
	【作業広報】dadmin01のSSL証明書更新（admin-dsp.ad-m.asia）
	以下の日時で表題の作業を行いますので、ご認識ください。

	日時 ： 2/21（木）11:30 - 12:30
	対象 ： dadmin01のSSL証明書更新（admin-dsp.ad-m.asia）
	備考 ： reloadで設定を反映します	
	```

	* 以下のコマンドでplaybookを実行する

	```
	#新しい証明書一式をコピー
	ansible-playbook -i inventory/hosts update_ssl_admin-dsp.ad-m.asia.yml --tags setting

	#証明書の確認ができたら、以下のコマンドでnginxの再起動
	ansible-playbook -i inventory/hosts update_ssl_admin-dsp.ad-m.asia.yml --tags add
	```

	* 作業が完了したら、dsp_infraチャンネルに完了広報を行う。

    ```
    【作業完了広報】dadmin01のSSL証明書更新（admin-dsp.ad-m.asia）
	以下の作業が完了しましたので、ご連絡します。

	https://fullspeed.slack.com/archives/C1PFEEAGY/p1550716127012500

	Desktop 11:45:05 RN-307 $ openssl s_client -connect admin-dsp.ad-m.asia:443 < /dev/null 2> /dev/null | openssl x509 -text | grep Not
            Not Before: Feb 21 02:00:35 2019 GMT
            Not After : Feb 22 02:00:35 2020 GMT
	Desktop 11:45:06 RN-307 $ 
	※ブラウザ上からも証明書が更新されていることを確認済み
	```

### 備考
* dadmin01のsysopsも管理している。