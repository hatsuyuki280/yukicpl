#!/bin/bash

###
# pre_test
###
test -a /usr/bin/sudo || sudo()( su -c "$@";)
test -e /etc/yukicpl/yukicpl.conf || {
    echo "未找到配置文件,执行初始化"
    test -e /usr/local/lib/yukicpl/init.sh
}
source /etc/yukicpl/yukicpl.conf
##程序本体部分~~~
help()(
echo 'Writing now'
)

####################我是分割线####################

echo "$@" | grep -q -- '--test' && TEST=1    ## 如果启动命令行参数有 --test 则使用测试模式，不执行命令
echo "$@" | grep -q -- '--help' && help

help    ##帮助
while true; do
    [ -z "$HELPED" ] && echo '查看帮助请输入 help'
    HELPED=1
    read -e -p '请输入命令> ' CMD
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
