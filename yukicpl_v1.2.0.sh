#!/bin/bash 
## 初雪的服务器控制面板
## 本文件可以放在 /usr/local/bin/yuki-panel.sh ，并 chmod +x /usr/local/bin/yuki-panel.sh 以方便执行
##
## 本文件 git 版本位于 https://gist.github.com/shellexy/73a5ed0d3c86a468104171e659c076d9
## 更新 git 版可以在 bash 执行 sudo wget -O /usr/local/bin/yuki-panel.sh https://gist.github.com/shellexy/73a5ed0d3c86a468104171e659c076d9/raw/24c3ea3eb035d6cd4cdb4761e452585a4c1cddfb/yuki-panel.sh ; sudo chmod +x /usr/local/bin/yuki-panel.sh


## 注： xxx()( yyyy; ) 或 xxx(){ yyyy; } 表示定义 bash 函数，函数名 xxx，函数内容为执行 yyyy
##     其中 圆括号版是在新建 bash 里执行里边的命令，而花括号版是在当前 bash 里执行

##设置部分↓↓↓

##这是默认的一级域名部分
DDN="yuki233.com"   ##请务必修改的部分

##这是默认网站所在的目录(绝对路径，以"/"开始，不要以"/"结尾)
WR="/yuki/site"     ##请务必修改的部分

##这是ngnix的设置文件夹(绝对路径，以"/"开始，不要"/"结尾)
NGSR="/etc/nginx"   ##此项开始以下为如果不确定请保持默的部分

##这是PHP的路径(绝对路径，以"/"开始，以响应PHP指令的文件结尾)
PP="/etc/init.d/php7.0-fpm"

##这是nginx的位置，用来执行重启、启用、停止、重载(绝对路径，以"/"开始，"nginx"结尾)
NGP="/etc/init.d/nginx"

##这是PHP.ini的位置(以"/"开头，以php.ini结尾)
PI="/etc/php/7.0/fpm/php.ini"

##这里是MonaServer的安装路径(执行文件应在这个文件夹里，否则将会自动部署nginx直播服务器)，直播用
LP="/yuki/live/MonaServer-master/MonaServer"


##程序本体部分~~~
help()(
echo '
    /////////////////////////[  初雪服务器控制面板  ]\\\\\\\\\\\\\\\\\\\\\\\\\\
    **************************[ Yuki Control Panel ]***************************
    ===========================================================================
   |      o  * 开启服务器       sqlf  * 数据库状态      giton  * 启动代码托管* |
   |      s  * 关闭服务器        php  * 查看php版本      ----  * 功能开发中    |
   |      r  * 重启服务器        ini  * 配置php.ini      ----  * 功能开发中    |
   |    add  * 添加新站点       ----  * 功能开发中       ----  * 功能开发中    |
   |   sset  * 手动配置站点*    ----  * 功能开发中     siscon  * 常用系统设置  |
   |    ssl  * 配置ssl证书      live  * 开始直播        clean  * 清理服务器    |
   |    sql  * SQL功能列表     lived  * 结束直播        chown  * 重置网站权限  |
   |     ss  * SS-VPN管理工具*  ----  * 功能开发中        dnc  * 批量改域名*   |
   |   list  * 查看网站列表     ----  * 功能开发中       tmgr  * 系统状态      |
   |    del  * 删除站点         ----  * 功能开发中       quit  * 退出面板      |
    ==========================================================================='
)

##第一列内容##

o()(        ##启用服务器（Ngnix、PHP、[MySQL]、[]）
    _check_nginx
    echo 开启 PHP 服务器
    $PP restart
    echo 开启 nginx 服务器
    set -x
    $NGP start
)

s()(        ##关闭服务器
    echo 关闭 nginx 服务器
    set -x
    $NGP stop
)

r()(        ##重启服务器
    _check_nginx
    echo 重启 php
    $PP restart
    echo 重启 nginx 服务器
    $NGP restart
)

