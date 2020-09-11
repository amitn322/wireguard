#!/bin/bash
echo "Installing please wait..."
cp wireguard-logging.service /etc/systemd/system/wireguard-logging.service
cp create_client.sh /etc/wireguard/
cp wireguard-logging.sh /etc/wireguard/
sleep 5
echo "Installation Complete !"
echo "Please run ./create_client.sh to create new clients "
echo "Log files are located at /var/log/wireguard/"
