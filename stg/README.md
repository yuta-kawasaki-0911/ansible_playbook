## toc
* [全体概要](#全体概要)
* [前提条件](#前提条件)
* [事前準備](#事前準備)
* [update_ssl_t-admatrix.jp.ymlの使い方](#update_ssl_t-admatrix.jp.ymlの使い方)

## 全体概要
* ディレクトリ構造とプログラム一覧
	* トップディレクトリ
		* `/home/ansible/stg`

```
.
├── README.md
├── inventory
│   ├── hosts
│   └── stg_hosts
├── roles
│   └── ssl_t-admatrix.jp
│       ├── files
│       │   ├── cn_t-admatrix.jp.crt.to20191118
│       │   ├── t-admatrix.jp.crt.to20191118
│       │   └── t-admatrix.jp.nopass.key
│       └── tasks
│           └── main.yml
├── update_ssl.retry
├── update_ssl_t-admatrix.jp.yml
└── vars
    └── ssl_t-admatrix.jp.yml
```

## 前提条件
### ハードウェア型番
* TBD

### CPU型番
* TBD

### Memory
* TBD

### Harddisk
* TBD

### OS
* TBD

### nginx
* TBD

### java
* TBD

## 事前準備
* ansibleユーザーの作成
* ansibleユーザーにmanagementサーバーのSSH鍵の登録
* `/home/ansible/stg/roles/ssl_t-admatrix.jp/files`に必要な証明書と鍵の格納
	* 対象はt-admatrix.jp
	* ファイル名は証明書名＋`to`以降に証明書の有効期限を`YYYYMMDD`で設定
      （例）`t.admatrix.jp.to20191118`

## update_ssl_t-admatrix.jp.ymlの使い方
* はじめに
	* 処理順序
		* `update_ssl_t-admatrix.jp.yml`から以下の順番で`roles`を呼び出す
			* `ssl_t-admatrix.jp`
* 注意事項
	* `/home/ansible/stg`に移動してからplaybookを実行すること
* 処理概要
	* t.admatrix.jpのSSL証明書を更新する
* 事前確認事項
	* `inventory/stg_hosts`の[target]グループ内に構築対象のhostsを追記
	* 事前に鍵を解除しておく
		* `openssl sha1 xxx.key`を実行して、値が表示されるか確認する
	* `roles/ssl_t-admatrix.jp/files/`に証明書ファイルを配置
* 実作業
	* dsp_infraチャンネルにSSL証明書更新作業を広報する

    ```
    @here
    【作業広報】stg02のSSL証明書更新（t-admatrix.jp）
    以下の日時で表題の作業を行いますので、ご認識ください。

    日時 ： MM/DD（x）hh:mm - hh:mm
    対象 ： stg02のSSL証明書（t-admatrix.jp）
    ```

    * 以下のコマンドでplaybookを実行する

    ```
    ansible-playbook -i inventory/stg_hosts update_ssl_t-admatrix.jp.yml --tags setting
    ansible-playbook -i inventory/stg_hosts update_ssl_t-admatrix.jp.yml --tags add

    ```

    * 作業が完了したら、dsp_infraチャンネルに完了広報を行う。

    ```
    【作業完了広報】stg02のSSL証明書更新（t-admatrix.jp）
    以下の作業が完了しましたので、ご連絡します。

    https://fullspeed.slack.com/archives/C1PFEEAGY/p1536026499000100
    ```