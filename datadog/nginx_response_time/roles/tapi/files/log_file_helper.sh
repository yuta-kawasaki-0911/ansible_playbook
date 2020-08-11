#!/bin/bash
# Only getting the latest 5000 log entry since on average of a 2.0G whole day log file size
# there is an average of 1200 entries and 3500 entries high that have the same timestamp in terms of minutes.

function get_average_response_time() {
    log_file=$1
    target_date=`date +"%Y:%H:%M"`
    full_log_path=/var/log/nginx/${log_file}

    if [ -f "$full_log_path" ]
    then
        average_response_time_result=`ionice -c3 nice -n 10 tail -n10000 ${full_log_path} |
            awk -v target_date="${target_date}" 'BEGIN {
                    row_cnt = 0
                    request_time_sum = 0
                    upstream_response_time_sum = 0
                }
                {
                    if (index(substr($3,2), target_date) != 0) {
                        request_time_sum += substr($5,2)
                        upstream_response_time_sum += substr($7,2)
                        row_cnt++
                    }
                }
                END {
                    average_request_time = request_time_sum/row_cnt
                    average_upstream_response_time = upstream_response_time_sum/row_cnt
                    print average_request_time,average_upstream_response_time
                }'`

        echo $average_response_time_result
    else
        echo 0.0 0.0
    fi
}

get_average_response_time $1