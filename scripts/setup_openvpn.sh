#!/bin/bash

# vim setup_openvpn.sh
# sh setup_openvpn.sh 2>&1 | tee output.log

# エラーハンドリング
set -e

# 更新と基本的なツールのインストール
echo "Updating system and installing required tools..."
sudo yum update -y
sudo yum install -y openvpn iptables-services openssl

# 証明書ディレクトリの作成
echo "Creating directories for certificates..."
sudo mkdir -p /etc/openvpn/server

# CA（認証局）の秘密鍵と証明書を作成
echo "Generating CA private key and certificate..."
sudo openssl genrsa -out /etc/openvpn/server/ca.key 2048
sudo openssl req -x509 -new -nodes -key /etc/openvpn/server/ca.key \
    -sha256 -days 3650 -out /etc/openvpn/server/ca.crt \
    -subj "/CN=OpenVPN-CA"

# サーバー証明書と秘密鍵を作成
echo "Generating server private key and certificate..."
sudo openssl genrsa -out /etc/openvpn/server/server.key 2048
sudo openssl req -new -key /etc/openvpn/server/server.key \
    -out /etc/openvpn/server/server.csr \
    -subj "/CN=OpenVPN-Server"
sudo openssl x509 -req -in /etc/openvpn/server/server.csr \
    -CA /etc/openvpn/server/ca.crt -CAkey /etc/openvpn/server/ca.key \
    -CAcreateserial -out /etc/openvpn/server/server.crt \
    -days 3650 -sha256

# クライアント証明書と秘密鍵を作成
echo "Generating client private key and certificate..."
sudo openssl genrsa -out /etc/openvpn/server/client.key 2048
sudo openssl req -new -key /etc/openvpn/server/client.key \
    -out /etc/openvpn/server/client.csr \
    -subj "/CN=OpenVPN-Client"
sudo openssl x509 -req -in /etc/openvpn/server/client.csr \
    -CA /etc/openvpn/server/ca.crt -CAkey /etc/openvpn/server/ca.key \
    -CAcreateserial -out /etc/openvpn/server/client.crt \
    -days 3650 -sha256

# Diffie-Hellman パラメータの生成
echo "Generating Diffie-Hellman parameters..."
sudo openssl dhparam -out /etc/openvpn/server/dh.pem 2048

# 証明書を適切なディレクトリに配置
echo "Moving certificates and keys to OpenVPN directory..."

# OpenVPN サーバー設定ファイルの作成
echo "Creating OpenVPN server configuration..."
cat <<EOF | sudo tee /etc/openvpn/server/server.conf
port 1194
proto udp
dev tun
ca /etc/openvpn/server/ca.crt
cert /etc/openvpn/server/server.crt
key /etc/openvpn/server/server.key
dh /etc/openvpn/server/dh.pem
server 192.168.1.0 255.255.255.0 # サブネットのIP
ifconfig-pool-persist ipp.txt
push "route 35.182.111.45 255.255.255.0" # EC2のIP
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

# IP 転送の有効化
echo "Enabling IP forwarding..."
sudo sh -c 'echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf && sysctl -p'

# インターフェイス名がenX0であるか確認
echo "Checking up iptables NAT rules..."
ip a

# NAT 設定 
# firewalld が存在しない / inactive の場合
echo "Setting up iptables NAT rules..."
sudo iptables -t nat -A POSTROUTING -o enX0 -j MASQUERADE
sudo service iptables save
sudo systemctl enable iptables

# OpenVPN の起動と有効化
echo "Starting and enabling OpenVPN server..."
sudo systemctl restart openvpn-server@server
sudo systemctl enable openvpn-server@server
sudo systemctl status openvpn-server@server --no-pager

# 証明証の確認
echo "--- /etc/openvpn/server/ca.crt ---"
sudo cat /etc/openvpn/server/ca.crt

echo "--- /etc/openvpn/server/client.crt ---"
sudo cat /etc/openvpn/server/client.crt

echo "--- /etc/openvpn/server/client.key ---"
sudo cat /etc/openvpn/server/client.key