add()(      ##添加新站点
    echo 给 nginx 添加一个站点并绑定域名
    read -e DN
    ## 提示用户输入域名
    ## 注：test -z "xxx" 或 [ -z "xxx" ] 用来检测变量是否空字符
    ##     && 表示如果 左边命令成功 则接着执行右边命令
    ##[ -z "$DN" ] && read -e -p '请输入新域名: '  DN
    ## 注：|| 表示如果 左边命令不成功，则接着执行右边命令
    while test -z "$SITE" ; do  ##检查$SITE变量是否存在
    echo "$DN" | grep -q -E '^[.a-zA-Z0-9-]+(.com|.info)$' && { ##合法的有效域名
        SITE="$DN"
        echo 将使用$SITE作为站点绑定的域名
    } || {  ##不合法的
            echo "$DN" | grep -q -E '^[.a-zA-Z0-9-]+$' && { ##可以作为二级域名注册
                    read -e -p "域名不是很合法，是否使用默认的“$DDN”作为一级域名？[Y/N]"   SL
                    ##提示输入....read -e -p  "提示信息"  变量名字
                echo "$SL" | grep -q -E '^[YyNn]$' && { ##满足Y或N
                        echo "$SL" | grep -q -E '^[Yy]$' && {   ##满足Y
                            SITE="$DN.$DDN"
                            echo '将使用'$SITE'作为域名创建站点'
                        } || {  ##不满足Y，满足N
                            echo "您希望创建的域名 $DN 不符合格式，请检查后重试，或检查本面板设置是否正确"
                            exit    ##返回待机
                        }
                }  
            } || {  ##不合法的无效输入
                echo "您输入的域名 $DN 似乎不符合格式"
                }
        }
    done
    ##echo "$DN" | grep -q -E '^[.a-zA-Z0-9_]+(.com|.info)$' || {
    ##    exit
    ##}
    ## 注：grep 带参数 -r 会在目录及子目录递归搜索
    ##          带参数 -E 可以用正则表达式搜索，其中 ^ 表示行开头， \s 表示空白字符，
    ##          ^\s* 则用来表示一行开头有任意个空白字符
    grep -r -E "^\s*server_name\s*$SITE;" $NGSR/sites-enabled/ && {
        echo "站点 $SITE 已经存在"
        exit
    }

    ## 检测 nginx、php-fpm 等
    _check_nginx
    ## 站点目录会放在 /yuki/site/站点名字 下边
    WWWDIR="/var/www/$SITE"
    WWWDIR="$WR/$SITE"

    ## 注：mkdir 带参数 -p 可以自动创建多级目录
    mkdir -p "$WWWDIR"

    ## 写入新站点配置文件
    ## 注：下边这种格式里边的文本里要用 \$xxx 来表示 $xxx 字符，否则会被当作 xxx 变量
    cat > "$NGSR/sites-enabled/$SITE" << OOO
## nginx configuration
server {
	listen 80;
	listen [::]:80;

	root $WWWDIR;

	index index.php index.html index.htm index.nginx-debian.html;

	server_name $SITE;

	location / {
		# First attempt to serve request as file, then
		# as directory, then fall back to displaying a 404.
		try_files \$uri \$uri/ =404;
		if (!-e \$request_filename){
			rewrite ^/(.*) /index.php last;
		}
	}

	# pass PHP scripts to FastCGI server
	#
	location ~ \.php\$ {
		include snippets/fastcgi-php.conf;

		# With php-fpm (or other unix sockets):
		fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
		# With php-cgi (or other tcp sockets):
	#	fastcgi_pass 127.0.0.1:9000;
	}

	# deny access to .htaccess files, if Apache's document root
	# concurs with nginx's one
	#
	location ~ /\.ht {
		deny all;
	}
}

OOO

 ## 检测 nginx
    $NGP start
    $NGP reload || {
        echo "## 添加站点 $SITE 没有成功"
        return
    }
    ## 添加默认的 index.html
    test -a "$WWWDIR/index.html" || test -a "$WWWDIR/index.php" || cp /var/www/html/index.nginx-debian.html "$WWWDIR/index.html"
    echo "## 添加了站点 $SITE ，目录位于 $WWWDIR"
    ping -c 1 $SITE ##敲击一下dns
    ## https 证书
    ## Let's Encrypt 目前只支持 A 记录验证，不支持 CNAME
    #nslookup $SITE | grep -q 'canonical name' && {
    #    echo "## Let's Encrypt 目前只支持 A 记录验证，不支持 CNAME…所以咱暂时没办法为您的 CNAME 域名申请并配置 ssl 证书了…"
    #    return
    #}
    echo "## 自动申请 Let’s Encrypt 免费 https 证书"
    ## 如果系统还没有 certbot --nginx 则尝试安装 python-certbot-nginx
    _check_certbot
    ## 注：certbot 具体用法可以在 bash 下执行 man certbot 查看
    ##     --nginx 参数表示对 nginx 服务器配置，
    ##     --preferred-challenges tls-sni 表示使用 443 端口验证申请
    ##     --redirect 参数表示将 80 端口 http 访问重定向到 443 端口 https 地址
    ##     --keep 参数表示保持已经申请过的证书
    certbot --agree-tos --nginx --preferred-challenges tls-sni --redirect --keep --register-unsafely-without-email -d "$SITE" && {
        ## 新版 certbot 生成的配置文件里 redirect 被注释了，所以用下边的 sed 命令开启将 http 访问转到 https
        sed -i '/# Redirect non-https traffic to https/,/# } # managed by Certbot/s/# Redirect non-https traffic to https/if ($scheme != "https") { return 301 https:\/\/$host$request_uri; } # Redirect http to https/g' "$NGSR/sites-enabled/$SITE"
        $NGP reload
        echo "## 站点 $SITE 已启用 https，并将 80 端口 http 访问重定向到 443 端口 https 地址，将于每月 1 日自动续期"
    }
    ## 配置 cron 定时自动续期证书
    which crontab > /dev/null || { echo "使用 cron 定时自动续期证书" ; apt install -y cron ; }
    echo -e "0 0 1 * * /usr/bin/certbot renew --force-renewal \n9 0 1 * * $NGP restart " > /etc/cron.d/certbot-renew
    chown
    echo 如果人为修改了$WWWDIR中的文件，记得回本面板使用一次chown工具将文件的权限重置为网站所有
)

