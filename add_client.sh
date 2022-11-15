#!/bin/bash
# @YuriyStartsev, github.com/blurry71

# Enter the values of client's name and allowedip
if [ -z "$1" ]
  then
    read -p "Enter VPN user name: " USERNAME
    if [ -z $USERNAME ]
      then
      echo "[#]Empty VPN user name. Exit"
      exit 1;
    fi
  else USERNAME=$1
fi

if [ -z "$2" ]
  then
    read -p "Enter AllowedIP: " ALLOWEDIP
    if [ -z $ALLOWEDIP ]
      then
      echo "[#]Empty AllowedIP"
      exit 1;
    fi
  else ALLOWEDIP=$2
fi

# Generate a pair of ssh keys
wg genkey | tee /etc/wireguard/clients_keys/${USERNAME}_privatekey | wg pubkey | tee /etc/wireguard/clients_keys/${USERNAME}_publickey

# Write the client's public key to the wg0.conf configuration file
PUBLICKEY="$(cat /etc/wireguard/clients_keys/${USERNAME}_publickey)"
echo -e "\n#${USERNAME}\n[Peer]\nPublicKey = ${PUBLICKEY}\nAllowedIPs = 10.0.0.${ALLOWEDIP}/32" >> /etc/wireguard/wg0.conf

# Reboot wireguard
cd /etc/wireguard/
systemctl restart wg-quick@wg0.service
systemctl status wg-quick@wg0.service

# Create client's profile
PRIVATEKEY="$(cat /etc/wireguard/clients_keys/${USERNAME}_privatekey)"
touch /etc/wireguard/clients_conf/${USERNAME}.conf
echo -e "[Interface]\nPrivateKey = ${PRIVATEKEY}\nAddress = 10.0.0.${ALLOWEDIP}/32\nDNS = 8.8.8.8\n" > /etc/wireguard/clients_conf/${USERNAME}.conf
echo -e "[Peer]\nPublicKey = #SERVER_PUBLICKEY_VALUE\nEndpoint = #HOST_IP:51830\nAllowedIPs = 0.0.0.0/0\nPersistentKeepalive = 20" >> 
/etc/wireguard/clients_conf/${USERNAME}.conf

# Generate QR-code
qrencode -t ansiutf8 < /etc/wireguard/clients_conf/${USERNAME}.conf && qrencode -t png -o /etc/wireguard/clients_conf/${USERNAME}qr.png -r /etc/wireguard/clients_conf/${USERNAME}.conf

