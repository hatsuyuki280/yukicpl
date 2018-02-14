#!/bin/bash
echo "  [雪次元AriaWebUI控制面板]
     请选择希望执行的操作
          [o] 启动
          [s] 停止
          [c] 设置
          [q] 退出
"
test -e ~/.yukicpl/aria.temp && {
    source ~/.yukicpl/aria.temp
}
test -e ~/.yukicpl/aria.conf || {
    setup
}
source ~/.yukicpl/aria.conf

c()(
    echo 暂不可用

    echo 请输入下载目录

    source ~/.yukicpl/aria.conf
)

o()(
    cd /yuki/site/dl.sm.yuki233.com/download/ 
    sudo -u dl nohup aria2c --enable-rpc &
#    cd $DLR/download/ 
#    sudo -u dl nohup aria2c --enable-rpc &
)

s()(
    pkill -f aria2c
#    test "$logsl" = "Y" && {
#        mv /yuki/site/dl.sm.yuki233.com/download/nohup.out "$log/$(date +"%Y_%m_%d_%H_%M_%S")Closed.log"
#        #mv $DLR/download/nohup.out "$log/$(date +"%Y_%m_%d_%H_%M_%S")Closed.log"
    }
)

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