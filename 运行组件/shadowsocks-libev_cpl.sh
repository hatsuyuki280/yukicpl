#!/bin/bash
## setup ss
port=""
password=""
##初始化
while test -z "$port" ; do
    read -e -p "请在这里输入希望监听的端口号
    >" port
done
while test -z "$password" ; do
    read -e -p "请在这里输入一串字符作为密码
    >" password
done
echo -e 'deb http://ftp.debian.org/debian/ stretch-backports main \ndeb-src http://ftp.debian.org/debian/ stretch-backports main'  | sudo tee /etc/apt/sources.list.d/stretch-backports.list
apt update
sudo apt install -y shadowsocks-libev simple-obfs -t  stretch-backports

cp /etc/shadowsocks-libev/config.json /etc/shadowsocks-libev/config.json.dpkg
cat > /etc/shadowsocks-libev/config.json <<OOO
{
    "server":"0.0.0.0",
    "server_port":$port,
    "local_port":1080,
    "password":"$password",
    "timeout":60,
    "mode":"tcp_and_udp",
    "fast_open":true,
    "method":"chacha20-ietf-poly1305",
    "plugin":"obfs-server",
    "plugin_opts":"obfs=http;failover=msn.com:80;fast-open"
}
OOO
systemctl restart shadowsocks-libev

## setup bbr
sysctl net.ipv4.tcp_congestion_control=bbr | grep -q sysctl: || {
    sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
    echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
    sysctl -p
}
