import subprocess

from checks import AgentCheck

class ProcessesRunning(AgentCheck):
    METRIC_NAME = 'fs.processes.running.number'


    def check(self,instance):
        PROCESSES_RUNNING_COMMAND = "ps o state axh | grep '^[R]' | wc -l"

        processes_running = subprocess.Popen(PROCESSES_RUNNING_COMMAND, stdout=subprocess.PIPE, shell=True)
        processesrunning, err = processes_running.communicate()
        processesrunning = processesrunning.translate(None, '\n')

        self.gauge(self.METRIC_NAME, processesrunning)
