#!/bin/bash
test -a /usr/bin/sudo || sudo()( su -c "$@";)   ##自动授予sudo权限
test -e ~/.yukicpl/aria.temp && {
    source ~/.yukicpl/aria.temp
    mv ~/.yukicpl/aria.temp ~/.yukicpl/aria.conf
}
test -e ~/.yukicpl/aria.conf || {
    c
}
source ~/.yukicpl/aria.conf
echo "  [雪次元AriaWebUI控制面板]
     请选择希望执行的操作
          [o] 启    用
          [s] 停    止
          [c] 设    置
          [q] 退    出
          [a] 添加用户
          [r] 移除用户
"


o()(
    start-stop-daemon --start --quiet --background --pidfile /run/aria2c-rpc.pid --chdir $WD/download/ --chuid $usr --exec /usr/bin/aria2c -- --enable-rp
)

s()(
    pkill -f aria2c ##结束进程
    test "$logsl" = "Y" && {    ##判断是否启用了日志备份
        test -z "$logdir" &&    {   ##判断是否指定了存储路径
            mv $logdir/nohup.out "$log/$(date +"%Y_%m_%d_%H_%M_%S")Closed.log"
            mv $WD/download/nohup.out "$log/$(date +"%Y_%m_%d_%H_%M_%S")Closed.log"
        }
    }
)

c()(    ##设置
    read -e -p "您当前指定的 webui 站点绑定的目录是 $WD ，如果希望修改请输入新值，请使用类似 /www/aria2_webui 这样的格式，并记得授予权限
    >" Wd
    test -z "$Wd" || {  ##不为空则更新
        WD=$Wd
    }
        read -e -p "您当前指定的用于运行 Aria2c_RPC 的用户是 $usr ,如果希望修改请输入新的用户名，请确保该用户名可用
    >" user
    test -z "$user" || {  ##不为空则更新
        usr=$user
    }
    read -e -p "您当前对停止后是否自动保存日志的设置（Y/N）是 $logsl ,如果希望修改请输入新的选项
    >" logsel
    test -z "$logsel" || {  ##不为空则更新
        logsl=$logsel
    }
    read -e -p "您当前指定的 webui 站点绑定的目录是 $logdir ,如果希望变更设置请在这里输入新值，请使用类似 /www/aria2_webui 这样的格式。
    >" logdr
    test -z "$logdr" || {  ##不为空则更新
        logdir=$logdr
    }

    echo ""
    echo 请输入下载目录
##写入配置文件
    rm -f ~/.yukicpl/aria.conf
    cat > "~/.yukicpl/aria.conf" << OOO
##这里存放的是雪次元服务器管理面板的 Aria2c_RPC_WebUI 管理模块专用的的相关设置，请尽量不要单独修改
WD="$WD"   ##请在这里输入webui绑定的目录（请不要以/结束）
usr="$usr"  ##请在这里输入启用 Aria2c_RPC 服务的用户名
logsl="$logsl"    ##请在这里输入是否需要备份日志（目前不会自动删除日志，Y / N 大写字母输入，默认为N，如果启用本功能，请务必手动填写 logdir 字段，否则将不会自动进行日志的保存）
logdir="$logdir"   ##请在这里指定用于保存日志的路径（为空则不自动保存，无论 logsl 的设置是什么）（请不要以/结束）
OOO
##  重载配置文件
source ~/.yukicpl/aria.conf
)

q()(    ##退出

)

a()(    ##添加用户

)

r()(    ##移除用户

)

echo " $@" | grep -q ' -t' && TEST=1    ## 如果启动命令行参数有 -t 则使用测试模式，不执行命令

help    ##帮助
while true; do
    [ -z "$HELPED" ] && echo '查看帮助请输入 help'
    HELPED=1
    read -e -p '请选择希望执行的操作> ' CMD
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