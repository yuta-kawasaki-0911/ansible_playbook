## toc
* [全体概要](#全体概要)
* [前提条件](#前提条件)
* [事前準備](#事前準備)
* [構築手順](#構築手順)

## 全体概要
### ansible
* ディレクトリ構造とプログラム一覧
	* トップディレクトリ
		* `/home/ansible/kvs`

```
.
├── README.md
├── build_bkvs.yml
├── build_ckvs.yml
├── build_dkvs.yml
├── build_dkvsm.yml
├── group_vars
│   ├── bkvs.yml
│   ├── dkvsm.yml
│   └── skvsm.yml
├── inventories
│   ├── production
│   └── staging
├── roles
│   ├── cron
│   │   ├── files
│   │   │   ├── bkvs
│   │   │   │   ├── logrotate.d
│   │   │   │   │   └── logrotate.d
│   │   │   │   │       ├── dracut
│   │   │   │   │       ├── redis
│   │   │   │   │       ├── syslog
│   │   │   │   │       ├── yum
│   │   │   │   │       └── zabbix-agent
│   │   │   │   └── makewhatis.cron
│   │   │   ├── ckvs
│   │   │   │   ├── logrotate
│   │   │   │   ├── logrotate.d
│   │   │   │   │   ├── dracut
│   │   │   │   │   ├── munin-node
│   │   │   │   │   ├── redis
│   │   │   │   │   ├── syslog
│   │   │   │   │   ├── yum
│   │   │   │   │   └── zabbix-agent
│   │   │   │   └── makewhatis.cron
│   │   │   ├── dkvs_logrotate.d
│   │   │   │   └── logrotate.d
│   │   │   │       ├── dracut
│   │   │   │       ├── munin-node
│   │   │   │       ├── redis
│   │   │   │       ├── syslog
│   │   │   │       ├── yum
│   │   │   │       └── zabbix-agent
│   │   │   └── dkvsm
│   │   │       ├── backup_log.sh
│   │   │       ├── logrotate.d
│   │   │       │   ├── dracut
│   │   │       │   ├── syslog
│   │   │       │   ├── yum
│   │   │       │   └── zabbix-agent
│   │   │       ├── makewhatis.cron
│   │   │       └── restore.sh
│   │   └── tasks
│   │       └── main.yml
│   └── redis
│       ├── files
│       │   ├── bkvs
│       │   │   └── redis.conf
│       │   ├── ckvs
│       │   │   └── redis.conf
│       │   └── dkvs
│       │       └── redis.conf
│       └── tasks
│           └── main.yml
└── vars
    ├── bkvs_cron.yml
    ├── bkvs_mount.yml
    ├── ckvs_cron.yml
    ├── dkvs_cron.yml
    ├── dkvs_mount.yml
    └── dkvsm_cron.yml
```

## 前提条件
### 全般
* dkvs, bkvsサーバ共に水平分割されている形。
* bkvsはdkvsから請求系の情報を抜いて別にしたもの。
* redis-sentinelや特別なクラスタ設定は行われていない。
* 起動やバックアップ等の操作をdkvsmサーバから行なっている。

### その他
* ミドルウェア以上の構築は簡単。
* ただし使われているcpu / メモリが高価なのでサーバを予め準備しておくことが大切。
* mount先のrnas01はSSD使用。

## 事前準備
* ansibleユーザーの作成
* ansibleユーザーにmanagementサーバーのSSH鍵の登録

## 構築手順
* build_XXX.ymlを使う
* dkvsを構築する時
	* インベントリ(inventory/production)の `[add_dkvs]` に対象サーバのホスト名を追記
	* build_dkvs.ymlの内容を確認
	* 以下のコマンドを実行
		* `ansible-playbook build_dkvs.yml -i inventory/production`
* bkvs, ckvs, dkvsmを構築する時
	* インベントリの `[add_dkvs]` を対象ホストのものに変えて実行する。