sset()(     ##手动设置站点配置Nginx文件（未完成）
    echo 现在已存在的站点列表
    grep -h -r '^\s*server_name ' $NGSR/sites-enabled/ | awk '{print $2}' | uniq
    echo 请输入需要手动修改配置文件的网站域名，取消请输入‘c’：
    read -e DN
    [ -z "$DN" ] && read -e -p '请重新输入: '  DN
    test "$DN" = c -o "$DN" = C && {
            echo  取消修改
            return
        }
    

)

ssl()(  ##设置基于Let’s Encrypt的SSL，仅限A记录
    echo "## 配置全站使用 Let’s Encrypt 免费 https 证书，并自动续期"
    echo "## 如果您已经配置过 https 证书，请输入 c 取消"
    $NGP start
    certbot -q --help | grep ' --nginx' || apt install -y python-certbot-nginx || return
    certbot --agree-tos --nginx --preferred-challenges tls-sni --redirect --keep --register-unsafely-without-email && {
        ## 新版 certbot 生成的配置文件里 redirect 被注释了，所以用下边的 sed 命令开启将 http 访问转到 https
        sed -i '/# Redirect non-https traffic to https/,/# } # managed by Certbot/s/# Redirect non-https traffic to https/if ($scheme != "https") { return 301 https:\/\/$host$request_uri; } # Redirect http to https/g' "$NGSR/sites-enabled/"*
        $NGP reload
    }
    which crontab > /dev/null || { echo "使用 cron 定时自动续期证书" ; apt install -y cron ; }
    echo -e "0 0 1 * * /usr/bin/certbot renew --force-renewal \n9 0 1 * * $NGP restart " > /etc/cron.d/certbot-renew
    echo -e "## 手动续期可以在 shell 下执行命令\n    certbot renew"
)


sql()(      ##SQL服务器管理界面（未完成）
    _check_mysql
    echo '
    ///////////////////////[  初雪服务器控制面板 -SQL- ]\\\\\\\\\\\\\\\\\\\\\\\
    ***********************[  Yuki -SQL- Control Panel ]***********************
    ===========================================================================
   |   sqlo  * 开启sql          user  * 列出用户名     sqlchk  * 遍历数据库    |
   |   sqls  * 关闭sql         pwsee  * 查看密码       addsql  * 添加数据库    |
   |   sqlr  * 重启sql         adusr  * 添加新用户     delsql  * 移除数据库    |
   |   sqlb  * 备份/导出       rmusr  * 移除用户         conf  * 数据库设置    |
   |  recov  * 恢复/导入        root  * root密码操作     back  * 返回主菜单    |
    ==========================================================================='

)

#### sql 控制面板用指令 ####\

sqlo()(     ##启动sql
    echo 启动sql
    service mysqld start
)

sqls()(   ##停止sql
    echo 停止sql
    service mysqld stop
)

