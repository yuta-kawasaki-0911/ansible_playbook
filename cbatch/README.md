## toc
* [全体概要](#全体概要)
* [前提条件](#前提条件)

## 全体概要
* ディレクトリ構造とプログラム一覧
	* トップディレクトリ
		* `/home/ansible/cbatch`

```
.
├── README.md
├── build.yml
├── hosts
└── roles
    └── cbatch
        ├── files
        │   └── backup_cbatch.sh
        └── tasks
            └── main.yml
```

## 前提条件
### 概要
* cbatch01: dsp最適化関係のバッチ処理が稼働している。
	* **redis、hadoopどちらでも使えるバッチサーバ**がコンセプト
	* batchXXはredisが使用不可、dbatchXXはHadoopが使用不可
* kvs_clean: redisのkeyを削除するバッチ処理が稼働している。
	* 実際に削除するjobだけ01と02両方で稼働している
	* またこのために各kvsサーバからのdumpをcbatch01に転送している
* cbatch02: cbatch01のコールドスタンバイ。