## toc
* [全体概要](#全体概要)
* [事前準備](#事前準備)
* [構築手順](#構築手順)

## 全体概要
* ディレクトリ構造とプログラム一覧
	* トップディレクトリ
		* `/home/ansible/iapi`

```
.
├── README.md
├── build.yml
├── build_centos7.yml
├── inventory
│   └── hosts
├── roles
│   └── iapi
│       ├── files
│       │   └── sysops
│       └── tasks
│           └── main.yml
└── vars
    └── nginx.yml
```

## 構築手順
* inventoryファイルの [add] グループ内に対象サーバを記入。
* 以下のコマンドを実行
```
ansible-playbook build.yml -i inventory/hosts
```
* 下記のplaybookでlinuxユーザーの登録を行う
	* operation/create_users.yml