sqlr()(   ##重启sql
    echo 重启sql
    service mysqld restart
)

sqlb()(   ##备份/导出
    echo 请选择想要备份/导出
)

recov()(  ##恢复/导入
    true
)

user()(   ##列出用户
    true
)

pwsee()(  ##查询某个数据库或某个用户的密码
    true
)

adusr()(  ##添加一个新用户并配置数据库权限
    true
)

rmusr()(  ##移除一个数据库并询问移除同名数据库
    true
)

root()(   ##操作root用户密码，实现显示密码和修改密码功能（软修改和强行修改最好都有）
    true
)

sqlchk()( ##列出所有数据库名
    true
)

addsql()( ##手动添加一个数据库
    true
)

delsql()( ##手动移除一个数据库
    true
)

conf()(   ##数据库设置（虽然不知道应该放些什么进去）
    true
)

#### sql 控制面板用指令 ####/

ss()(       ##用于控制ShadowS-lib(未完成)
    echo '
     ///////////////////////[  初雪服务器控制面板 -SS- ]\\\\\\\\\\\\\\\\\\\\\\\\
     ***********************[ Yuki -S.S- Control Panel ]************************
     ===========================================================================
    |   ss-o  * 开启服务器*   ss-auto  * 自动部署ss*    ss-ins  * 安装SS服务端* |
    |   ss-s  * 关闭服务器*      ----  * 功能开发中      ss-rm  * 卸载SS服务端* |
    |  ssini  * 修改配置文件*    ----  * 功能开发中       back  * 返回主菜单    |
     ==========================================================================='
)

#### SS 控制面板用指令 ####\
ss-auto()(     ##自动部署ss服务器
    echo 即将自动部署
)

ss-ins()(   ##SS安装
    echo 这里是SS的安装
)

ss-rm()(   ##SS卸载
    echo 这里是SS的卸载
)

#### SS 控制面板用指令 ####/

list()(     ##查看已启用的站点列表
    echo 查看站点列表
    grep -h -r '^\s*server_name ' $NGSR/sites-enabled/ | awk '{print $2}' | uniq
)

del()(      ##移除站点
    echo 现在已存在的站点列表
    grep -h -r '^\s*server_name ' $NGSR/sites-enabled/ | awk '{print $2}' | uniq
    echo '输入要删除站点的域名或二级域名，取消请输入‘c’，不支持删除多域名绑定的站点
          (如未指定一级域名，则使用默认设置)'
    read -e DN
    ## 提示用户输入域名
    [ -z "$DN" ] && read -e -p '请重新输入: '  DN
    test "$DN" = c -o "$DN" = C && {
        echo  停止删除
        return
    }
    echo "$DN" | grep -q -E '^[.a-zA-Z0-9_]+(.com|.info)$' && {
        SITE="$DN"
    } || {
        SITE="$DN.$DDN"
    }
    echo "$DN" | grep -q -E '^[.a-zA-Z0-9_]+(.com|.info)$' && {
        SITE="$DN"
    }

    read -e LS
    rm -r $WR/$SITE
    rm $NGSR/sites-enabled/$SITE
    $NGP reload
)


##第二列内容##

sqlf()(
    service mysqld status
)

php()(
    echo 查看 php 版本
    /usr/bin/php -v
)


ini()(      ##打开php.ini
    echo 查看 php.ini 
    nano $PI
)

