## toc
* [全体概要](#全体概要)
* [事前準備](#事前準備)
* [build.ymlの使い方](#build.ymlの使い方)

## 全体概要
* ディレクトリ構造とプログラム一覧
	* トップディレクトリ
		* `/home/ansible/ip_db`

```
.
├── README.md
├── build_ipdb-api01.yml
├── build_ipdb-batch01.yml
├── build_ipdb-db.yml
└── inventory
    └── hosts
```

* 稼働しているドメイン
	* ipdb-api01: `ipdbapi.admatrix.jp`

## 事前準備
* ansibleユーザーの作成
* ansibleユーザーにmanagementサーバーのSSH鍵の登録

## build_xxx.ymlの使い方
* はじめに
	* 各サーバ種別ごとにplaybookを用意している。
		* api : `build_ipdb-api.yml`
		* batch : `build_ipdb-batch.yml`
		* DB : `build_ipdb-db.yml`
	* 処理順序
		* `build.yml`から以下の順番で`roles`を呼び出す
			* `../common_build/roles/common`
* 注意事項
	* `/home/ansible/ip_db`に移動してからplaybookを実行すること
* 処理概要
	* ipdbサーバを構築する
* 事前確認事項
	* `inventory/hosts`の[add]グループ内に構築対象のhostsを追記
* 実作業
	* 各サーバに対応したplaybookを実行

		```
		■ipdb-api01を構築する場合
		ansible-playbook build_ipdb-api.yml -i inventory/hosts
		```