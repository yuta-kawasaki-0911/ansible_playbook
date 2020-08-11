## toc
* [全体概要](#全体概要)
* [前提条件](#前提条件)
* [事前準備](#事前準備)
* [構築手順](#構築手順)
* [レプリケーション設定](#レプリケーション設定)

## 全体概要
* ディレクトリ構造とプログラム一覧
	* トップディレクトリ
		* `/home/ansible/tbl`

```
.
├── README.md
├── build.yml
├── hosts
├── roles
│   ├── mysql_multiproccess
│   │   ├── files
│   │   │   ├── my.cnf
│   │   │   ├── my1.cnf
│   │   │   ├── my3.cnf
│   │   │   └── myf.cnf
│   │   └── tasks
│   │       └── main.yml
│   └── ssd_mount
│       └── tasks
│           └── main.yml
└── vars
    └── mount.yml
```

## 前提条件
### tablau用mysqlプロセス
* dbm02のslave: mysql -uroot -p
* dbm01のslave: mysql -uroot -h 127.0.0.1 -P3307
* dbm03のslave: mysql -uroot -h 127.0.0.1 -P3308
* federated server: mysql -uroot -p -h 127.0.0.1 -P3309

### federatedサーバの用途
* リサーチャーがサーバを跨いだテーブルのjoinを行いたい時、tbl内の各slaveサーバから-P3309内のDB内でそういったことを行なっている。
* これをdbsなどのリモートサーバから直接行おうとすると遅かったり、本番環境への負荷が心配されるため。
* なお、本番のslaveサーバのため、dumpなどは取られていない。

## 構築手順
* インベントリの[add]グループ内に対象ホストを追記
* build.yml内のmysql_passowordに、設定するmysqlパスワードを追記
* 以下のコマンドでplaybookを実行

```
ansible-playbook build.yml -i hosts --ask-vault-pass
```

* `--ask-vault-pass`: ../common_build/roles/mysql_5.7で使用。mysqlのrootのパスワードに使われている。

### レプリケーション設定
#### master
* 書き込みをロック

```
flush tables with read lock;
```

* masterサーバの対象DBのdumpを取得
* masterのバイナリファイルの下記の状態をメモする

```
show master status;

file:
position:
```

* ロックを解除

```
unlock tables;
```

#### slave
* パラメータ設定

```
change master to
master_host=[[ dbmXX ]],
master_user=repl,
master_password=[[ password ]],
master_log_file=[[ バイナリログファイル名]],
master_log_pos=[[ バイナリログの位置 ]];
```

* バイナリログファイル情報はmasterで show master status;した時のfileとposition項目を参照
* レプリケーション対象であるmasterのDBを指定する

```
change replication filter replicate_do_db = ([[ DB名 ]]);
```

* 開始

```
slave start;
```