live()(     ##开启直播服务器
    test -e $LP/MonaServer && { ##如果安装了mona直播服务
        cd $LP
        ./MonaServer -d
    } || {  ##没有安装直播服务
        test -a /usr/lib/nginx/modules/ngx_rtmp_module.so || {  #检查nginx直播服务安装状态，如未安装
            echo -e 'deb http://ftp.debian.org/debian/ stretch-backports main \ndeb-src http://ftp.debian.org/debian/ stretch-backports main'  > /etc/apt/sources.list.d/stretch-backports.list
            apt update
            apt install libnginx-mod-rtmp -t stretch-backports
        } 
    }
        rm $NGSR/yukicpl_check_point/.liveadd
        read -e -p "是否需要同时直播至其他站点？[y/N]"   SL
        while [ "$SL" = "Y" -o "$SL" = "y" ] ; do  ##是否继续添加
            while test -z "$live_url" ; do  ##检查$SITE变量是否存在(不存在执行)
                echo "请输入需要转播的直播站点（rtmp协议，格式如下）"
                echo "(直接从直播地址的域名开始)live.example.com/直播码(直播密钥)"
                read -e live_url           
                echo "$live_url" | grep -q -E '^[.a-zA-Z0-9-/]$' && { ##合法的有效域名
                echo push rtmp://$live_url>>$NGSR/yukicpl_check_point/.livesite
                    } || {  ##不合法的
                    echo 输入的内容不合规范，请再检查一遍并重新输入
                    break ##离开当前循环&continue=继续循环
                    }
            done
        live_url="" ##初始化
        read -e -p "是否需要同时直播至其他站点？[y/N]"
        done

    live_url_ok=$(cat $NGSR/yukicpl_check_point/.livesite ) ##将推流列表扔进变量里
    grep -q "rtmp" /etc/nginx/nginx.conf || cat >> /etc/nginx/nginx.conf <<OOO
rtmp {
 server{
     listen 1935;
     chunk_size 4096;

     application live {
           live on;
           record off;
           $live_url_ok         ##想把那个文件的内容扔进这里
          }
    }
}  
OOO
    ##修改nginx的配置为[可直播]
    }
    test -e $NGSR/yukicpl_check_point/.livesite || {  ##检查直播网站文件是否存在
        read -e -p "是否需要为直播服务添加一个站点？[Y/n]"   SL ##询问是否需要
        echo "$SL" | grep -q -E '^[Nn]$' && {   ##满足否
        echo '将不配置www页面'
            } || {  ##需要
                ret=$(add | tee /dev/stderr)
                site_dir=`echo "$ret" |  grep '添加了站点.*目录位于' | grep -o '\/[0-9a-zA-Z./]*'`
                livesite=`echo "$ret" |  grep '添加了站点.*目录位于' | grep -o '[0-9a-zA-Z.]*' | head -1`
                mkdir -p "$NGSR/yukicpl_check_point"    ##记录检查点
                cat > "$NGSR/yukicpl_check_point/.livesite" << OOO
ready
直播站点 web 目录位于 $site_dir
直播站点绑定的域名是：$livesite
OOO
                cd $site_dir    ##转入站点目录
                echo 未部署站点程序
            }
    }
    r
    echo 启动成功
    grep -h 直播站点 "$NGSR/yukicpl_check_point/.livesite"
)

lived()(     ##停止直播服务器
    test -e $LP/MonaServer && { ##如果安装了mona直播服务
        pkill -f MonaServer
    } || {  ##没有安装直播服务
        sed -i '/^rtmp/,/^}/d' /etc/nginx/nginx.conf
    ##修改nginx的配置为[不可直播]
    }
    r
    echo 停止成功
)

list()(     ##查看已启用站点列表
    echo 查看站点列表
    grep -h -r '^\s*server_name ' $NGSR/sites-enabled/ | awk '{print $2}' | uniq
)

##第三列内容##

giton()(    ##启用本地代码托管（未完成）
echo '正在编写'
echo '未完成'
)

siscon ()(
    echo '
    ///////////////////////[  初雪服务器控制面板 -SSS- ]\\\\\\\\\\\\\\\\\\\\\\\
    ***********************[  Yuki -SSS- Control Panel ]***********************
    ===========================================================================
   |   ----  * 功能开发中       ----  * 功能开发中       ----  * 功能开发中    |
   |   ----  * 功能开发中       ----  * 功能开发中       ----  * 功能开发中    |
   |   ----  * 功能开发中       ----  * 功能开发中       ----  * 功能开发中    |
   |   ----  * 功能开发中       ----  * 功能开发中      timea  * 系统时区设置  |
   |   ----  * 功能开发中       ----  * 功能开发中       back  * 返回主菜单    |
    ==========================================================================='
)
##给常用系统设置功能用的命令##

timea()( ##修改时区
    timearea=$(date -R)
    echo 当前时区为"$timearea"
    read -e -p "是否要修改当前时区[y/N]"   SL ##询问是否需要
    echo "$SL" | grep -q -E '^[Yy]$' && {   ##满足是
    dpkg-reconfigure tzdata
    }
)

