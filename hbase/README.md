## toc
* [全体概要](#全体概要)
* [事前準備](#事前準備)
* [cebu用playbookについて](#cebu用playbookについて)
* [set_app_user.ymlについて](#set_app_user)

## 全体概要
* ディレクトリ構造とプログラム一覧
	* トップディレクトリ
		* `/home/ansible/dapi`

```
.
├── README.md
├── build_nhcm.yml
├── build_nhcm_cebu.yml
├── build_nhmn.yml
├── build_nhmn_cebu.yml
├── build_nhsn.yml
├── build_nhsn_cebu.yml
├── hosts
├── hosts_cebu
├── inventory
│   └── hosts
├── roles
│   ├── cluster_common
│   │   └── tasks
│   │       └── main.yml
│   ├── cm_5.14
│   │   ├── files
│   │   │   └── cloudera-manager.repo
│   │   └── tasks
│   │       └── main.yml
│   ├── hsn
│   │   ├── files
│   │   │   └── sysops
│   │   └── tasks
│   │       └── main.yml
│   └── mysql_connector_java
│       └── tasks
│           └── main.yml
└── set_app_user.yml
```

## 事前準備
* batch01,03のid_rsa.pubをsysops@hsn:~/.ssh/authorized_keys に登録しておく
* sysopsユーザを作成する

## cebu用playbookについて
### 前提
* このplaybookは自身の手元の環境で実行する前提で作られている
* 経緯としては、セブのcmanagementにリポジトリを配置しようとしたらDLが遅すぎて断念したため。
* またfsリポジトリがセブ環境からだとアクセスできないため、fsリポジトリを使わず共通設定を行うroleを使用している。

### 利用方法
#### 準備
* hostsファイルを最新のものに反映させる。
	* ファイルを配置
		* path: `../common_build/roles/common_cebu/files/hosts_YYYYMMDD`
		* `YYYYMMDD`には最後に反映させた年月日が入る
	* 変数の中にファイル名を定義
		* 各build_***_cebu.ymlの `vars: hosts_file` に上記に配置したファイル名を反映させる。

#### 構築
* 実行コマンド

```
ansible-playbook -i hosts_cebu build_nshcm_cebu.yml --ask-pass
```

## set_app_user.ymlについて
### 前提
* sysopsなどのアプリケーションユーザーの設定を行う

### 利用方法
* 実行コマンド

```
ansible-playbook set_app_user.yml -i hosts 
```

* batch01,03のtomcatユーザーのid_rsa.pubを貼り付けておく
