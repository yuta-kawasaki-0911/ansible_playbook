## toc
* [全体概要](#全体概要)
* [前提条件](#前提条件)
* [build_db.ymlの使い方](#build_db.ymlの使い方)
* [set_mysql_app_user.ymlの使い方](#set_mysql_app_user.ymlの使い方)
* [データリストア時のTips](#データリストア時のTips)

## 全体概要
* ディレクトリ構造とプログラム一覧
	* トップディレクトリ
		* `/home/ansible/db`

```
├── README.md
├── build.yml
├── build_centos7.yml
├── build_dbfm01.yml
├── check_status.yml
├── inventory
│   └── production
├── production
├── restart_mysql.yml
├── roles
│   ├── cron_dbfm01
│   │   ├── files
│   │   │   └── dbfm01
│   │   │       ├── daily
│   │   │       │   ├── logrotate
│   │   │       │   └── makewhatis.cron
│   │   │       └── logrotate
│   │   │           ├── dracut
│   │   │           ├── mysql
│   │   │           ├── syslog
│   │   │           └── yum
│   │   └── tasks
│   │       └── main.yml
│   ├── cron_dbsXX
│   │   ├── files
│   │   │   ├── backupDumpToRemoteServer.sh
│   │   │   ├── setBackupVariables.sh
│   │   │   └── trdads_backup_dbdump
│   │   └── tasks
│   │       └── main.yml
│   ├── mysql
│   │   ├── files
│   │   │   ├── dbfm01
│   │   │   │   └── my.cnf.dbfm01
│   │   │   ├── dbm01
│   │   │   │   ├── my.cnf.dbm01
│   │   │   │   └── my.cnf.dbs01
│   │   │   ├── dbm02
│   │   │   │   ├── my.cnf.dbm02
│   │   │   │   └── my.cnf.dbs02
│   │   │   ├── dbm03
│   │   │   │   ├── my.cnf.dbm03
│   │   │   │   └── my.cnf.dbs03
│   │   │   └── dbm04
│   │   │       ├── my.cnf.dbm04
│   │   │       └── my.cnf.dbs04
│   │   └── tasks
│   │       └── main.yml
│   └── mysql_app_user
│       ├── files
│       │   └── dbs03
│       │       └── user_info_private.yml
│       └── tasks
│           └── main.yml
├── set_mysql_app_user.yml
└── vars
    ├── dbfm01.yml
    ├── dbm01.yml
    ├── dbm02.yml
    ├── dbm03.yml
    ├── dbm04.yml
    ├── dbs01.yml
    ├── dbs02.yml
    ├── dbs03.yml
    └── dbs04.yml
```

## 前提条件
* dbm02、dbs02は特別負荷のかかるサーバのため、FusionIOを使用している。
* dbs03のHDDは全てSSD。2TBをRAID1+0
	* データのリストアに時間がかかり過ぎるためSSDを使用。
* diskの速度は `100 MB/sec` 出ていないといけない。

## build_db.ymlの使い方
* インベントリの `[add]`に構築対象のホストを記入
* build_db.ymlの `vars:` に対象ホストの変数を定義したファイル(vars/を参照)を追記
* 以下のコマンドでplaybookを実行

```
ansible-playbook build.yml -i inventory/production
```

* Playbookでレプリケーションの定義は行なっていない。
* 下記のplaybookでlinuxユーザーとdbユーザーの登録を行う。
  - operation/create_users.yml
  - operation/create_dbusers.yml

## set_mysql_app_user.ymlの使い方
* 処理概要
  - サーバ固有のアプリケーションで使っているmysqlのアカウント設定を行う
  - アプリケーションで使っているアカウント情報が追加される際は、`roles/mysql_app_user/files/`の各サーバの設定ファイルに、アカウント情報を残しておく。

* 注意事項
  - 同じDBでもmasterとslaveで登録されているユーザーは異なる。
  - セブエンジニアの各ユーザーアカウントはこちらでは管理せず、[operation/create_dbusers](https://github.com/FullSpeedInc/admatrix_devops/tree/master/operation#create-db-users) で行う。
  - DBのアカウント情報が記されているファイルは、必ず`ansible-vault`で暗号化してからgit commitすること。
  - また暗号化させる際のパスワードはいつもの
  - dbs03に関しては、`MySQL_python`がインストールできなかったため、ansibleからは設定が行えない
  - 複合化する場合は以下のコマンドで行う。

  ```
  ■ansibleユーザでパスワードファイル格納先へ移動
  cd db/roles/mysql_app_user/files/dbs03/
  
  ■パスワードファイルを作成
  echo sysdev > vault_password
  
  ■複合化を実施
  ansible-vault decrypt user_info_private.yml --vault-password-file vault_password
  ```

* 事前確認事項
  - 実行対象のインベントリを確認
  - set_mysql_app_user.ymlにmysqlのログインパスワードを記入
 
  ```
  vars:
    LOGIN_PASS:
  ```
 
  - また実行対象のアカウント情報が管理されているファイルのパスを設定

  ```
  #e.g.dbs03に対してアカウント設定を行う場合
  vars_files:
    - ./roles/mysql_app_user/files/dbs03/user_info_private.yml
  ```

* 実作業
  - 以下のコマンドを実行
  ```
  ansible-playbook set_mysql_app_user.yml -i inventory/production --ask-vault-pass
  ```

## データリストア時のTips
* SSDを使っていても半日以上時間がかかる。
* 各masterのmysqlの `expire_logs_days=7`に設定されているため、リストアに7日以上かかることがあれば同期が不可能になる。
* slaveをリストアする時、dump時点でバイナリログの位置が記録されているため、リストアが終わったら以下のコマンドを実行するだけで良い。

```
# 解凍したdumpファイルの冒頭部分
CHANGE MASTER TO MASTER_HOST='192.168.134.72', MASTER_PORT='3306', MASTER_LOG_FILE='XXX', MASTER_LOG_POS=XXX;

start slave;
```

## 参考リンク
* [Ansible-Vaultを用いた機密情報の暗号化のTips](https://qiita.com/takuya599/items/2420fb286318c4279a02)