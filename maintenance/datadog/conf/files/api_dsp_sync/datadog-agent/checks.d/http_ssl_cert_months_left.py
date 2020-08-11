import subprocess
from datetime import datetime
import _strptime # noqa
import os.path

import requests
import tornado

from checks import AgentCheck


class SSLExpiryChecker(AgentCheck):
    METRIC_NAME = 'fst.system.ssl.cert_months_left'

    def _load_conf(self, instance):
        # Fetches the conf
        method = instance.get('method', 'get')
        data = instance.get('data', {})
        tags = instance.get('tags', [])
        instance_ca_certs = instance.get('ca_certs', 'None')
        
        return method, data, tags, instance_ca_certs


    def check(self, instance):
        METHOD, DATA, TAGS, INSTANCE_CA_CERTS = self._load_conf(instance)
        SSL_EXPIRATION_COMMAND = ["openssl", "x509", "-enddate", "-noout", "-in", INSTANCE_CA_CERTS]
        custom_tags = instance.get('tags', [])

        openssl_process = subprocess.Popen(SSL_EXPIRATION_COMMAND, stdout=subprocess.PIPE)
        openssl_out, err = openssl_process.communicate()

        expiration_date = datetime.strptime(openssl_out.split("=")[1], "%b %d %H:%M:%S %Y %Z\n")
        time_left = expiration_date - datetime.utcnow()

        remaining_months = self._check_remaining_months(instance, time_left)

        self.gauge(metric=self.METRIC_NAME, value=remaining_months, tags=custom_tags)


    def _check_remaining_months(self, instance, time_left):
        return time_left.days * (1 / 30.4167) 

