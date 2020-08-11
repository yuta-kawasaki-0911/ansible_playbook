## toc
* [本領域の位置付け](#本領域の位置付け)
* [playbookの書き方に関して追記](#playbookの書き方に関して追記)
* [roles/nginxについて](#roles/nginxについて)
* [roles/mountについて](#roles/mountについて)
* [roles/ssl_XXXについて](#roles/ssl_XXXについて)
* [api/vars/mount.ymlについて](#api/vars/mount.ymlについて)

## 本領域の位置付け
* 各サーバの構築作業において、共通的に使用可能なplaybookを管理する。
	* 例：`apache` / `tomcat` / `nginx` / `java` / `mount` など

```
common_build
├── README.md
├── build.yml
├── inventory
│   ├── hosts
│   └── hosts.bk2
└── roles
    ├── README.md
    ├── common
    │   ├── files
    │   │   ├── centos6.3
    │   │   │   ├── CentOS-Base.repo
    │   │   │   └── CentOS-Vault.repo
    │   │   ├── centos6.4
    │   │   │   ├── CentOS-Base.repo
    │   │   │   └── CentOS-Vault.repo
    │   │   ├── centos6.5
    │   │   │   ├── CentOS-Base.repo
    │   │   │   └── CentOS-Vault.repo
    │   │   ├── centos6.6
    │   │   │   ├── CentOS-Base.repo
    │   │   │   └── CentOS-Vault.repo
    │   │   ├── centos6.7
    │   │   │   ├── CentOS-Base.repo
    │   │   │   └── CentOS-Vault.repo
    │   │   ├── centos6.8
    │   │   │   ├── CentOS-Base.repo
    │   │   │   └── CentOS-Vault.repo
    │   │   ├── common_sudoers
    │   │   ├── dsp_3pas
    │   │   │   └── fullspeed.repo
    │   │   └── fullspeed.repo
    │   └── tasks
    │       ├── main.yml
    │       └── main2.yml
    ├── common2
    │   ├── files
    │   │   ├── centos6.3
    │   │   ├── centos6.4
    │   │   ├── centos6.5
    │   │   ├── centos6.6
    │   │   ├── centos6.7
    │   │   ├── centos6.8
    │   │   └── dsp_3pas
    │   ├── tasks
    │   │   ├── main.yml
    │   │   ├── main.yml.bak
    │   │   └── main.yml.bk
    │   └── vars
    │       └── main.yml
    ├── common_cebu
    │   ├── files
    │   │   ├── common_sudoers
    │   │   └── hosts_20180906
    │   └── tasks
    │       └── main.yml
    ├── common_centos7
    │   ├── files
    │   │   ├── centos6.3
    │   │   │   ├── CentOS-Base.repo
    │   │   │   └── CentOS-Vault.repo
    │   │   ├── centos6.4
    │   │   │   ├── CentOS-Base.repo
    │   │   │   └── CentOS-Vault.repo
    │   │   ├── centos6.5
    │   │   │   ├── CentOS-Base.repo
    │   │   │   └── CentOS-Vault.repo
    │   │   ├── centos6.6
    │   │   │   ├── CentOS-Base.repo
    │   │   │   └── CentOS-Vault.repo
    │   │   ├── centos6.7
    │   │   │   ├── CentOS-Base.repo
    │   │   │   └── CentOS-Vault.repo
    │   │   ├── centos6.8
    │   │   │   ├── CentOS-Base.repo
    │   │   │   └── CentOS-Vault.repo
    │   │   ├── common_sudoers
    │   │   ├── dsp_3pas
    │   │   │   └── fullspeed.repo
    │   │   └── fullspeed.repo
    │   └── tasks
    │       └── main.yml
    ├── hadoop_client
    │   ├── files
    │   │   ├── conf.class
    │   │   │   ├── capacity-scheduler.xml
    │   │   │   ├── capacity-scheduler.xml.rpmnew
    │   │   │   ├── configuration.xsl
    │   │   │   ├── container-executor.cfg
    │   │   │   ├── core-site.xml
    │   │   │   ├── core-site.xml.rpmsave
    │   │   │   ├── fair-scheduler.xml
    │   │   │   ├── hadoop-env.sh
    │   │   │   ├── hadoop-metrics.properties
    │   │   │   ├── hadoop-metrics2.properties
    │   │   │   ├── hadoop-policy.xml
    │   │   │   ├── hdfs-site.xml
    │   │   │   ├── hdfs-site.xml.rpmsave
    │   │   │   ├── log4j.properties
    │   │   │   ├── mapred-queues.xml.template
    │   │   │   ├── mapred-site.xml
    │   │   │   ├── mapred-site.xml.rpmsave
    │   │   │   ├── mapred-site.xml.template
    │   │   │   ├── slaves
    │   │   │   ├── ssl-client.xml.example
    │   │   │   ├── ssl-server.xml.example
    │   │   │   ├── yarn-env.sh
    │   │   │   └── yarn-site.xml
    │   │   ├── conf.empty
    │   │   │   ├── capacity-scheduler.xml
    │   │   │   ├── capacity-scheduler.xml.rpmnew
    │   │   │   ├── configuration.xsl
    │   │   │   ├── container-executor.cfg
    │   │   │   ├── core-site.xml
    │   │   │   ├── core-site.xml.rpmsave
    │   │   │   ├── fair-scheduler.xml
    │   │   │   ├── hadoop-env.sh
    │   │   │   ├── hadoop-metrics.properties
    │   │   │   ├── hadoop-metrics2.properties
    │   │   │   ├── hadoop-policy.xml
    │   │   │   ├── hdfs-site.xml
    │   │   │   ├── hdfs-site.xml.rpmsave
    │   │   │   ├── log4j.properties
    │   │   │   ├── mapred-queues.xml.template
    │   │   │   ├── mapred-site.xml
    │   │   │   ├── mapred-site.xml.rpmsave
    │   │   │   ├── mapred-site.xml.template
    │   │   │   ├── slaves
    │   │   │   ├── ssl-client.xml.example
    │   │   │   ├── ssl-server.xml.example
    │   │   │   ├── yarn-env.sh
    │   │   │   └── yarn-site.xml
    │   │   ├── conf.impala
    │   │   │   ├── core-site.xml
    │   │   │   └── hdfs-site.xml
    │   │   ├── core-site.xml
    │   │   ├── hdfs-site.xml
    │   │   ├── mapred-site.xml
    │   │   ├── repos
    │   │   │   ├── cloudera-cdh5.repo
    │   │   │   └── cloudera-gplextras5.repo
    │   │   └── slf4j-log4j12-1.6.1.jar
    │   └── tasks
    │       └── main.yml
    ├── hadoop_client_centos7
    │   ├── files
    │   │   ├── conf.class
    │   │   │   ├── capacity-scheduler.xml
    │   │   │   ├── capacity-scheduler.xml.rpmnew
    │   │   │   ├── configuration.xsl
    │   │   │   ├── container-executor.cfg
    │   │   │   ├── core-site.xml
    │   │   │   ├── core-site.xml.rpmsave
    │   │   │   ├── fair-scheduler.xml
    │   │   │   ├── hadoop-env.sh
    │   │   │   ├── hadoop-metrics.properties
    │   │   │   ├── hadoop-metrics2.properties
    │   │   │   ├── hadoop-policy.xml
    │   │   │   ├── hdfs-site.xml
    │   │   │   ├── hdfs-site.xml.rpmsave
    │   │   │   ├── log4j.properties
    │   │   │   ├── mapred-queues.xml.template
    │   │   │   ├── mapred-site.xml
    │   │   │   ├── mapred-site.xml.rpmsave
    │   │   │   ├── mapred-site.xml.template
    │   │   │   ├── slaves
    │   │   │   ├── ssl-client.xml.example
    │   │   │   ├── ssl-server.xml.example
    │   │   │   ├── yarn-env.sh
    │   │   │   └── yarn-site.xml
    │   │   ├── conf.empty
    │   │   │   ├── capacity-scheduler.xml
    │   │   │   ├── capacity-scheduler.xml.rpmnew
    │   │   │   ├── configuration.xsl
    │   │   │   ├── container-executor.cfg
    │   │   │   ├── core-site.xml
    │   │   │   ├── core-site.xml.rpmsave
    │   │   │   ├── fair-scheduler.xml
    │   │   │   ├── hadoop-env.sh
    │   │   │   ├── hadoop-metrics.properties
    │   │   │   ├── hadoop-metrics2.properties
    │   │   │   ├── hadoop-policy.xml
    │   │   │   ├── hdfs-site.xml
    │   │   │   ├── hdfs-site.xml.rpmsave
    │   │   │   ├── log4j.properties
    │   │   │   ├── mapred-queues.xml.template
    │   │   │   ├── mapred-site.xml
    │   │   │   ├── mapred-site.xml.rpmsave
    │   │   │   ├── mapred-site.xml.template
    │   │   │   ├── slaves
    │   │   │   ├── ssl-client.xml.example
    │   │   │   ├── ssl-server.xml.example
    │   │   │   ├── yarn-env.sh
    │   │   │   └── yarn-site.xml
    │   │   ├── conf.impala
    │   │   │   ├── core-site.xml
    │   │   │   └── hdfs-site.xml
    │   │   ├── core-site.xml
    │   │   ├── hdfs-site.xml
    │   │   ├── mapred-site.xml
    │   │   ├── repos
    │   │   │   ├── cloudera-cdh5.repo
    │   │   │   └── cloudera-gplextras5.repo
    │   │   └── slf4j-log4j12-1.6.1.jar
    │   └── tasks
    │       └── main.yml
    ├── java
    │   └── tasks
    │       └── main.yml
    ├── java_cebu
    │   └── tasks
    │       └── main.yml
    ├── mount
    │   ├── files
    │   │   ├── badmin01_20180420
    │   │   ├── batch01_20180207
    │   │   ├── batch03_20180207
    │   │   ├── bidresult05_20181220
    │   │   ├── dadmin02-ubu_20180403
    │   │   ├── dadmin02_20180417
    │   │   ├── dadmin02s-ubu_20180403
    │   │   ├── dadmin03-ubu_20180327
    │   │   ├── dapi27_20181002
    │   │   ├── dapi28_20181002
    │   │   ├── dapi31_20190710
    │   │   ├── dapi32_20190710
    │   │   ├── dapi33_20190710
    │   │   ├── dbatch01-ubu_20180327
    │   │   ├── img04_20190206
    │   │   ├── img05_20190206
    │   │   ├── nbatch01_20190222
    │   │   ├── sweb01_20180309
    │   │   └── tapi06_20190109
    │   └── tasks
    │       └── main.yml
    ├── mount_centos7
    │   ├── files
    │   │   ├── badmin01_20180420
    │   │   ├── batch01_20180207
    │   │   ├── batch03_20180207
    │   │   ├── bidresult05_20181220
    │   │   ├── dadmin02-ubu_20180403
    │   │   ├── dadmin02_20180417
    │   │   ├── dadmin02s-ubu_20180403
    │   │   ├── dadmin03-ubu_20180327
    │   │   ├── dapi27_20181002
    │   │   ├── dapi28_20181002
    │   │   ├── dapi31_20190710
    │   │   ├── dapi32_20190710
    │   │   ├── dapi33_20190710
    │   │   ├── dbatch01-ubu_20180327
    │   │   ├── img04_20190206
    │   │   ├── img05_20190206
    │   │   ├── nbatch01_20190222
    │   │   ├── sweb01_20180309
    │   │   └── tapi06_20190109
    │   └── tasks
    │       └── main.yml
    ├── mysql_5.7
    │   ├── tasks
    │   │   └── main.yml
    │   └── vars
    │       ├── main.yml
    │       └── private.yml
    ├── mysql_source
    │   ├── files
    │   └── tasks
    │       └── main.yml
    ├── mysql_yum
    │   └── tasks
    │       ├── main.yml
    │       └── main.yml2
    ├── nginx
    │   ├── files
    │   │   ├── api
    │   │   │   ├── acq_http.conf
    │   │   │   ├── acq_https.conf
    │   │   │   ├── cache_block.conf
    │   │   │   ├── common_nginx.conf
    │   │   │   ├── default.conf
    │   │   │   ├── error.html
    │   │   │   ├── errorpage.conf
    │   │   │   ├── nginx.conf
    │   │   │   ├── prefetch.conf
    │   │   │   ├── proxy_cache.conf
    │   │   │   ├── robots.txt
    │   │   │   ├── server.xml
    │   │   │   ├── serving_http.conf
    │   │   │   ├── serving_https.conf
    │   │   │   ├── spamfilter.conf
    │   │   │   └── ssl.conf
    │   │   ├── bidresult
    │   │   │   ├── 40x.html
    │   │   │   ├── 50x.html
    │   │   │   ├── bidresult_http.conf
    │   │   │   ├── bidresult_https.conf
    │   │   │   ├── cache_block.conf
    │   │   │   ├── default.conf
    │   │   │   ├── error.html
    │   │   │   ├── errorpage.conf
    │   │   │   ├── health.html_bk.html
    │   │   │   ├── index.html
    │   │   │   ├── logrote_nginx
    │   │   │   ├── nginx.conf
    │   │   │   ├── openx.html
    │   │   │   ├── prefetch.conf
    │   │   │   ├── proxy_cache.conf
    │   │   │   ├── robots.txt
    │   │   │   ├── spamfilter.conf
    │   │   │   └── ssl.conf
    │   │   ├── iapi
    │   │   │   ├── default.conf
    │   │   │   ├── diiapi.admatrix.jp.conf
    │   │   │   ├── iiapi.ad-m.asia.conf
    │   │   │   ├── iiapi.admatrix.jp.conf
    │   │   │   ├── iiapi.dsp.admatrix.jp.conf
    │   │   │   ├── nginx.conf
    │   │   │   ├── robots.txt
    │   │   │   └── spamfilter.conf
    │   │   ├── img
    │   │   │   ├── default.conf
    │   │   │   ├── mime.types
    │   │   │   ├── nginx.conf
    │   │   │   ├── proxy_cache.conf
    │   │   │   ├── robots.txt
    │   │   │   ├── spamfilter.conf
    │   │   │   └── ssl.conf
    │   │   ├── relay
    │   │   │   ├── cache_block.conf
    │   │   │   ├── default.conf
    │   │   │   ├── direlay.admatrix.jp.conf
    │   │   │   ├── nginx.conf
    │   │   │   ├── relay-dsp.ad-m.asia.conf
    │   │   │   ├── robots.txt
    │   │   │   ├── spamfilter.conf
    │   │   │   └── ssl.relay-dsp.ad-m.asia.conf
    │   │   └── tapi
    │   │       ├── cache_block.conf
    │   │       ├── default.conf
    │   │       ├── default.conf.20171218
    │   │       ├── mime.types
    │   │       ├── nginx.conf
    │   │       ├── prefetch.conf
    │   │       ├── robots.txt
    │   │       ├── spamfilter.conf
    │   │       ├── ssl-sync-dsp.ad-m.asia.conf
    │   │       └── ssl.conf
    │   └── tasks
    │       └── main.yml
    ├── nginx_centos7
    │   ├── files
    │   │   ├── api
    │   │   │   ├── acq_http.conf
    │   │   │   ├── acq_https.conf
    │   │   │   ├── cache_block.conf
    │   │   │   ├── common_nginx.conf
    │   │   │   ├── default.conf
    │   │   │   ├── error.html
    │   │   │   ├── errorpage.conf
    │   │   │   ├── nginx.conf
    │   │   │   ├── prefetch.conf
    │   │   │   ├── proxy_cache.conf
    │   │   │   ├── robots.txt
    │   │   │   ├── server.xml
    │   │   │   ├── serving_http.conf
    │   │   │   ├── serving_https.conf
    │   │   │   ├── spamfilter.conf
    │   │   │   └── ssl.conf
    │   │   ├── bidresult
    │   │   │   ├── 40x.html
    │   │   │   ├── 50x.html
    │   │   │   ├── bidresult_http.conf
    │   │   │   ├── bidresult_https.conf
    │   │   │   ├── cache_block.conf
    │   │   │   ├── default.conf
    │   │   │   ├── error.html
    │   │   │   ├── errorpage.conf
    │   │   │   ├── health.html_bk.html
    │   │   │   ├── index.html
    │   │   │   ├── logrote_nginx
    │   │   │   ├── nginx.conf
    │   │   │   ├── openx.html
    │   │   │   ├── prefetch.conf
    │   │   │   ├── proxy_cache.conf
    │   │   │   ├── robots.txt
    │   │   │   ├── spamfilter.conf
    │   │   │   └── ssl.conf
    │   │   ├── iapi
    │   │   │   ├── default.conf
    │   │   │   ├── diiapi.admatrix.jp.conf
    │   │   │   ├── iiapi.ad-m.asia.conf
    │   │   │   ├── iiapi.admatrix.jp.conf
    │   │   │   ├── iiapi.dsp.admatrix.jp.conf
    │   │   │   ├── nginx.conf
    │   │   │   ├── robots.txt
    │   │   │   └── spamfilter.conf
    │   │   ├── img
    │   │   │   ├── default.conf
    │   │   │   ├── mime.types
    │   │   │   ├── nginx.conf
    │   │   │   ├── proxy_cache.conf
    │   │   │   ├── robots.txt
    │   │   │   ├── spamfilter.conf
    │   │   │   └── ssl.conf
    │   │   ├── relay
    │   │   │   ├── cache_block.conf
    │   │   │   ├── default.conf
    │   │   │   ├── direlay.admatrix.jp.conf
    │   │   │   ├── nginx.conf
    │   │   │   ├── relay-dsp.ad-m.asia.conf
    │   │   │   ├── robots.txt
    │   │   │   ├── spamfilter.conf
    │   │   │   └── ssl.relay-dsp.ad-m.asia.conf
    │   │   └── tapi
    │   │       ├── cache_block.conf
    │   │       ├── default.conf
    │   │       ├── default.conf.20171218
    │   │       ├── mime.types
    │   │       ├── nginx.conf
    │   │       ├── prefetch.conf
    │   │       ├── robots.txt
    │   │       ├── spamfilter.conf
    │   │       ├── ssl-sync-dsp.ad-m.asia.conf
    │   │       └── ssl.conf
    │   └── tasks
    │       └── main.yml
    ├── ruby
    │   ├── files
    │   │   └── ruby-2.0.0-p353.tar.gz
    │   └── tasks
    │       └── main.yml
    ├── ssl_admatrix.jp
    │   ├── files
    │   │   ├── admatrix.jp.nopass.key.to20191013
    │   │   ├── admatrix.jp.nopass.key.to20201112
    │   │   ├── cn_admatrix.jp.crt.to20191013
    │   │   └── cn_admatrix.jp.crt.to20201112
    │   ├── tasks
    │   │   └── main.yml
    │   └── vars
    │       └── main.yml
    ├── tomcat
    │   ├── files
    │   │   ├── lvs
    │   │   │   ├── lvs_add.sh
    │   │   │   └── lvs_del.sh
    │   │   ├── server.xml
    │   │   ├── setenv.sh
    │   │   └── tomcat_bin
    │   │       ├── catalina.sh
    │   │       ├── setenv.sh
    │   │       ├── shutdown.sh
    │   │       └── startup.sh
    │   ├── tasks
    │   │   └── main.yml
    │   └── templates
    │       └── apache-tomcat-8.0.26.tar.gz
    ├── zabbix_2.2
    │   └── tasks
    │       ├── main.yml
    │       └── main.yml.bk
    ├── zabbix_3.0
    │   ├── files
    │   │   └── discovery.conf
    │   └── tasks
    │       ├── main.yml
    │       └── main.yml.bk
    ├── zabbix_3pas
    │   └── tasks
    │       ├── main.yml
    │       └── main.yml.bk
    ├── zabbix_common
    │   └── tasks
    │       ├── main.yml
    │       └── main.yml.bk
    ├── zabbix_dsp
    │   └── tasks
    │       ├── main.yml
    │       └── main.yml.bk
    └── zabbix_staging
        └── tasks
            ├── main.yml
            └── main.yml.bk
```

## common_buildの使い方
* どのプロジェクトからでも共通的に利用する処理を保持する領域。
* 各サーバの領域で作成したplaybookを再利用可能と判断したら、`common_build`へ移行する。

## playbookの書き方について
### `tags: not_XXX` (not_api, not_tapi等) の意味
* common_build/roles/common_build/tasks/main.ymlは他のホストの構築playbookから引用されている。

```
例: /home/ansible/tapi/build.yml

---
- hosts: add
  roles:
    - role: ../common_build/roles/common

```

* 一部サーバによって設定ファイルの中身が少し異なる。
* common_build/roles/common_build/tasks/main.ymlのnot_XXXは共通設定ではまだ設定しないことを意味する。
* playbook実行時にtagを有効にする時は、 `--skip-tags=` オプションを利用する。
	* 各領域のREADMEを参照

## roles/nginxについて
### 用途
* 主にapi, tapi, dapi, dadminディレクトリのbuild.ymlで利用されている。

### 目的
* 共通化させた目的は複数サーバで設定されている`admatrix.jp`のssl証明書と鍵の管理を一元化する為。

### 使い方
* 使いたいサーバのbuild.ymlにcommon_buildのnginxロールを利用する。

### 注意事項
* 同じ名前の設定ファイルでも中身やパスが各サーバごとに異なることがある。
* copyモジュールで配置するときのsrc、dest、modeなどの設定はtasks/main.yml内ではなく個別に定義し、実行するplaybookごとにそれぞれ読み込ませる。

```
例
# common_build/roles/nginx/files/
admatrix.jp.crt
api/default.conf
tapi/default.conf
```

```
例
# common_build/roles/nginx/tasks/main.yml
# nginxのmain.yml内では定義しない
- name: 設定ファイルの配布
  copy:
    src: '{{ item.src }}'
    dest: '{{ item.dest }}'
    mode: '{{ item.mode }}'
  with_items: '{{ conf_files }}'
```

```
例
# api/vars/nginx.yml
# 各ファイルの設定は変数で別に定義している
conf_files:
  - { src: api/default.conf, dest: /etc/nginx/conf.d/, mode: 0644 }
```

```
例
# api/build.yml
---
- hosts: add
  vars:
    vars_files: vars/nginx.yml #ここで変数を定義したファイルを読み込ませる
  roles:
    - { role: ../common_build/roles/common } ##build tablet server
    - { role: api }
    - { role: ../common_build/roles/nginx }
```

## roles/mountについて
### 用途
* apiサーバやbatchサーバなど、nas06,07にマウントしているサーバの処理をまとめたもの。
* hadoopやkuduに関しては未対応。

### 目的
* 各サーバのmount設定を定義ファイルに指定して、処理を共通化する為。

### 使い方
* 使いたいサーバのplaybookのvarsで設定を記述した変数のファイルを作成。
* 変数名は `mount_info`にすること。
* 使いたいサーバのbuild.ymlにvars_fileとcommon_buildのmountロールを利用する。

```
例
# api/vars/mount.ymlについて
mount_info:
  - { src: "192.168.134.205:/backup", path: /nas/backup, opts: "rsize=8192,wsize=8192,hard,intr" }
```

```
例
# api/build.yml

  vars_files:
+    - vars/mount.yml
  roles:
    - ../common_build/roles/common
+    - ../common_build/roles/mount
    - api
```

### 備考
* mountモジュールを実行する前に既存のfstabファイルのバックアップをとる仕様になっている。
バックアップファイルの保存先は以下。

`common_build/roles/mount/files/`

## roles/ssl_XXXについて
### 用途
* 共通的に利用されるものを定義する。
	* （例）`*.admatrix.jp`
* `ssl_ドメイン名`という名称でrolesを作成する。

### 目的
* SSL証明書の配布処理を共通化する為。

### 使い方
* 使いたいサーバの`build.yml`にcommon_buildの`ssl_XXX`のロールを定義して利用する。

```
（例）
- hosts: target
  become: yes
  roles:
    - { role: ../common_build/roles/ssl_admatrix.jp }
```