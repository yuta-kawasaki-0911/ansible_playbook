#!/usr/bin/expect

set timeout 5
spawn ssh [lindex $argv 0]
expect "password:"
send "sysdev\r"
expect "Last login"
send "touch /usr/local/apache2/htdocs/health.html\r"
send "echo [lindex $argv 0] > /usr/local/apache2/htdocs/health.html\r"
send "chmod 777 /usr/local/apache2/htdocs/health.html\r"
send "exit\r"
interact

