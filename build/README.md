## toc
* [全体概要](#全体概要)
* [connect_with_ssh.yml について](#connect_with_ssh.yml について)
* [備考](#備考)

## 全体概要
* ディレクトリ構造とプログラム一覧
	* トップディレクトリ
		* `/home/ansible/build`

```
.
├── README.md
├── connect_with_ssh.yml
├── inventory
│   └── hosts
└── roles
    └── connect_with_ssh
        ├── files
        │   └── tomcat
        └── tasks
            └── main.yml
```

## connect_with_ssh.yml について

* 処理概要
  - 開発側のjenkinsサーバから、hadoopのnamenode, hbaseのmasternodeに対して実行させるようにするため、tomcatユーザーの作成とssh接続を行う。(hadoop,hbaseにtomcatはinstallされていないが、開発側の都合上作業ユーザーがtomcatになっているようなのでそこに合わせる形になった)

* 事前確認事項
  - hostsファイルの実行対象を確認。

* 実作業
  ```
  ansible-playbook connect_with_ssh.yml  -i hosts
  ```

## 備考
### 各サーバのtomcatユーザーの役割
* jenkinsから各サーバへのスクリプトの実行は、各サーバに設定されたtomcatユーザーを通しておこなっている。
* その為、**tomcatのインストールされていないサーバでもjenkinsから処理を実行させるためにtomcatユーザーを作成していることがある**。（nnやnhmnなど）
* またtomcatユーザーは**パスなしでsudoが行える設定**をしてある。
	* `公開鍵認証方式`を採用している