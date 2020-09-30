#!/bin/bash
SERVER_IP=YOUR_SERVER_IP
LISTEN_PORT=YOUR_WIREGUARD_LISTEN_PORT
DNS_SERVERS="DNS_IP_1 , DNS_IP_2"
SERVER_PUBLIC_KEY="SERVER_PUBLIC_KEY"
PUSH_ROUTE_ALL="0.0.0.0/0, ::/0"
PUSH_ROUTE_INTRANET="192.168.x.0/24, 192.168.x.0/24"
SERVER_CONFIG='wg0.conf'
IP_RANGE='192.168.x.1 and 192.168.x.253'
read -p "Enter Client Name:" client_name_temp
read -p "Push All Routes ? If not only Intranet will be routed (y/n):" confirmRoutes
echo "What do you want the client IP to be,must be between ${IP_RANGE} ?:"
echo "These Ips are already used:"
grep AllowedIPs ${SERVER_CONFIG}
read -p "Enter client IP you want to assign:" clientIP

if [ "${confirmRoutes}" == 'y' ];then
        PUSH_ROUTE=${PUSH_ROUTE_ALL}
elif [ "${confirmRoutes}" == 'n' ];then
        PUSH_ROUTE=${PUSH_ROUTE_INTRANET}
else
        echo "Invalid Selection, aborting..."
fi

echo "Push Route: ${PUSH_ROUTE}"

client_name=`echo ${client_name_temp} | sed 's/ /-/g'`
mkdir -p ./clients/${client_name}
destination_file=./clients/${client_name}/${client_name}
private_key=`wg genkey`
public_key=`echo ${private_key} | wg pubkey`

echo "${private_key}" >> ${destination_file}-priv.key
echo "${public_key}" >> ${destination_file}-pub.key

# create client config
echo "Creating Client Config"

cat <<EOF > ${destination_file}.conf
[Interface]
Address = ${clientIP}/24
PrivateKey = ${private_key}
DNS = ${DNS_SERVERS}

[Peer]
PublicKey = ${SERVER_PUBLIC_KEY}
AllowedIPs = ${PUSH_ROUTE}
Endpoint = ${SERVER_IP}:${LISTEN_PORT}
EOF

# append config to server
systemctl stop wg-quick@wg0

echo "Appending Configuration to Server Config ${SERVER_CONFIG}"
cat << EOF >> ${SERVER_CONFIG}

#${client_name}
[Peer]
PublicKey = ${public_key}
AllowedIPs = ${clientIP}/32
EOF

echo "Scan the CODE below if Mobile, or Copy the Config File if other devices"
qrencode -t ansiutf8 < ${destination_file}.conf

echo "Client Configuration"
echo "######################################################"
cat ${destination_file}.conf

systemctl restart wg-quick@wg0
systemctl restart wireguard-logging
