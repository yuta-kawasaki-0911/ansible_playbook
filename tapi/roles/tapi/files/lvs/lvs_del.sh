#!/usr/bin/expect

set timeout 5
spawn ssh [lindex $argv 0]
expect "password:"
send "sysdev\r"
expect "Last login"
send "rm -rf /usr/local/apache2/htdocs/health.html\r"
send "exit\r"
interact
