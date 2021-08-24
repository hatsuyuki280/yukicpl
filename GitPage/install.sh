#!/bin/bash
## 雪次元服务器控制面板安装程序
UpdatedDate='20210721'
###
# init install script
###
test -a /usr/bin/sudo || sudo() (su -c "$@")
full=0
lang="zh_CN.UTF-8"
echo $@ | grep -q -- "--full" && full=1
echo $@ | grep -q -- "--ja" && lang="ja_JP.UTF-8"
echo $@ | grep -q -- "--en" && lang="C.UTF-8"
echo $@ | grep -q -- "--zh" && lang="zh_CN.UTF-8"
DistChannel="dev"

###
# main
###
main() {
    install && {
        success
    } || {
        fail
    }
}

install() {
    ###
    # Show Readme and license
    ###
    echo "
    "

    ###
    # Download main file and grant exec permission
    ###
    sudo wget -O /usr/local/bin/yukicpl "https://yukicpl.moeyuki.tech/dist/$DistChannel/bin/yukicpl.sh"
    sudo chmod +x /usr/local/bin/yukicpl

    ###
    # Creat dir and download translate file
    ###
    sudo mkdir -p /usr/local/lib/yukicpl /usr/local/share/yukicpl /etc/yukicpl
    sudo wget -O /etc/yukicpl/yukicpl.$lang "https://yukicpl.moeyuki.tech/dist/$DistChannel/i18n/yukicpl.$lang"

    [ $full -eq 1 ] && {
        [ $lang = "zh_CN.UTF-8" ] && echo "接下来将会调用Yukicpl进行下载，请根据向导的提示完成Yukicpl的初期设置。"
    [ $lang = "ja_JP.UTF-8" ] && echo "これからはYukicplを実行し、ダウンロードを行う。\nウイザードに従って、初期設定を完成してください。"
    [ $lang = "C.UTF-8" ] && echo "Yukicpl will execute after 3s, And full-downloading all yukicpl files.please complete the init setting following wizard first."
        yukicpl --full-install --"$lang"
    }

    return 0
}

success() {
    [ $lang = "zh_CN.UTF-8" ] && echo "安装完成，在当前终端输入 yukicpl 即可启动"
    [ $lang = "ja_JP.UTF-8" ] && echo "インストールが完了しました。パネルを起動するには、ターミナルで yukicpl を実行してください。"
    [ $lang = "C.UTF-8" ] && echo "Install is Successfully Done, you can execute yukicpl in terminal for run."
}
fail() {
    [ $lang = "zh_CN.UTF-8" ] && echo "安装失败！无法完成某些命令。" >&2
    [ $lang = "ja_jp.UTF-8" ] && echo "インストールが失敗しました。一部の操作は完了できませんでした。" >&2
    [ $lang = "C.UTF-8" ] && echo "Install is Failed. Can not complete some tasks." >&2
}

main