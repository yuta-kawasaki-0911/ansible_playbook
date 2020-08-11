## toc
* [全体概要](#全体概要)
* [事前準備](#事前準備)
* [構築手順](#構築手順)
* [keepalivedの設定を行う](#keepalivedの設定を行う)
* [起動時のコマンド](#起動時のコマンド)
* [レプリケーションの設定](#レプリケーションの設定)

## 全体概要
* ディレクトリ構造とプログラム一覧
	* トップディレクトリ
		* `/home/ansible/mongo`

```
.
├── README.md
├── build_ndmongoa.yml
├── build_ndmongom.yml
├── build_ndmongos.yml
├── inventory
│   └── production
├── mount.yml
├── n-build_ndmongoa.yml
├── n-build_ndmongom.retry
├── n-build_ndmongom.yml
├── n-build_ndmongos.retry
├── n-build_ndmongos.yml
├── roles
│   ├── cron
│   │   ├── files
│   │   │   ├── ndmongoa
│   │   │   │   ├── cron.daily
│   │   │   │   │   ├── logrotate
│   │   │   │   │   └── makewhatis.cron
│   │   │   │   └── logrotate.d
│   │   │   │       ├── dracut
│   │   │   │       ├── hp-snmp-agents
│   │   │   │       ├── syslog
│   │   │   │       └── yum
│   │   │   ├── ndmongom
│   │   │   │   ├── cron.daily
│   │   │   │   │   ├── logrotate
│   │   │   │   │   └── makewhatis.cron
│   │   │   │   └── logrotate.d
│   │   │   │       ├── dracut
│   │   │   │       ├── syslog
│   │   │   │       └── yum
│   │   │   └── ndmongos
│   │   │       ├── cron.daily
│   │   │       │   ├── logrotate
│   │   │       │   ├── makewhatis.cron
│   │   │       │   └── mongodump
│   │   │       └── logrotate.d
│   │   │           ├── dracut
│   │   │           ├── syslog
│   │   │           └── yum
│   │   └── tasks
│   │       └── main.yml
│   ├── keepalived
│   │   ├── tasks
│   │   │   └── main.yml
│   │   └── templates
│   │       └── keepalived.conf.j2
│   ├── mongodb2.6
│   │   ├── files
│   │   │   ├── mongo.repo
│   │   │   ├── ndmongoa
│   │   │   │   └── mongod.conf
│   │   │   ├── ndmongom
│   │   │   │   └── mongod.conf
│   │   │   └── ndmongos
│   │   │       └── mongod.conf
│   │   └── tasks
│   │       └── main.yml
│   └── mongodb3.6
│       ├── files
│       │   ├── disable-transparent-hugepages
│       │   ├── mongo.repo
│       │   ├── mongod.conf
│       │   └── mongodb-keyfile
│       └── tasks
│           └── main.yml
├── set_keepalived.retry
├── set_keepalived.yml
├── set_keepalived_n-mongo.yml
└── vars
    ├── n-ndmongom_cron.yml
    ├── n-ndmongos_cron.yml
    ├── n-ndmongos_mount.yml
    ├── ndmongoa_cron.yml
    ├── ndmongom_cron.yml
    ├── ndmongos_cron.yml
    └── ndmongos_mount.yml
```

## 事前準備
* ansibleユーザーの作成
* ansibleユーザーにmanagementサーバーのSSH鍵の登録

## 構築手順
* インベントリに対象ホストを追記

```
#例 inventory/production
[add]
ndmongom
```

* 対象サーバのbuid playbookを実行

```
#例
ansible-playbook build_ndmongom.yml -i inventory/production
```

* build_ndmongoX.yml: 2018.06リプレイス前(mongodb2.6)
* n-build_ndmongoX.yml: リプレイス後(mongodb3.6)

## About backup & restore
### backup
* slave02のcron.daily/mongodumpスクリプトにて行なっている

### restore
* `mongodump -v --out [[バックアップファイル名]]`
	* 2.6では未検証だが、空のdbは作成されない可能性がある

## About Replication
### 概要
* PRIMARY: ndmongom
* SECONDARY: ndmongos
* ARBITER: ndmongoa

### 備考
* primaryとsecondaryの役割は入れ替わらないようにする。
* もし逆になってしまったら、primaryになってしまっているサーバで以下を実行。
	* `PRIMARY> rs.stepDown()`

## keepalivedの設定
### 概要
* ndmongomとndmongosはkeepalivedでvirtual ipの共有が行われている。
* masterにvipが付与され、masterが落ちた時はslaveにvipが付与されることでアクセス先が持続する。

### 構築
* set_keepalived.confを確認
	* 対象ホストとvars: 以下の変数の値を確認する。

```
# varsは二箇所ある
vars:
  vrip: #ネットワークの中で固有のvirtual_route_ip
  global_vip: #二つのサーバ間で共有するvip
  interface: #サーバによって異なるので注意
```

* 以下のコマンドで実行

```
# ミドルウェアのインストールと設定ファイルの配布
ansible-playbook set_keepalived.yml -i inventory/production --tags setting

# keepalivedの起動
ansible-playbook set_keepalived.yml -i inventory/production --tags start 
```

## 起動時のコマンド
* mongodbの起動

```
mongod -f /etc/mongod.conf &
```

* /etc/init.dやserviceコマンドはstopはできるが起動は行えない。
* これはmongo起動時に出てくる「WARNING: You are running on a NUMA machine. ...」を消すために `numactl --interleave=all mongod [other options]`　を使ったことが原因。
* 再同期をすれば元に戻る。

* login
```
mongo -u root -p --authenticationDatabase="admin"
```

## ユーザーの設定
```
{ "_id" : "admin.root", "user" : "root", "db" : "admin", "credentials" : { "SCRAM-SHA-1" : { "iterationCount" : 10000, "salt" : "aRsQubXgpVeC3TC2kTJ7Kg==", "storedKey" : "SaE1sjNZlWaY4o7fuDn09tAM5s4=", "serverKey" : "0kjLINANshQtX+DpUR781mHEK98=" } }, "roles" : [ { "role" : "root", "db" : "admin" } ] }

//画面サーバがアクセスするときに使っているアカウント
{ "_id" : "admin.dsp", "user" : "dsp", "db" : "admin", "credentials" : { "SCRAM-SHA-1" : { "iterationCount" : 10000, "salt" : "sj8FyDcQoUIIgxzUfnPcDQ==", "storedKey" : "aDc2b+8+EV2z2DSLnlM16efMRrM=", "serverKey" : "yoqidySQz/VWUmxOTdU8gvzJsA0=" } }, "roles" : [ { "role" : "root", "db" : "admin" } ] }
```

## レプリケーションの設定
* master(ndmongom)からmongoに接続
* レプリカセット

```
> config = {
_id: "nfsmongo"
members: [
  { _id: 0, host: "n-ndmongom:27017", priority: 1000 },
  { _id: 1, host: "n-ndmongos:27017", priority: 1 },
  { _id: 2, host: "n-ndmongoa:27017", arbiterOnly: true, priority: 0 }
]
}

> rs.initiate(config)
```

* slaveとarbiterを追加

```
> rs.add("n-ndmongom:27017");
```
