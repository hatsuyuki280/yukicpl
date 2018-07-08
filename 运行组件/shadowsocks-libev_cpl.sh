#!/bin/bash
test -a /usr/bin/sudo || sudo()( su -c "$@";)   ##自动申请sudo权限
## setup ss

help()(
    echo "
            |==================|
            | steup 安装SS服务 |
            |  open 启用服务器 |
            |  stop 停止ss服务 |
            | reset 重新设置SS |
            |==================|
    "
    echo 请选择需要的操作
    echo ">"
)

setup()(    ##执行安装操作&进行设置
    test ~/.yukicpl/sitting/ss.ini && {
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
    } || {
    ture
    }
    test 
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
ip=$(wget -O- ifconfig.me )
systemctl restart shadowsocks-libev ##测试是否启动正常
systemctl stop shadowsocks-libev    ##停止运行

echo "shadowsocks-libev已经部署完毕
链接信息为      “$IP”
远程端口号为    “$port”
连接密码为      “$password”
加密方式为      “chacha20-ietf-poly1305”
已启用 Simple-Obfs 混淆服务
请在客户端安装并启用 Simple-Obfs 客户端。"


## setup bbr
sysctl net.ipv4.tcp_congestion_control=bbr | grep -q sysctl: || {
    sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
    echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
    sysctl -p
})


echo " $@" | grep -q ' -t' && TEST=1    ## 如果启动命令行参数有 -t 则使用测试模式，不执行命令
echo " $@" | grep -q ' -setup' && setup
help    ##帮助
while true; do
    [ -z "$HELPED" ] && echo '查看帮助请输入 help'
    HELPED=1
    read -e -p '请选择命令> ' CMD
    [ "$CMD" = quit ] && quit
    [ "$CMD" =    q ] && quit
    ## 检测输入的命令有没有存在对应函数
    test -z "$CMD" && continue ## 输入命令为空
    type -t "$CMD" | grep -q function || {
        echo "命令 $CMD 没找到，查看帮助请输入 help"
        continue 
    }
    ## 测试模式下不实际执行命令，而是显示命令内容
    if [ -n "$TEST" ] ; then
        type "$CMD"
    else
        "$CMD"
    fi
done
