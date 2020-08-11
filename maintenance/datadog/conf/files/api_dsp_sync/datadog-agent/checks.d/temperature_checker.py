#!/usr/bin/python

# @author - Cristopher Cutas
#
# Notes:
# millidegree = 1.0e-3 = .001
# https://unix.stackexchange.com/questions/85468/how-to-get-core-temperature-of-haswell-i7-cores-in-i3status

import subprocess, glob, tempfile
from shutil import copyfile

from checks import AgentCheck

class TemperatureChecker(AgentCheck):
    def check(self, instance):
        temperature_files = glob.glob("/sys/devices/platform/coretemp.*/temp2_input")
        if temperature_files.__len__() < 1:
            return False
        
        core_counter = 0

        for temperature_file in temperature_files:
            millidegree_celsius = int(self.file_get_contents(temperature_file))
            celsius = millidegree_celsius * .001
            self.gauge("fst.system.cpu.temperature", celsius, tags=["cpu:" + str(core_counter)])
            core_counter += 1

    def file_get_contents(self, filename):
        tempcopy = tempfile.gettempdir() + "/fst.agent.tempcopy"
        copyfile(filename, tempcopy)
        with open(tempcopy, "r") as f:
            return f.read()

    def celsius_to_fahrenheit(self, celsius):
        return ((celsius - 32) * 5) / 9

    def fahrenheit_to_celcius(self, fahrenheit):
        return ((fahrenheit * 9) / 5) + 32


