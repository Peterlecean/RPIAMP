#!/bin/bash
if [ "$(id -u)" -ne 0 ]; then
    echo -e "\e[31mRun as root with sudo ...\e[0m" >&2
    exit 1
fi
apt update
apt -y upgrade
apt install gcc cmake make g++ build-essential devscripts autotools-dev fakeroot dpkg-dev debhelper autotools-dev dh-make quilt ccache libsamplerate0-dev libpulse-dev libaudio-dev lame libjack-jackd2-dev libasound2-dev libtwolame-dev libfaad-dev libflac-dev libshout3-dev libmp3lame-dev mc sudo network-manager net-tools apache2 php libapache2-mod-php php-mbstring php-mysql php-curl php-gd php-zip php-xml mariadb-server htop btop git zip openvpn icecast2 -y
cd /etc/openvpn
make-cadir easy-rsa/
cd easy-rsa/
./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa build-server-full server nopass
./easyrsa gen-dh
openvpn --genkey secret /etc/openvpn/server/ta.key
./easyrsa build-client-full client nopass
echo -e 'port 1194
proto udp
dev tun
ca      /etc/openvpn/easy-rsa/pki/ca.crt
cert    /etc/openvpn/easy-rsa/pki/issued/server.crt
key     /etc/openvpn/easy-rsa/pki/private/server.key
dh      /etc/openvpn/easy-rsa/pki/dh.pem
topology subnet
server 10.10.0.0 255.255.0.0
push "route 192.168.0.0 255.255.0.0"
push "redirect-gateway def1 bypass-dhcp"
keepalive 10 120
tls-auth /etc/openvpn/server/ta.key 0
auth-nocache
cipher AES-256-CBC
data-ciphers AES-256-CBC
duplicate-cn
persist-key
persist-tun
status /var/log/openvpn/openvpn-status.log
verb 3
client-to-client
explicit-exit-notify 1' >> /etc/openvpn/server.conf
echo 'AUTOSTART="all"' >> /etc/default/openvpn
touch /var/log/openvpn/openvpn-status.log
systemctl stop openvpn
systemctl daemon-reload
systemctl start openvpn
