#!/bin/bash
## 雪次元服务器控制面板安装程序

###
# init install script
###
test -a /usr/bin/sudo || sudo() (su -c "$@")
easy=1
lang="zh"
echo $@ | grep -q -- "--full" && easy=0
echo $@ | grep -q -- "--ja" && lang="ja"
echo $@ | grep -q -- "--en" && lang="en"

###
# main
###
main() {
    [ $easy -eq 1 ] && {
        easy_install() && {
            success()
        } || {
            fail()
        }
    } || {
        install() && {
            success()
        } || {
            fail()
        }
    }
}

easy_install() {
    ###
    # 下载主程序并授予所有用户执行权限
    ###
    sudo wget -O /usr/local/bin/yukicpl https://yukicpl.moeyuki.tech/dist/dev/bin/yukicpl.sh
    sudo chmod +x /usr/local/bin/yukicpl

    ###
    # 创建相关目录
    ###
    sudo mkdir -p /usr/local/lib/yukicpl /usr/local/share/yukicpl /etc/yukicpl
    return 0
}

install() {
    ###
    # Download main file and grant exec permission
    ###
    sudo wget -O /usr/local/bin/yukicpl https://yukicpl.moeyuki.tech/dist/dev/bin/yukicpl.sh
    sudo chmod +x /usr/local/bin/yukicpl

    ###
    # Creat dir
    ###
    sudo mkdir -p /usr/local/lib/yukicpl /usr/local/share/yukicpl /etc/yukicpl

    ###
    # download more files
    ###
    
}

sucess() {
    [ $lang = "zh" ] && echo "安装完成，在当前终端输入 yukicpl 即可启动"
    [ $lang = "ja" ] && echo "インストールが完了しました。パネルを起動するには、ターミナルで yukicpl を実行してください。"
    [ $lang = "en" ] && echo "Install is Successfully Done, you can execute yukicpl in terminal for run."
}
fail() {
    [ $lang = "zh" ] && echo "安装失败！无法完成某些命令。" >&2
    [ $lang = "ja" ] && echo "インストールが失敗しました。一部の操作は完了できませんでした。" >&2
    [ $lang = "en" ] && echo "Install is Failed. Can not complete some tasks." >&2
}