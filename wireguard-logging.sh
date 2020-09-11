#!/bin/bash

threshold=120 # 5 minutes in seconds.. anything below that means user connected, anything above means disconnected.
connection_info_file=/var/log/wireguard/connected_clients.info
log_file=/var/log/wireguard/wireguard.log
echo "`date` -- Wireguard Logging Service Started" >> /var/log/wireguard-logging.log
while [ 1 ]
do
        wgout=`wg | grep -B 3 second`
        if [ ! -z "$wgout" ];then
                echo $wgout | sed -n 1'p' | tr '-' '\n' | grep -v '^$'| while read word; do
                peer=`echo $word | awk {'print $2'}`
                hours=`echo $word | grep -oE "[0-9]{1,2} hour" | awk {'print $1'}`
                minutes=`echo $word | grep -oE "[0-9]{1,2} minute" | awk {'print $1'}`
                seconds=`echo $word | grep -oE "[0-9]{1,2} second" | awk {'print $1'}`

                if [ ! -z $hours ];then
                        hour_seconds=$((hours*60))
                fi

                if [ ! -z $minutes ];then
                        minute_seconds=$((minutes*60))
                fi

                if [ ! -z $seconds ];then
                        second_seconds=$((seconds))
                fi

                duration=$((hour_seconds + minute_seconds + second_seconds))
                user=`grep -irl ${peer} /etc/wireguard/clients/ | awk -F'/' {'print $5'}`
                #echo "User: $user, Duration: $duration, Peer: $peer"
                if [ $duration -le $threshold ];then
                        touch ${connection_info_file} ${log_file}
                        grep -i $user ${connection_info_file} >> /dev/null
                        if [ $? -ne 0 ];then
                                echo "`date` - $user connected" >> ${connection_info_file}
                                echo "`date` - User $user connected $hours Hours $minutes Minutes $seconds second ago" >> ${log_file}

                        fi
                elif [ $duration -gt $threshold ];then
                        touch ${connection_info_file} ${log_file}
                        grep -i $user ${connection_info_file} >> /dev/null
                        if [ $? -eq 0 ];then
                                sed -i "/$user/d" ${connection_info_file}
                                echo "`date` - User $user disconnected $hours Hours $minutes Minutes $seconds second ago" >> ${log_file}

                        fi
                fi
                done
        fi
        sleep 5
