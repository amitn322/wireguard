# wireguard

This is a set of helper script to create new configuration for wireguard clients. There is also a script that basically creates a service to monitor wireguard interfaces and log incoming connections as well as disconnections. 

# Pre-Requisites
- All Client Configurations must be stored in `/etc/wireguard/clients` directory

# Installation
- Clone this repo
- Run the Install Script
```bash
./install.sh 
```
- To Manage Clients Run the Create Client Script
```bash
./create_client.sh
```
- The logs will be avavailable in `/var/log/wireguard/`

# Future Enhancements
- Add optional Email Notifications 
- Log the connections and disconnections to syslog.
- Create a patterndb parser for syslog. 
