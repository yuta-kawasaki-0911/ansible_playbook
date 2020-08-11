# VPNアカウント大量作成手順
## 前提
* VPNアカウントはまとめて作成を行うことから、あまり使う機会は無いのでansible化はせず、手順と使用したスクリプトだけ残す。

## 手順
* 作成するアカウントの数だけパスワードファイルを用意する

```
macで以下を実行
$ pwgen -s 8 100 | xargs -n1 > clients_pass.txt
```

* clientXXの数字とパスワードの行数を対応させておく。
	* 例えばclient101~199まで作成するとしたら、clients_pass.txtのパスワードを101~199行目になるように調整
	* 後ほどsedコマンドで行数に対応したパスワードを取得するようにしているため
* パスワードの中に**「[」**や**「"」**が入るとシェルスクリプトがエラーとなるので、注意すること。

* vpn01サーバへログインし、以下のディレクトリへ移動する。

```
$ cd /etc/openvpn/easy-rsa
```

* 以下の2ファイルを配置する。
  - 先ほど生成した`clients_pass.txt`
  - 証明書を生成する`create_client_files.sh`
  	- 詳細は後述

```
■create_client_files.sh

#!/bin/bash

for var in {101..199} #client101~199まで作る時
do
  pass=`sed -n ${var}p /etc/openvpn/easy-rsa/clients_pass.txt`
  expect -c "
  spawn /etc/openvpn/easy-rsa/pkitool --pass client$var
  expect \"Enter PEM pass phrase:\"
  send \"${pass}\n\"
  expect \"Verifying - Enter PEM pass phrase:\"
  send \"${pass}\n\"
  interact
  "
  mkdir -p /tmp/users_dir/client$var
  cp keys/client$var.crt /tmp/users_dir/client$var/client$var.crt
  cp keys/client$var.key /tmp/users_dir/client$var/client$var.key
  echo $pass > /tmp/users_dir/client$var/client$var.cfg
  cp ../ca.crt /tmp/users_dir/client$var/ca.crt
  cp ../ta.key /tmp/users_dir/client$var/ta.key
done
```

* 以下の手順でスクリプトをを実行。
```
$ source var
$ ./create_client_files.sh
```

* `/tmp/users_dir/`配下に作成された`clientXXファイル`をGoogleドライブの所定領域へ格納する。