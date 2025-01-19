#!/bin/bash

# エラーハンドリング
set -e

# 更新と基本的なツールのインストール
echo "Updating system and installing required tools..."
sudo yum update -y

# EPELリポジトリの有効化とOpenVPNのインストール
echo "Enabling EPEL repository and installing OpenVPN..."

# amazon linux 2
sudo amazon-linux-extras enable epel
sudo yum clean metadata
sudo yum install -y epel-release

sudo yum install -y openvpn
sudo yum install -y easy-rsa --enablerepo=epel

sudo /usr/share/easy-rsa/3/easyrsa init-pki
sudo /usr/share/easy-rsa/3/easyrsa build-ca nopass
sudo /usr/share/easy-rsa/3/easyrsa gen-dh
sudo /usr/share/easy-rsa/3/easyrsa gen-crl

# VPNサーバの証明書作成
sudo /usr/share/easy-rsa/3/easyrsa build-server-full server nopass

# クライアントの証明書作成
sudo /usr/share/easy-rsa/3/easyrsa build-client-full user nopass
sudo cp -r /usr/bin/pki/. /etc/openvpn/server/

cat <<EOF | sudo tee /etc/openvpn/server.conf
port 1194
proto udp
dev tun
ca /etc/openvpn/server/ca.crt
cert /etc/openvpn/server/issued/server.crt
key /etc/openvpn/server/private/server.key
dh /etc/openvpn/server/dh.pem
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "route 192.168.1.0 255.255.255.0"
push "redirect-gateway def1"
keepalive 10 120
user nobody
group nobody
persist-key
persist-tun
status openvpn-status.log
log-append  openvpn.log
verb 3
EOF

# Linux カーネルの IP 転送を有効にする
sudo sh -c 'echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf && sysctl -p'

# iptables で MASQUERADE（NAT）設定
# firewalld が存在しない / inactive の場合
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo yum install -y iptables-services
sudo service iptables save
sudo systemctl enable iptables

# OpenVPNの起動と有効化
echo "Starting and enabling OpenVPN server..."
sudo systemctl restart openvpn@server
sudo systemctl enable openvpn@server
sudo systemctl status openvpn@server
