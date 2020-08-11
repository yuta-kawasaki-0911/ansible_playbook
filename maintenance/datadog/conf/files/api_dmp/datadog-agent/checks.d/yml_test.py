import subprocess
from datetime import datetime
import _strptime # noqa
import os.path

import requests
import tornado

from checks import AgentCheck


class SSLWebsiteExpiryChecker(AgentCheck):
    def check(self, instance):
        domain = instance.get('domainname', None)
        metric_name = 'fs.ssl.months_left'
        ssl_command = "echo |  openssl s_client -connect " + domain + ":443 2>/dev/null | openssl x509 -noout -enddate"
        ssl_process = subprocess.Popen(ssl_command, stdout=subprocess.PIPE, shell=True)
        openssl_out, err = ssl_process.communicate()

        self.gauge(metric=metric_name, value=0, tags=['domain:'+domain,openssl_out])

    def _calculate_remaining_months(self, instance, time_left):
        return time_left.days * (1 / 30.4167)