##给常用系统设置功能用的命令##
clean()(
    echo 本操作将会清理所有网站目录/数据库/ftp信息，同时卸载nginx环境/php环境/mysql环境/sqlite环境
    echo 不会删除控制面板文件，适合打算初始化服务器的情景使用
    echo 请确定已完成数据/文件备份
    echo 操作将不可逆，重新执行本面板的相关功能将会重新安装所需功能，所有设置都将初始化（包括数据库用户信息）
    timearea=$(date -R)
    echo 为了顺利执行本面板的清理，请确定当前时区正确（"$timearea"）
    read -e -p "是否要修改当前时区[y/N]"   SL ##询问是否需要
    echo "$SL" | grep -q -E '^[Yy]$' && {   ##满足是
    dpkg-reconfigure tzdata
    }
    read -e -p "即便如此也要进行这个操作？默认为No，确定请输入小写yes[yes/NO]"   SL ##询问是否
    echo "$SL" | grep -q -E 'yes' && {   ##满足
        read -e -p "真的要进行这个操作？真的是不可逆的操作！！！[确定请输入本面板的管理授权密码：yuki233.com]"   SL ##询问是否
        test "$SL" = "yuki233.com" && {   ##满足
            read -e -p "这将是最后一遍确认，真的确定要执行？确定请输入现在的时间（2位小时数）[24小时制]"   SL ##询问
            time=`date +%H`
            test "$SL" = "$time" && {   ##满足
            echo 即将删除
            apt autoremove -y *nginx* php* mysql* *certbot*
            echo 程序已卸载完成
            rm -rf $WR
            echo 已删除默认站点目录$WR下的所有文件
            rm -rf $NGSR/sites-enabled/
            echo 已释放域名绑定
            rm -rf /var/lib/mysql/
            echo 已清空数据库
            rm -rf $NGSR/yukicpl_check_point
            echo 已更新面板检查点
            rm -rf /etc/letsencrypt/
            echo 已清理ssl证书配置
            echo 面板清理已完成，本面板将会自动退出，如有需要可手动执行“rm -f /usr/local/bin/[本面板的文件名]“彻底移除本面板
            quit
            }
        }
    }
    )

chown()(
    echo 使用本工具可以重置所有在$WR文件夹中的文件的所属权限归www所有
     /bin/chown -R www-data "$WR"
)

dnc()(   ##更换域名
    echo 将会按照规则批量修改域名绑定
    echo 请确定新域名已正确接入本服务器
    echo 功能开发中，暂不可用

)

tmgr()(     ##查看系统状态
    echo 查看系统状态
    ## 检测 htop 
    which htop >/dev/null || apt install -y htop
    ## 执行~~
    htop
)

quit(){     ##退出
    echo 已退出面板√
    exit
}

##################以下内容为自用##################

_check_nginx(){
    ## 检测 nginx、php-fpm 等
    { which nginx && which php-fpm7.0 && { echo /etc/php/7.0/mods-available/* | grep gd.ini | grep sqlite3.ini | grep mbstring.ini ; }
    } >/dev/null || apt install -y  nginx-full php-fpm php-cgi php-curl php-gd php-mcrypt php-mbstring php-sqlite3 php7.0-mysql
    _check_mysql
}

_check_mysql()(
    which mysql >/dev/null || {
        echo mysql服务器未安装
        echo 将会自动进行安装
        apt install -y mysql-server
        mysql_secure_installation
    }
)

_check_certbot(){
    ## debian 9 自带的 certbot 0.10.* 有问题不支持 cname 域名申请证书，所以需要修改掉默认版本
    ## @TODO: 要改为更快速的判断方法
    ## 先判断有 certbot nginx 支持      &&    再判断 certbot 版本不是 debian 9 自带的 0.10.*  || 否则就安装或升级
    certbot --help | grep ' --nginx'    &&    certbot --version 2>&1 | grep -v -q ' 0.10.'    || {
        ## 判断是否 debian 9 （debian 9 的名字是 stretch）
        grep -q stretch /etc/apt/sources.list && {
            ## 添加 stretch-backports 升级源
            echo -e 'deb http://ftp.debian.org/debian/ stretch-backports main \ndeb-src http://ftp.debian.org/debian/ stretch-backports main'  > /etc/apt/sources.list.d/stretch-backports.list
            apt update
            apt install -y python-certbot-nginx -t stretch-backports
        } || {
            add-apt-repository -y -u ppa:certbot/certbot
            apt install -y python-certbot-nginx
        }
    } || return
}

back()(     ##返回主菜单
    help
)

####################我是分割线####################

echo " $@" | grep -q ' -t' && TEST=1    ## 如果启动命令行参数有 -t 则使用测试模式，不执行命令

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
