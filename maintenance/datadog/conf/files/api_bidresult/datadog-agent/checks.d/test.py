import subprocess

shell_command = ['sh', 'log_file_helper.sh', 'bidresult-dsp.ad-m.asia_dsp_api_http.log']
process = subprocess.Popen(shell_command, stdout=subprocess.PIPE)
result, err = process.communicate()
print(float(result.strip()))
