## toc
* [全体概要](#全体概要)
* [前提条件](#前提条件)
* [事前準備](#事前準備)
* [（作成中）build.ymlの使い方](#（作成中）build.ymlの使い方)
* [update_ssl_admatrix.jp.ymlの使い方](#update_ssl_admatrix.jp.ymlの使い方)

## 全体概要
* ディレクトリ構造とプログラム一覧
	* トップディレクトリ
		* `/home/ansible/capi`

```
.
├── README.md
├── inventory
│   └── hosts
└── update_ssl_admatrix.jp.yml
```

* lvsの設定
	* `lvs01 / lvs02`
		* `192.168.134系`のIPアドレスを付与
* 稼働しているドメイン
	* `eventd-cro.admatrix.jp`

## 事前準備
* ansibleユーザーの作成
* ansibleユーザーにmanagementサーバーのSSH鍵の登録
* `/home/ansible/img/roles/ssl/files`に必要な証明書と鍵の格納
	* 対象はt-admatrix.jp
	* ファイル名は証明書名＋`to`以降に証明書の有効期限を`YYYYMMDD`で設定
      （例）`t.admatrix.jp.to20191118`

## （作成中）build.ymlの使い方
* 前提条件
	* **今後、capiサーバは役割がなくなる可能性があることから、積極的なAnsible Playbookの適用は行わない**
* はじめに
	* 処理順序
		* `build.yml`から以下の順番で`roles`を呼び出す
			* `../common_build/roles/common`
			* `../common_build/roles/nginx`
				* 上記処理中にSSL証明書の配置まで行う
			* `capi`
			* `../common_build/roles/mount`
* 注意事項
	* `/home/ansible/capi`に移動してからplaybookを実行すること
* 処理概要
	* capiサーバを構築する
* 事前確認事項
	* `inventory/hosts`の[add]グループ内に構築対象のhostsを追記
* 実作業
	* 以下のplaybookを実行

		```
		ansible-playbook build.yml -i inventory/hosts
		```

## update_ssl_admatrix.jp.ymlの使い方
* はじめに
	* 処理概要
		1. 対象のサーバーをlvsから外す
       2. （手動で）lvs01 / lvs02で対象のサーバがlvsから外れたかを確認する
       3. 新しい証明書を更新し、正しく更新されているかを確認する
       4. nginxを再起動し、lvsへ組み込む
       5. （手動で）lvs01 / lvs02で対象のサーバがlvsへ組み込まれたことを確認する
    * プログラムの関連性
		* `update_ssl_admatrix.jp.yml`から以下の順番で`roles`を呼び出す
			* `../common_build/roles/ssl_admatrix.jp`
				* `common_build`領域で共通化された処理
* 注意事項
	* **1部更新したら新しい証明書がきちんと更新されているかを確認してから全台行う。また全台の更新は月末月初は避ける**
	* `/home/ansible/img`に移動してからplaybookを実行すること
* 処理概要
	* admatrix.jpのSSL証明書を更新する
* 事前確認事項
	* `inventory/hosts`の[target]グループ内に構築対象のhostsを追記
	* 事前に鍵を解除しておく
		* `openssl sha1 xxx.key`を実行して、値が表示されるか確認する
	* 証明書ファイルをmanagementサーバに配置
	* imgは本番稼働しているので、サービスに影響が出ないように1台ずつ定義する

        ```
        [target]
        capi01
        ```

* 実作業
	* dsp_infraチャンネルにSSL証明書更新作業を広報する

    ```
    @here
    【作業広報】capi01-02のSSL証明書更新（*.admatrix.jp）
    以下の日時で表題の作業を行いますので、ご認識ください。

    日時 ： MM/DD（x）hh:mm - hh:mm
    対象 ： capi01-02のSSL証明書（*.admatrix.jp）
    ```

    * 以下のコマンドでplaybookを実行する

	```
    サービス稼働中のため一つずつ行う。
    #lvsへ外す
    ansible-playbook -i inventory/hosts update_ssl_admatrix.jp.yml --tags remove

    #lvs01から `ipvsadm -L`で外れていることを確認する

    #無事外されたのが確認できたら、新しい証明書一式をコピー
    ansible-playbook -i inventory/hosts update_ssl_admatrix.jp.yml --tags setting

    #証明書の確認ができたら、以下のコマンドでnginxの再起動。
    #nginxの定義が正しいことを確認し、無事再起動した時lvsに戻すようになっている
    ansible-playbook -i inventory/hosts update_ssl_admatrix.jp.yml --tags add

    #lvs01系から `ipvsadm -L`でインされていることを確認する
    ```

    * インベントリファイルの対象ホストを次のサーバに変えて、全台完了するまでplaybookを実行する
    * 全台作業が完了したら、dsp_infraチャンネルに完了広報を行う。

    ```
    【作業完了広報】capi01-02のSSL証明書更新（*.admatrix.jp）
    以下の作業が完了しましたので、ご連絡します。

    https://fullspeed.slack.com/archives/C1PFEEAGY/p1536026499000100
    ```