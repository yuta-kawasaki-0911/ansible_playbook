import subprocess
import os.path

from checks import AgentCheck

class ConntrackCountChecker(AgentCheck):
    METRIC_NAME = 'fst.system.idle_nf_conntrack'


    def check(self, instance):
        CONNTRACK_COUNT_COMMAND = ["cat", "/proc/sys/net/netfilter/nf_conntrack_count"]

        conntrack_count = subprocess.Popen(CONNTRACK_COUNT_COMMAND, stdout=subprocess.PIPE)
        conntrackcount, errC = conntrack_count.communicate()
        
        
        CONNTRACK_MAX_COMMAND = ["cat", "/proc/sys/net/netfilter/nf_conntrack_max"]
        
        conntrack_max = subprocess.Popen(CONNTRACK_MAX_COMMAND, stdout=subprocess.PIPE)
        conntrackmax, errM = conntrack_max.communicate()
        
        percent = round(float(conntrackcount)/float(conntrackmax), 2)

        self.gauge(self.METRIC_NAME, percent)
