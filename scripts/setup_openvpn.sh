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

# PKI（公開鍵基盤）を初期化
sudo /usr/share/easy-rsa/3/easyrsa init-pki
# 対話なしで認証局（CA）の作成
yes "" | sudo /usr/share/easy-rsa/3/easyrsa build-ca nopass
# Diffie-Hellman（DH）パラメータの生成
sudo /usr/share/easy-rsa/3/easyrsa gen-dh
# 証明書失効リスト（CRL）の作成
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
server 10.8.0.0 255.255.255.0 # サブネットのIP
ifconfig-pool-persist ipp.txt
push "route 192.168.1.78 255.255.255.0" # EC2のIP
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

# 証明証の確認
echo "--- /etc/openvpn/server/ca.crt ---"
sudo cat /etc/openvpn/server/ca.crt

echo "--- /etc/openvpn/server/issued/user.crt ---"
sudo cat /etc/openvpn/server/issued/user.crt

echo "--- /etc/openvpn/server/private/user.key ---"
sudo cat /etc/openvpn/server/private/user.key
