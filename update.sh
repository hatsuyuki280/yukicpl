#!/bin/bash 
## 雪次元服务器控制面板更新程序
test -a /usr/bin/sudo || sudo()( su -c "$@";)   ##自动申请sudo权限
rm /usr/local/bin/yukicpl* yukicpl
sudo wget -O /usr/local/bin/yukicpl https://raw.githubusercontent.com/hatsuyuki280/yukicpl/master/yukicpl.sh
chmod +x /usr/local/bin/yukicpl
echo 更新完成，下次使用直接输入 yukicpl 即可
