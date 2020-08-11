## toc
* [全体概要](#全体概要)
* [事前準備](#事前準備)
* [構築手順](#構築手順)

## 全体概要
* ディレクトリ構造とプログラム一覧
	* トップディレクトリ
		* `/home/ansible/hadoop`

```
.
├── README.md
├── files
│   └── yarn-site.xml
├── install_omsa.yml
├── inventories
│   ├── production
│   └── staging
├── playbook
│   ├── build_dn.yml
│   ├── build_nn.yml
│   ├── build_nn03.yml
│   ├── create_dn_directory.yml
│   ├── files
│   │   └── tmp_repo.repo
│   ├── give_hosts.yml
│   ├── give_repo.yml
│   ├── group_vars
│   │   ├── prod_add
│   │   └── stg_add
│   ├── install_irqbalance.yml
│   ├── parted_disks.yml
│   ├── replace_settingfile.yml
│   └── start_dn.yml
└── roles
    ├── build_dn
    │   ├── files
    │   │   ├── cloudera-cdh5.repo
    │   │   ├── cloudera-gplextras5.repo
    │   │   ├── prod
    │   │   │   ├── hdfs-site.xml
    │   │   │   ├── mapred-site.xml
    │   │   │   └── yarn-site.xml
    │   │   └── stg
    │   │       ├── hdfs-site.xml
    │   │       ├── mapred-site.xml
    │   │       └── yarn-site.xml
    │   └── tasks
    │       ├── create_directory.yml
    │       └── main.yml
    ├── build_jobhistory
    │   ├── files
    │   │   ├── hdfs-site.xml
    │   │   ├── mapred-site.xml
    │   │   └── yarn-site.xml
    │   └── tasks
    │       └── main.yml
    ├── build_nn
    │   ├── files
    │   │   ├── dfs_hosts_allow.txt
    │   │   ├── fair-scheduler.xml
    │   │   ├── jobhistory
    │   │   │   ├── hdfs-site.xml
    │   │   │   ├── mapred-site.xml
    │   │   │   └── yarn-site.xml
    │   │   ├── mapred-site.xml
    │   │   └── zoo.cnf
    │   ├── handlers
    │   │   └── main.yml
    │   ├── tasks
    │   │   └── main.yml
    │   └── templates
    │       ├── hdfs-site.xml.j2
    │       └── yarn-site.xml.j2
    ├── common_build
    │   ├── files
    │   │   ├── cloudera-cdh5.repo
    │   │   ├── cloudera-gplextras5.repo
    │   │   ├── hosts
    │   │   ├── prod
    │   │   │   ├── core-site.xml
    │   │   │   ├── hadoop-env.sh
    │   │   │   └── yarn-env.sh
    │   │   └── stg
    │   │       ├── core-site.xml
    │   │       ├── hadoop-env.sh
    │   │       └── yarn-env.sh
    │   └── tasks
    │       ├── CDH_yum_conf.yml
    │       ├── Hd_karnel_conf.yml
    │       ├── create_conf.yml
    │       ├── create_link_slf4j-log4j12jar.yml
    │       ├── create_user.yml
    │       ├── give_conf_files.yml
    │       └── install_middlewares.yml
    ├── create_dn_directory
    │   ├── files
    │   │   ├── cloudera-cdh5.repo
    │   │   ├── cloudera-gplextras5.repo
    │   │   ├── prod
    │   │   │   ├── hdfs-site.xml
    │   │   │   ├── mapred-site.xml
    │   │   │   └── yarn-site.xml
    │   │   └── stg
    │   │       ├── hdfs-site.xml
    │   │       ├── mapred-site.xml
    │   │       └── yarn-site.xml
    │   └── tasks
    │       ├── create_directory.yml
    │       └── main.yml
    └── parted_disks
        └── tasks
            └── main.yml
```

## 事前準備
* ansibleユーザーの作成
* ansibleユーザーにmanagementサーバーのSSH鍵の登録

## 構築手順
### parted_disks.yml
* inventory/hostsの[partition]に対象のホストを記入

```
[partition]
dn35
```

* 以下のコマンドでplaybookを実行

```
ansible-playbook parted_disks.yml -i inventory/production
```

* formatの処理は3時間くらいかかるため、playbook終了まで時間がかかる

### hosts配布
* 以下のhostsファイルに新サーバのipを追加しておく
	* managementサーバの~/admatrix_infra_configfiles/hosts
		* githubのadmatrix_infra_configfilesリポジトリで管理
	* managementサーバの/etc/hosts

* hadoop全台のhostsファイルを更新する
	* インベントリに新しいサーバを追加する。

```
cd ~/hadoop
vi inventories/production
```

* playbookを実行

```
ansible-playbook playbook/give_hosts.yml -i inventories/production
```

### build_dn.yml
* インベントリのaddグループに対象サーバのhostsを追記

```
vi ~/hadoop/inventories/production

[add]
#ここに構築対象のホストを記入
```

* 以下のコマンドでplaybookを実行する。
	* `ansible-playbook playbook/build_dn.yml -i inventories/production`

* *Tips*
	* `ansible-playbook playbook/build_dn.yml -i inventories/production --start-at-task='[[タスクname]]'`
	* そのタスクからstartすることができる

### dn起動
* 以下のコマンドでdatanodeを起動する。
	* `/etc/init.d/hadoop-hdfs-datanode start`
* エラーが出ていないかログを確認する。
	* `tail -f /var/log/hadoop-hdfs/hadoop-hdfs-datanode-dn**.3pas.admatrix.jp.log`
	* ※dn**に対象のホストidを入れる
* 余計なプロセスが入っていないか確認
	* `sudo jps`

### nnへdnを投入
* nn01,nn02に新dnのipを追加
	* `vi /etc/hadoop/conf/dfs_hosts_allow.txt`
	* ipは必ずしも連番とは限らないので注意。

### nnを止めずに新規dnをクラスタinする
* hadoopクライアントが入っているサーバ(nn01など)で以下を実行
	* `sudo -u hdfs hdfs dfsadmin -refreshNodes`
* 確認
	* `sudo -u hdfs hdfs dfsadmin -report`
* 新DNが "Live datanodes" になっていればHDFSのクラスタに参加できている
* *ブラウザからも確認できる*
	* `http://192.168.134.111:50070/dfshealth.html#tab-overview (nn01)`
	* 「datanode」タブをクリックし、新dnのhostsが正常に動いているか確認する

### resource managerへ新node managerを投入
* nn01,nn02の以下のファイルに新dnのipを追加
	* `vi /etc/hadoop/conf/mapred_hosts_allow.txt`
* 対象dnでyarnを起動
	* `/etc/init.d/hadoop-yarn-nodemanager start`
* ログを確認
	* `tail -f /var/log/hadoop-yarn/yarn-yarn-resourcemanager-dn**.3pas.admatrix.jp.log`
	* ※dn**に対象のホストを入れる
* rmを起動させたまま新nmを認識させる。hadoopクライアントが入っているサーバ(nn01など)で以下を実行
	* `sudo -u yarn yarn rmadmin -refreshNodes`
* 以下のurlを開き、新dnのNode Statusが「RUNNING」になっていることを確認する
	* `http://192.168.134.111:23188/cluster/nodes`

### 作業完了後
* inventory/productionの[add]グループからホストを削除しておく。
