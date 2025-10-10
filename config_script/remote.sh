#!/bin/bash
# https://github.com/Hero-oo/IPSec-Server-Setup/blob/master/setup.sh
# https://github.com/hwdsl2/docker-ipsec-vpn-server/tree/master
set -x
uptime
ufw disable
sudo apt-get update
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

sudo apt-get install -y iftop docker.io
cat > vpn.env << EOF
# Define IPsec PSK, VPN username and password
# - DO NOT put "" or '' around values, or add space around =
# - DO NOT use these special characters within values: \ " '
VPN_IPSEC_PSK=Admin123
VPN_USER=vpn
VPN_PASSWORD=Admin123

# Define additional VPN users
# - DO NOT put "" or '' around values, or add space around =
# - DO NOT use these special characters within values: \ " '
# - Usernames and passwords must be separated by spaces
# VPN_ADDL_USERS=additional_username_1 additional_username_2
# VPN_ADDL_PASSWORDS=additional_password_1 additional_password_2

# Use a DNS name for the VPN server
# - The DNS name must be a fully qualified domain name (FQDN)
# VPN_DNS_NAME=vpn.example.com

# Specify a name for the first IKEv2 client
# - Use one word only, no special characters except '-' and '_'
# - The default is 'vpnclient' if not specified
# VPN_CLIENT_NAME=your_client_name

# Use alternative DNS servers
# - By default, clients are set to use Google Public DNS
# - Example below shows Cloudflare's DNS service
# VPN_DNS_SRV1=1.1.1.1
# VPN_DNS_SRV2=1.0.0.1

# Protect IKEv2 client config files using a password
# - By default, no password is required when importing IKEv2 client configuration
# - Uncomment if you want to protect these files using a random password
# VPN_PROTECT_CONFIG=yes

VPN_ANDROID_MTU_FIX=yes
VPN_L2TP_NET=10.1.0.0/16
VPN_L2TP_LOCAL=10.1.0.1
VPN_L2TP_POOL=10.1.0.10-10.1.254.254
VPN_XAUTH_NET=10.2.0.0/16
VPN_XAUTH_POOL=10.2.0.10-10.2.254.254
EOF
docker run --name vpn-server --restart=always --env-file ./vpn.env \
  -v ikev2-vpn-data:/etc/ipsec.d -v /lib/modules:/lib/modules:ro \
  -d --privileged --network host \
  hwdsl2/ipsec-vpn-server
#-p 500:500/udp -p 4500:4500/udp -d --privileged \

