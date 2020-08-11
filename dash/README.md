## toc
* [全体概要](#全体概要)
* [概要](#概要)

## 全体概要
* ディレクトリ構造とプログラム一覧
	* トップディレクトリ
		* `/home/ansible/dash`

```
.
├── README.md
└── roles
    └── apache_tomcat
        └── files
            ├── catalina.policy
            ├── catalina.properties
            ├── context.xml
            ├── logging.properties
            ├── server.xml
            ├── tomcat-users.xml
            ├── tomcat-users.xsd
            └── web.xml
```

## 概要
* ログインURL
	* `http://dash01.admatrix.jp/loginForm`
* 用途
	* パフォーマンスモニターでレポートを出力するときに使われる。
* 利用者
	* リサーチ
	* 運用
		* 使われる頻度は不定期だが、利用されている
* 利用範囲
	* 社内のみ
* 接続先データベース
	* `dbs02`