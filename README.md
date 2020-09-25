# Wireguard Helper Script

This is a set of helper script to create new configuration for wireguard clients. There is also a script that basically creates a service to monitor wireguard interfaces and log incoming connections as well as disconnections. 

# Buy me Coffee

<a href="https://www.buymeacoffee.com/akn" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>

# Pre-Requisites
- All Client Configurations must be stored in `/etc/wireguard/clients` directory

# Installation
- Clone this repo
- Run the Install Script
```bash
./install.sh 
```
- Update following configurations in `/etc/wireguard/create_client.sh` to your own environment's settings
```
SERVER_IP=YOUR_SERVER_IP
LISTEN_PORT=YOUR_WIREGUARD_LISTEN_PORT
DNS_SERVERS="DNS_IP_1 , DNS_IP_2"
SERVER_PUBLIC_KEY="SERVER_PUBLIC_KEY"
PUSH_ROUTE_ALL="0.0.0.0/0, ::/0"
PUSH_ROUTE_INTRANET="192.168.x.0/24, 192.168.x.0/24"
SERVER_CONFIG='wg0.conf'
IP_RANGE='192.168.x.1 and 192.168.x.253'
```
- Update the `notify_by_email` and `notification_email` in `wireguard-logging.sh` to get email notifications.
- To Manage Clients Run the Create Client Script
```bash
./create_client.sh
```
- The logs will be avavailable in `/var/log/wireguard/`

# Future Enhancements
- Add optional Email Notifications 
- Log the connections and disconnections to syslog.
- Create a patterndb parser for syslog. 
- Create whitelist and notify over telegram/slack etc. when IP outside whitelist connect

# Help, Bugs &  Feature Requests
- Please open up an issue for any bugs and Feature Requests.

# Learn More

Watch my videos at https://www.youtube.com/playlist?list=PL5PZjrSldZ81vy_pQV-hFy5F7S4JnAVqN

# Need Help ? 

Open an issue in github. 
