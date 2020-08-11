## 注意事項
* **サービス全体の可動（ロードバランシング）に関わる重要なサーバなので、通常はAnsibleから接続できないようになっている**
* **アクセス制限を解除することで一部Ansibleで接続可能となる。**
	* `lvs05 - lvs08` / `sgwXX`が接続可能

## toc
* [全体概要](#全体概要)
* [前提条件](#前提条件)
* [事前準備](#事前準備)
* [lvs構築playbookの説明](#lvs構築playbookの説明)
* [事後作業](#事後作業)

## 全体概要
* ディレクトリ構造とプログラム一覧
	* トップディレクトリ
		* `/home/ansible/lvs`

```
.
├── README.md
├── build_3pas.yml
├── build_dsp.yml
├── build_sgw.yml
├── give_config_files.conf
├── inventory
│   └── hosts
└── roles
    ├── keepalived
    │   ├── files
    │   │   ├── ipvsadm-1.26-2.el6.x86_64.rpm
    │   │   ├── keepalived-1.2.7-3.el6.x86_64.rpm
    │   │   ├── keepalived_3pas.conf
    │   │   ├── keepalived_3pas0102.conf
    │   │   ├── keepalived_3pas0708.conf
    │   │   ├── keepalived_dsp.conf20180820.conf
    │   │   ├── keepalived_dsp0304.conf
    │   │   └── keepalived_dsp0506.conf
    │   └── tasks
    │       └── main.yml
    └── lvs
        ├── files
        │   ├── CentOS6.5_sysctl.conf
        │   ├── CentOS6.6_sysctl.conf
        │   ├── CentOS6.7_sysctl.conf
        │   ├── hosts.allow
        │   ├── hosts.deny
        │   └── rc.local
        └── tasks
            └── main.yml
```

## 前提条件 
* dsp lvs(lvs03,04)はネットワークボンディングでnicを冗長化している。

## 事前準備
* ansibleユーザーの作成
* ansibleユーザーにmanagementサーバーのSSH鍵の登録
* managementサーバの`~/.ssh/config`に構築対象を追加
	* 設定ミスによる事故を防ぐ為、原則使用を制限する
* keepalived.confを環境に合わせて作成
	* playbookの中で配置を行うのは以下のどちらか
		* `keepalived_3pas.conf` 
		* `keepalived_dsp.conf`
	* 構築するサーバ名のものをコピーして、リネームする
		* 例：lvs01を構築する場合、`keepalived_3pas0102.conf`をコピーして、`keepalived_3pas.conf`とする

## lvs構築playbookの説明
* `inventory/hosts`ファイルの `[add]`グループ以下に、構築対象のサーバのホストを記入。
* 以下のコマンドを実行。

```
$ ansible-playbook build_[[サービス名]].yml -i inventory/hosts

lvs01,02,07,08(192.168.134.~)　→　build_3pas.yml
lvs03,04,05,06(192.168.199.~)　→　build_dsp.yml
```

* playbookはkeepalivedの起動までは行わない。
	* 移行作業が完了するまで、起動しないこと

## 事後作業
### iptables IPマスカレードのREDIRECT設定
* playbookの中身が`lvs01 / lvs02` or `lvs03 / lvs04`の設定となっているので、新しく構築する内部VIPに修正すること。
	* `/etc/sysconfig/iptables`を修正
	* `iptables-restore < /etc/sysconfig/iptables`を実行