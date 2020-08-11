import subprocess
import os.path

from checks import AgentCheck

class CheckNumberOfProcess(AgentCheck):
    def check(self, instance):
        metric_name = 'fs.process.count'
        ps_count_command = 'ps aux | wc -l'

        ps_count = subprocess.Popen(ps_count_command, stdout=subprocess.PIPE, shell=True)
        pscount_out, err = ps_count.communicate()

        self.gauge(metric_name, pscount_out)