import subprocess
from checks import AgentCheck

class NginxResponseTimeCheck(AgentCheck):
    def check(self, instance):
        metric_request_time = self.init_config.get('metric_request_time', 'fs.nginx.request_time.seconds')
        metric_upstream_response_time = self.init_config.get('metric_upstream_response_time', 'fs.nginx.upstream_response_time.seconds')
        groups = self.init_config.get('groups', 'bidresult')

        server_name = instance.get('server_name')
        logfile = instance.get('logfile')
        protocol = instance.get('protocol')

        shell_command = ['nice', '-n', '10', 'sh', '/etc/datadog-agent/checks.d/log_file_helper.sh', logfile]
        process = subprocess.Popen(shell_command, stdout=subprocess.PIPE)
        result, err = process.communicate()

        request_time, upstream_response_time = result.split()

        self.gauge(metric_request_time, 
            float(request_time.strip()), 
            tags=[
                    'protocol:' + protocol, 
                    'server_name:' + server_name, 
                    'log_file:' + logfile,
                    'groups:' + groups
                ])

        self.gauge(metric_upstream_response_time, 
            float(upstream_response_time.strip()), 
            tags=[
                    'protocol:' + protocol, 
                    'server_name:' + server_name, 
                    'log_file:' + logfile,
                    'groups:' + groups
                ])