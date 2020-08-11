## General idea

To monitor the response time of our api servers we need to parse our nginx logs since it contains data that we needed.

```
/etc/nginx/nginx.conf
    log_format  main  '$remote_addr $remote_user [$time_local] [$request_time ms] [$upstream_response_time ms] '
                      '"$request" $status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
```



Above is a snippet of the configuration file which details how the log is formatted. Our data of _interest are request_time upstream_response_time_ which is defined by nginx as

**upstream_response_time** - keeps time spent on receiving the response from the upstream server; the time is kept in seconds with millisecond resolution.
**request_time** - request processing time in seconds with a milliseconds resolution; time elapsed between the first bytes were read from the client and the log write after the last bytes were sent to the client

Previously we are sending these metric via curl to datadog's rest api. For code management purposes I opt to create a custom agent check which makes use of a shell script to tail the target log file.


## Details
### Getting the value of the metric
We will be sending two metrics, fs.nginx.upstream_response_time.seconds fs.nginx.request_time.seconds.


### Parsing multiple logs
Our nginx log configuration have assigned log files to different end point.

```conf
    location  ~^/v/[0-9]*/[0-9]*/[0-9a-z]*\.fs$ {
      access_log /var/log/nginx/acq_http_view.log main;
      error_log  /var/log/nginx/acq_http_view.errorlog;
      proxy_pass http://localhost:8080;
    }

    location  ~^/v2/[0-9]*/[0-9]*/[0-9a-z]*\.fs$ {
      access_log /var/log/nginx/acq_http_view.log main;
      error_log  /var/log/nginx/acq_http_view.errorlog;
      proxy_pass http://localhost:8080;
    }
```

```
('fs.nginx.upstream_response_time.seconds',
  1517462741,
  0.0,
  {'hostname': 'bidresult01.dsp.admatrix.jp',
   'tags': ['protocol:http',
            'server_name:bidresult-dsp.ad-m.asia',
            'log_file:bidresultzzz-dsp.ad-m.asia_dsp_api_http.log',
            'groups:bidresult'],
   'type': 'gauge'}),
 ('fs.nginx.request_time.seconds',
  1517462741,
  0.00228092,
  {'hostname': 'bidresult01.dsp.admatrix.jp',
   'tags': ['protocol:https',
            'server_name:bidresult-dsp.ad-m.asia',
            'log_file:bidresult-dsp.ad-m.asia_adverification_https.log',
            'groups:bidresult'],
   'type': 'gauge'})
```

Note:
On the blogs i cited in these ticket, they recommend checking how the request was handled (pipe or keep alive) however our case does not seem to care for this one, so no need to update the configuration to include the pipe value.

### Sample nginx log
```
1.79.87.58 - [11/Jan/2018:11:14:33 +0900] [0.006 ms] [0.006 ms] "GET /dsp/api/sbid/b?tpsid=d66f25f1a9496468e7ae4e6f8be572d5a11c49de2f1eb814&s=8&w=320&h=50&a=cqZo&rd=http%3A%2F%2Frd.adingo.jp%2F%3Fp%3DIvi4dh5agsHYnl-TqFAbNiBXZ6oi_MjkmOSuFWAe223wxqKAbj8ExOHfpoXFYDg82Z5HD4HJ8qlQ7QlCl0dern8jfHpG5XbYMk9p6sZ93sdzDUEt83rljVE6nELwaOvDy8SG-zzBli7rLha9cA6rPWBAkBqQxf_9DPuW4kgKXQr4e2p61RZPfmiCiKkJtskdI1MDfnQRcTWQbK5cnB-A1XajKJaZ6zdp59BBgTDfWUMG312Y40WNWrE7YVHqTJsG4epHaUNJbnNfxpLnUB7zgNxI8b1XRH84j1ULORn9_l7Qi28EGjuPGaBD4TUU29w5CB2uDM5awJt4H8LDlN2rtg..%26v%3DWqWvDtABIOc.%26k%3D1%26guid%3DON%26u%3D&id=d8895830-4bcf-4e58-9164-d55852b6ac62&b=5&pr=62&mp=0&ru=JTpYm6bE1c&rf=himasoku%2Ecom&auc=9f4891e71c4beefd&va=ae97692d238c450a&kt=5&pos=4&ssc=1!1.0&dc=6&bd=4fc278452624d4be0a04968a4c68b3a7ca58fb832d0cef00&cb=QgNtIPN&cpdt=efa65acea719b02e&afe=Mi41LzAvMS4wLzEwMDAwMC8wLzA&adtype=0&ot=2&at=0&ds=4 HTTP/1.1" 200 3136 "http://himasoku.com/" "Mozilla/5.0 (Linux; Android 6.0.1; SO-02J Build/34.1.B.2.32) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.84 Mobile Safari/537.36" "-"
```

## Ansible Playbook
Execute the following command to run the playbook:
```
cd datadog/nginx_response_time/
ansible-playbook nginx_response_time.yml -i ../inventory/hosts
```

## Links
http://nginx.org/en/docs/http/ngx_http_upstream_module.html
http://nginx.org/en/docs/http/ngx_http_log_module.html
https://lincolnloop.com/blog/tracking-application-response-time-nginx/