## toc
- [注意事項](#注意事項)
	- [前提条件](#前提条件)
	- [開発側との役割分担](#開発側との役割分担)
	- [playbookの作成・利用にあたってのルール](#playbookの作成・利用にあたってのルール)
	- [playbookの実行](#playbookの実行)
	- [playbookの管理](#playbookの管理)
	- [playbookの更新](#playbookの更新)
	- [容量の大きいfiles/はgitignoreさせる](#容量の大きいfiles/はgitignoreさせる)
- [ADMATRIX DSPサーバの情報](#ADMATRIX DSPサーバの情報)
- [新規サーバ構築時の設定](#新規サーバ構築時の設定)
    - [ansibleユーザの作成](#ansibleユーザの作成)
    - [managementサーバの公開鍵受け渡し](#managementサーバの公開鍵受け渡し)
    - [ansibleで疎通確認](#ansibleで疎通確認)

## 注意事項
### 前提条件
* ディレクトリ構成
	* ADMATRIX DSPの`各ホスト名`と対応している。
		* 例：dapiXXサーバのplaybookは `dapi`ディレクトリ以下
	* 一部例外があるので、注意すること。
		* （例）`dsp_admin`：管理画面系（dadmin01など）のplaybookを格納
		* （例）`hadoop`：namenodeやdatanodeのplaybookを格納
* トップレベルのフォルダ構成

```
.
├── README.md
├── all_hosts
├── api
├── batch
├── bidresult
├── build
├── cbatch
├── common_build
├── dapi
├── dash
├── datadog   # セブのエンジニア管轄の領域（ただし、更新・実行を請け負う）
├── db
├── dbatch
├── dsp_admin   # 管理画面系のplaybook（サーバは1台以外ubuntu）
├── hadoop
├── hbase
├── iapi
├── img
├── kudu_tablet
├── kvs
├── lvs   # 構築時のみ使用
├── maintenance   # セブのエンジニア管轄の領域（使用状況を確認し、未使用の場合は削除してOK）
├── mongo
├── operation   # linux、MySQLアカウント作成、hosts更新など、サーバ種別に寄らない運用タスク用の管理領域
├── relay
├── stg
├── tapi
├── tbl
└── util
```

### 開発側との役割分担
* `責任分界点`について、協議・整理を実施したので、以下のJIRAチケットを参照すること。
	* [JIRAチケット：【構成管理改善】サーバ構築の責任分界点明確化](https://fullspeed.atlassian.net/browse/DOTB-70)
* 今後、サーバ構築・リプレースを行う際に**事前に役割分担のすり合わせ**を行い、役割・責任範囲の認識齟齬をなくすようにする。
* インフラテクノロジー開発部の掌握は以下の作業。
	* **機器セットアップ 〜 MWインストール**
	* **MWの設定（既存のサーバ）**
* インフラテクノロジー開発部のリソースが足りない場合、作業手順を引き継いで開発側に権限を移譲する事も可能。
	* ただし、データセンターでの作業必須のものはインフラテクノロジー開発部が責任を持って対応する
* Ansible Playbookでの構成管理も不十分である。開発側と協力して、構成管理の課題を解決していくこと。

### playbook作成・利用にあたって
### 注意事項
* fullspeedリポジトリの`apache-tomcat-8.0.26-0.x86_64.rpm`が破損している可能性があり、**Playbookでapache-tomcatのインストールができない状態となっている。**
	* yumによるインストールもできない
* サーバ構築を行う場合は既存サーバの`/usr/local/tomcat`をコピーするか、以下に格納したbidresult01のtomcatディレクトリを展開することで回避する。
	* [bidresult01のtomcat.tar.gz](https://drive.google.com/file/d/18b_GwCqUe897C1hzTDGj9v9jVUax_RKX/view?usp=sharing)

#### Playbook作成ルール
* `common_build`ディレクトリ内はjavaやnginxのインストール、nasへのマウントなど、よく行われる処理を共通化したもの。
	* 新たにplaybookを作る時はむやみに新しい処理を書いたり、他ディレクトリからコピペしない
	* できるだけ`common_build/roles`から引用するようにする
* playbook内で処理の分岐を作成しない。
	* シンプルな処理でplaybookを作成することで、第三者にもわかりやすい構成とする
* `build.yml`内に極力、処理を直接定義しない。
	* `roles`を作成することで、他の処理で再利用を可能とする
* SSL証明書更新用Playbookは**1ドメイン1YAML**で作成する。
	* 2018年に管理単位について検討を行い、疎結合で作成することとした
	* [JIRAチケット：tapi06リプレイス](https://fullspeed.atlassian.net/browse/SITB-828)

#### Playbook利用ルール
* 原則として、lvsへのansibleによるアクセスは制限している。  
	* 本番のLoadBalancerであり、万が一ミスがあるとサービス全断のリスクがある為
* lvs05〜08はansibleで構築しているので、以下の設定をすればアクセス可能。
	* 通常時はansibleユーザの`~/.ssh/config`で制限をかけているので、ansibleで作業をする際には修正が必要

### playbookの実行
* リポジトリ情報
	* `ansible@management:/home/ansible/`
* playbook作成・更新時のコミットメッセージ
	* [コミットメッセージについているpreifxに関して](https://qiita.com/numanomanu/items/45dd285b286a1f7280ed)
* 実行時のTips
	* [ナレッジベース](https://github.com/FullSpeedInc/admatrix_docs_infrastructure/blob/master/construction/README.md)を参照すること。

### playbookの管理
* 容量の大きいfilesは`gitignore`を行う。
	* Githubのファイルサイズ制限に抵触する為　

	```
	#例

	#role/で実行
	$ vi .gitignore

	#.gitignore
	#全てのカレントディレクトリの下にあるfilesディレクトリの中身を無視する。

	*/files/
	```

* Githubは**空のディレクトリを管理下に置かない**ので、注意すること。

### playbookの更新
* Playbookレビュー方針

<img width="1000" src="https://user-images.githubusercontent.com/42759293/82845416-6ecdb900-9f1f-11ea-92db-93042beb5f87.png">

* 上記の通り、原則として、**追加の場合はレビュー不要**。
	* ただし、**READMEの追加**と**テストでエラーが0件**になっていることが条件
* 修正 / 削除の場合、**プルリクエストを作成し、チーム内でレビューを行う**こと。
	* 稼働中の本番サーバに対する処理が可能な為、相互チェックを行う必要がある
* ただし、**配布用のhostsファイルの更新**など、簡易的な更新、かつ、急ぎの者は直接更新を行っても問題ない。
	* **本番環境への影響があるものなので、十分に注意して作業を行うこと**
* Githubの内容更新後、managementサーバへログインし、`ansibleユーザ`で以下のコマンドを実行することで、managementサーバに最新情報を取り込む。

```
git pull origin master
※パスワードはいつもの
```

## ADMATRIX DSPサーバの情報
### サーバ管理表
* [ADMATRIX DSPサーバ管理表](https://drive.google.com/open?id=1_QDOBbEWQmiq7XGLGlmjeRGNz9kpuLWRoeUeYZkj7Gs)
	* サーバのHW・SWスペック、サービスイン時期などを一覧化している資料

### IPアドレス一覧表
* [IPアドレス一覧表](https://drive.google.com/open?id=1FJvOVzuoK5SI-UbZ9rFz-vOr3hGMbmqGpEF0D8G_h54)
	* IPアドレスと対応するホストを一覧化した資料

## 新規サーバ構築時の設定
### ansibleユーザの作成
* 構築対象サーバにansibleユーザを作成する。

```
adduser ansible
```

* ansibleユーザをsudoできるように設定する。

```
visudo

# visudo内に追記
ansible ALL=(ALL)   NOPASSWD: ALL
```

### managementサーバの公開鍵受け渡し
* managementサーバの公開鍵をコピーする。

```
[ansible@management ~]$ cat ~/.ssh/to_ansible_client.pub
```

* 追加するサーバ内にsshし、キーファイルを設置する。

```
mkdir -p /home/ansible/.ssh
vi /home/ansible/.ssh/authorized_keys
# 先ほどの公開鍵をコピペする

chmod -R 700 /home/ansible/.ssh
chmod 600 /home/ansible/.ssh/authorized_keys
chown -R ansible. /home/ansible/.ssh
```

* managementサーバのconfigにサーバ種別の設定を追記する。
	* 基本的に増設やリプレースであれば、作業不要

```
[ansible@management ~]$ vi ~/.ssh/config

host dapi*    # 該当するファイル名を書く。dapi01,02,03~などは全て*で含められる
StrictHostKeyChecking no
IdentityFile ~/.ssh/to_ansible_client    # 秘密鍵を指定
```

### ansibleで疎通確認
* 対象playbookのインベントリに、追加したサーバのホストを追記する。

```
# 例：hadoop
[ansible@management hadoop]$ vi inventories/production
[add]
dn35 # 追加したホストを記入
```

* 以下のコマンドを実行し、`ping`、`pong`が返却されることを確認。

```
[ansible@management hadoop]$ ansible -i inventories/production dn35 -m ping
dn35 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```