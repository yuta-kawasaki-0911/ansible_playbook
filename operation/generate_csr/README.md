## ssl証明書用のプライベートキーとcsrの作成方法
```
$ ansible-playbook generate_***_csr.yml
```
`generate_***_csr.yml`: 該当のドメインのファイルを指定する。

csrの作成はローカルで行うため、インベントリは指定しなくてよい。(警告は出る)

* `created_files/`以下にprivatekeyとcsr証明書が作成される。

## 設定ファイルの作成方法

既存の実行ファイルをコピペして、必要に応じて設定値を変える。

* 実行ファイル名は `generate_[[対象のドメイン名]]_csr.yml` にする。
* target_domain: 対象ドメインを指定する

その他privatekeyの暗号アルゴリズムやcsrのコモンネームなど、必要に応じてオプションの値を変更する。

* 参考
  - [openssl_privatekey](http://docs.ansible.com/ansible/latest/modules/openssl_privatekey_module.html)
  - [openssl_csr](https://docs.ansible.com/ansible/2.4/openssl_csr_module.html)



