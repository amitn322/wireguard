#!/bin/bash
echo "Installing please wait..."
cp wireguard-logging.service /etc/systemd/system/wireguard-logging.service
mkdir -p /etc/wireguard/clients/
cp create_client.sh /etc/wireguard/
cp wireguard-logging.sh /etc/wireguard/
sleep 5
chmod +x /etc/wireguard/create_client.sh
chmod +x /etc/wireguard/wireguard-logging.sh
systemctl enable wireguard-logging.service
systemctl start wireguard-logging.service
echo "Installation Complete !"
echo "Please run ./create_client.sh to create new clients "
echo "Log files are located at /var/log/wireguard/"
