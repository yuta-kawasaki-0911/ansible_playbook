# authorized_keysファイルの管理

## 管理対象を追加する時

1. hostsに対象サーバを記入
* グループ名の命名規則
  - サーバが一つの時：ホストと数字の間に"_"を入れる。(※ホスト名とグループ名を同じにするとwarningが出るため) 例)bidresult_01
  - サーバが冗長化されている時：ホスト名から数字を抜いたもの 例)dapi

2. 管理対象のauthorized_keysファイルを設定する

`rsync -av [[管理対象のauthファイルのパス]]　./roles/copy_file/files/[[グループ名]]_authorized_keys`　

3. group_vars/にパラメータファイルを作成
* ファイル名は"グループ名.yml"にする
* 設定項目
```
user: tomcat  # copy先のパスと、ファイルのユーザ/グループに設定される
authorized_keys_file: [[グループ名]]_authorized_keys # 手順2で作成したファイル名
```

## ansible管理下のauthorized_keysファイルを本番サーバに反映させる時

* インベントリの中から対象グループ名を以下の場所に記入
```
$ vim set_authorized_key.yml

---
- hosts: [[グループ名]]
```

* playbookを実行

※ `--check`オプションを付けて挙動を確認した方が良い

`$ ansible-playbook set_authorized_key.yml -i hosts`

copyモジュールによってfiles/以下の該当のファイルが本番ディレクトリの方に置き換えられる。
