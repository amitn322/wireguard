#!/bin/bash

# Version 1.1 
# Author : Amit K Nepal 
# email: amit@amitnepal.com

# Configuration Variables
threshold=300 # 5 minutes in seconds.. anything below that means user connected, anything above means disconnected.
connection_info_file=/var/log/wireguard/connected_clients.info
log_file=/var/log/wireguard/wireguard.log
notification_email=YOUR_EMAIL
notify_by_email=yes
#Configuration End

# Functions Declarations

function notify()
{
  user=$1
  endpoint=$2
  durationMsg=$3
  msgType=$4


  message="VPN $msgType: $user from $endpoint"
           {
                echo "User: $user"
                echo "Remote Host: $endpoint"
                echo "Event Type: $msgType"
                echo "Event Time: $durationMsg"
                echo "Date: `date`"
                echo "Hostname: `hostname -f`"
                echo "Server: `uname -a`"
        } | mail -s "Wireguard Alert: $user $msgType from $endpoint on `hostname -s`" ${notification_email}

echo "`date` Message: $message $durationMsg"

}

# Functions End

# Script Logic Begin

mkdir -p /var/log/wireguard/
echo "`date` -- Wireguard Logging Service Started" >> /var/log/wireguard/wireguard-service.log
while [ 1 ]
do
        wgout=`wg | sed -n '/^peer/,/^$/p'`
        if [ ! -z "$wgout" ];then
                echo $wgout | sed 's/peer/\npeer/g' | grep -v '^$'| while read word; do
                #echo "-------------------------------------------"
                #echo "word: $word"
                #echo "-------------------------------------------"
                endpoint=`echo $word | grep -o 'endpoint:\s\+\S*\W' | awk -F':' {'print $2'} | tr -d ' '`
                peer=`echo $word | grep -o 'peer:\s\+\S*\W' | awk -F':' {'print $2'} | tr -d ' '`
                days=`echo $word | grep -oE "[0-9]{1,3} day" | awk {'print $1'}`
                hours=`echo $word | grep -oE "[0-9]{1,2} hour" | awk {'print $1'}`
                minutes=`echo $word | grep -oE "[0-9]{1,2} minute" | awk {'print $1'}`
                seconds=`echo $word | grep -oE "[0-9]{1,2} second" | awk {'print $1'}`
                #endpoint=`echo $word  | awk -F' |:' {'print $6'}`
                durationMessage=''
                continue=true
                if [ ! -z $days ];then
                        day_seconds=$(($days*24*60*60*60))
                        durationMessage+="$days Day(s),"
                        continue=false
                fi
                if [ ! -z $hours ];then
                        hour_seconds=$((hours*60*60))
                        durationMessage+="$hours Hour(s), "
                        continue=false
                fi

                if [ ! -z $minutes ];then
                        minute_seconds=$((minutes*60))
                        durationMessage+="$minutes minute(s), "
                        continue=false
                fi

                if [ ! -z $seconds ];then
                        second_seconds=$((seconds))
                        durationMessage+="$seconds second(s) ago"
                        continue=false
                fi

                if [ $continue == "true" ];then
                    continue
                fi

                duration=$((hour_seconds + minute_seconds + second_seconds))
                user=`grep -rl ${peer} /etc/wireguard/clients/ | awk -F'/' {'print $5'}`
                #echo "User: $user , Duration: $duration, Peer: $peer, IP: $endpoint, Threshold: $threshold"
                if [ $duration -le $threshold ];then
                        touch ${connection_info_file} ${log_file}
                        grep -i $user[[:space:]] ${connection_info_file} >> /dev/null
                        if [ $? -ne 0 ];then
                                echo "`date` - $user connected" >> ${connection_info_file}
                                echo "`date` - User $user connected from $endpoint $durationMessage" >> ${log_file}
				if [ "$notify_by_email" == "yes" ];then
                                	notify "$user" "$endpoint" "$durationMessage" "Connected"
				fi

                        fi
                elif [ $duration -gt $threshold ];then
                        touch ${connection_info_file} ${log_file}
                        grep -i $user[[:space:]] ${connection_info_file} >> /dev/null
                        if [ $? -eq 0 ];then
                                sed -i "/$user/d" ${connection_info_file}
                                echo "`date` - User $user $endpoint disconnected $durationMessage" >> ${log_file}
                                if [ "$notify_by_email" == "yes" ];then
                                	notify "$user" "$endpoint" "$durationMessage" "Disconnected"
                                fi

                        fi
                fi
                done
        fi
        sleep 30
done

