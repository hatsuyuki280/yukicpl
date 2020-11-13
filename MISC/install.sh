#!/bin/bash 
## 雪次元服务器控制面板安装程序
test -a /usr/bin/sudo || sudo()( su -c "$@";)   ##自动申请sudo权限
sudo wget -O /usr/local/bin/yukicpl https://raw.githubusercontent.com/hatsuyuki280/yukicpl/master/yukicpl.sh
chmod +x /usr/local/bin/yukicpl
echo 安装完成，在当前终端输入 yukicpl 即可启动
