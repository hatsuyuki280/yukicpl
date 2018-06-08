#!/bin/bash 
##雪次元服务器管理面板位于 
## 注： xxx()( yyyy; ) 或 xxx(){ yyyy; } 表示定义 bash 函数，函数名 xxx，函数内容为执行 yyyy
##     其中 圆括号版是在新建 bash 里执行里边的命令，而花括号版是在当前 bash 里执行

test -a /usr/bin/sudo || sudo()( su -c "$@";)   ##自动申请sudo权限

test -e ~/.yukicpl/yukicpl.conf || {    ##启动检测
    echo "由于系统检查不到设置文件的存在
    （当前用户的用户文件夹下的/.yukicpl文件夹内的yukicpl.conf文件）
    因此现在将会进行本面板的配置，如果未完成设置，将不会保存
    当前进行的一切设置均可在今后使用过程中随时修改
    "
    echo '请在这里输入希望使用的根域名，输入后将可以仅输入二级域名部分完成站点域名绑定
    如希望创建的域名为www.example.com则在这里输入
    “example.com”(不包含引号) 即可在后续创建站点时输入“www”进行绑定
    '
    while test -z "$input_1" ; do
    read -e input_1
    echo "$input_1" | grep -q -E '^[.a-zA-Z0-9-]+$' || {
        echo 输入有误，请重试
        input_1=""
    }
    done
    echo '请在这里输入希望作为站点默认存储位置的路径
    请输入以"/"开始，不要以"/"结尾的绝对路径
    留空将会默认使用“/yuki/site”
    >'
    while test -z "$input_2" ; do
    read -e input_2
    test -z "$input_2" && {
        input_2="/yuki/site"
        echo "将使用$input_2作为默认存储位置"
        break
    }
    done
    echo '如果安装过MonaServer，请输入MonaServer的安装路径
    执行文件应在这个文件夹里，如未安装过MonaServer，请保持此处为空！
    留空将会自动部署nginx直播服务器
    '
    while test -z "$input_3" ; do
    read -e input_3
    test -z "$input_3" && {
        break
    } || {
        echo ...
        ##检查正确性
    }
    echo 输入有误，请重试
    done
    echo "是否希望使用Mysql?
    （如果选择否将会默认使用Sqlite作为数据库）
    备注，较低配置（500MB内存以下设备）的设备以及部分设备将可能由于种种原因无法正常使用Mysql服务器，如强行启用将会影响性能。如果启用后发现无法正常使用请重新进行设置。
    "
    read -e -p "Yes(No)，默认为yes
    >"   Input_sql ##询问是否需要
    test "$Input_sql" = "no" && {
        input_4="N"
    } || {
        input_4="Y"
    }
    test "$Input_sql" = "n" && {
        input_4="N"
    } || {
        input_4="Y"
    }
    test "$input_4" = "Y" && {
        echo '请输入打算用于存放数据库文件的目录
        输入的内容应该是以"/"开始，不要以"/"结尾的绝对路径
        如果不存在将会自动创建，留空自动使用默认目录/yuki/data/db
        >'
        read -e input_5
        test -z "$input_5" && {
            input_5="/yuki/data/db"        
        }
    }
    echo 设置到此为止

    mkdir -p ~/.yukicpl
    cat >> ~/.yukicpl/yukicpl.conf <<OOO
##这是默认的一级域名部分
DDN="$input_1"   ##请务必修改的部分

##这是默认网站所在的目录(绝对路径，以"/"开始，不要以"/"结尾)
WR="$input_2"     ##请务必修改的部分

##这里是MonaServer的安装路径(执行文件应在这个文件夹里，否则将会自动部署nginx直播服务器)，直播用
LP="$input_3"

##是否使用Mysql
Sqlt="$input_4"

##mySql数据文件将在这里
Sqlp="$input_5"
OOO
    input_1=""
    input_2=""
    input_3=""
    input_4=""
    Input_sql=""
    input_5=""
}

##设置部分↓↓↓

##将会从配置文件读取
source ~/.yukicpl/yukicpl.conf
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
   |    vpn  * VPN工具          ----  * 功能开发中        dnc  * 批量改域名*   |
   |   list  * 查看网站列表     ----  * 功能开发中       tmgr  * 系统状态      |
   |    del  * 删除站点         ----  * 功能开发中       quit  * 退出面板      |
    ==========================================================================='
)

##第一列内容##

o()(        ##启用服务器（Ngnix、PHP、[MySQL]、[]）
    _check_nginx
    echo 启动 MySQL 服务器
    sqlo
    echo 开启 PHP 服务器
    $PP start
    echo 开启 nginx 服务器
    set -x
    $NGP start
)

s()(        ##关闭服务器
    echo 关闭 nginx 服务器
    set -x
    $NGP stop
    $PP stop
    sqls
)

r()(        ##重启服务器
    _check_nginx
    echo 重启MySQL
    sqlr
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
    echo "$DN" | grep -q -E '^[.a-zA-Z0-9_]+[.a-z]$' && { ##合法的有效域名
        SITE="$DN"
        echo 将使用$SITE作为站点绑定的域名
    } || {  ##不合法的
            echo "$DN" | grep -q -E '^[.a-zA-Z0-9_]+$' && { ##可以作为二级域名注册
                    read -e -p "域名不是很合法，是否使用默认的“ $DDN ” 作为一级域名？[Y/N]"   SL
                    ##提示输入....read -e -p  "提示信息"  变量名字
                echo "$SL" | grep -q -E '^[YyNn]$' && { ##满足Y或N
                        test "$SL" = "y" && {   ##满足Y
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
    echo "## 自动申请 Let’s Encrypt 免费 https 证书"
    ## 如果系统还没有 certbot --nginx 则尝试安装 python-certbot-nginx
    _check_certbot
    ## 注：certbot 具体用法可以在 bash 下执行 man certbot 查看
    ##     --nginx 参数表示对 nginx 服务器配置，
    ##     --preferred-challenges tls-sni 表示使用 443 端口验证申请
    ##     --redirect 参数表示将 80 端口 http 访问重定向到 443 端口 https 地址
    ##     --keep 参数表示保持已经申请过的证书
    ## 因为 Let’s Encrypt 不再支持 --nginx 自动申请，所以得改为 --authenticator webroot --installer nginx
    #certbot --agree-tos --nginx --preferred-challenges tls-sni --redirect --keep --register-unsafely-without-email -d "$SITE" && {
    for i in $(seq 2); do
        certbot --authenticator webroot --installer nginx --webroot-path "$WWWDIR" --redirect --keep --register-unsafely-without-email -d "$SITE" && break
        test "$i" = 2 && break
        echo "申请 $SITE 的 ssl 证书失败， 将在 30 秒后自动再次尝试申请…"
        ## 计时 30
        for t in $(seq 30); do
            echo -n "$t…"
            sleep 1
        done
        echo
    done
    test -a /etc/letsencrypt/live/$SITE/fullchain.pem && {
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
    $NGP stop
    certbot --agree-tos --authenticator standalone --installer nginx --redirect --keep --register-unsafely-without-email && {
        ## 新版 certbot 生成的配置文件里 redirect 被注释了，所以用下边的 sed 命令开启将 http 访问转到 https
        sed -i '/# Redirect non-https traffic to https/,/# } # managed by Certbot/s/# Redirect non-https traffic to https/if ($scheme != "https") { return 301 https:\/\/$host$request_uri; } # Redirect http to https/g' "$NGSR/sites-enabled/"*
    }
    pkill nginx
    $NGP start
    which crontab > /dev/null || { echo "使用 cron 定时自动续期证书" ; apt install -y cron ; }
    echo -e "0 0 1 * * /usr/bin/certbot renew --force-renewal \n9 0 1 * * $NGP restart " > /etc/cron.d/certbot-renew
    echo -e "## 手动续期可以在 shell 下执行命令\n    certbot renew"
)



sql()(      ##SQL服务器管理界面（未完成）
    test "$Sqlt" = "N" && {
        echo 您当前并未启用Mysql功能，请检查设置，如无需使用mysql，将默认使用sqlite，无需额外设置
        break
    } || {
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
    }
)

#### sql 控制面板用指令 ####\

sqlo()(     ##启动sql
    echo 正在启动sql
    service mysqld start
    echo sql服务器已启动
)

sqls()(   ##停止sql
    echo 正在停止sql
    service mysqld stop
    echo sql服务器已停止
)

sqlr()(   ##重启sql
    echo 正在重启sql
    service mysqld restart
    sql服务器已重新启动
)

sqlb()(   ##备份/导出

    echo 请选择想要备份/导出
    echo 功能未编写完成，导出已结束
)

recov()(  ##恢复/导入
    echo 请选择需要导入的文件
    echo 功能未编写完成，导入已结束
    true
)

user()(   ##列出用户
    sudo mysql -e "select distinct user from mysql.user;"
)

pwsee()(  ##查询某个数据库或某个用户的密码
    true
)

adusr()(  ##添加一个新用户并配置数据库权限
    echo "使用本向导将会建立一个用于连接到数据库的用户"
    read -e -p "请在这里输入打算创建的用户名称并按回车键。
        用户名称应由英文及或数字的组合组成，
        如果没有输入任何内容，或者输入了与现有用户重复的用户名
        将会使用随机字符作为用户名
        >"   USERNAME
    test -z "$USERNAME_" && {
        USERNAME=user$RANDOM$RANDOM
    }
    echo $(sudo mysql -e "select distinct user from mysql.user;") | grep -q -E "$USERNAME_" && {
        USERNAME=user$RANDOM$RANDOM
    } || {
        USERNAME=$USERNAME_
    }
    read -e -p "请在这里输入打算创建的用户的密码并按回车键。
        如果没有输入任何内容，将会使用随机字符作为密码
        >"   PASSWORD
    test -z "$PASSWORD" && {
        PASSWORD=$( head -c 22 /dev/urandom | base64 | head -c 20 )
    }
    sudo mysql -e "create user '$USERNAME'@localhost identified by '$PASSWORD';"
    echo 用户 $USERNAME 创建成功,密码为$PASSWORD
    SL=""
    read -e -p "是否需要绑定数据库权限？(Y/n)" SL
    echo "$SL1" | grep -q -E '^[Nn]$' && {
        true
    } || {
        echo "请在下面的列表里选择一个数据库，并输入完整数据库名"
        sudo mysql -e 'show databases'
        echo "如果现在想创建新库，请输入新的库名，本面板将会帮助你完成创建"
        read -e -p "   >" DATABASENAME_
        echo $(sudo mysql -e 'show databases') | grep -q -E "$DATABASENAME_" && {
            DATABASENAME=$DATABASENAME_
        } || {
            DATABASENAME=$DATABASENAME_
            sudo mysqladmin create "$DATABASENAME"
        }
        sudo mysql -e "grant select,insert,update,delete on $DATABASENAME.* to '$USERNAME'@'localhost' "
    }
    flush
)

rmusr()(  ##移除一个用户并询问移除同名数据库
    sudo mysql -e "revoke select,insert,update,delete on $DATABASENAME.* from '$USERNAME'@'host';"
    echo "$SL1" | grep -q -E '^[Nn]$' && {
)

root()(   ##操作root用户密码，实现显示密码和修改密码功能（软修改和强行修改最好都有）
    true
)

sqlchk()( ##列出所有数据库名
    sudo mysql -e 'show databases'
)

addsql()( ##手动添加一个数据库
    echo 您当前正在创建一个数据库，请根据提示输入相应的内容以完成创建。
    echo "为了方便您管理，我们为您列出了所有已经存在的数据库名。"
    sudo mysql -e 'show databases'
    DATABASENAME_=""
    read -e -p "请在这里输入打算创建的数据库名并按回车键：
        合法的数据库名称应由英文及或数字的组合组成，可包括的符号为“ _ ”
        如果没有输入任何内容，将会使用日期作为数据库名
        但是为了方便管理，还请务必自行输入。
        *如果输入了重复的数据库名，将会直接进入绑定用户环节，输入“ C ”取消
        >"   DATABASENAME_   ##读入数据库名
    echo "$DATABASENAME_" | grep -q -E '^[Cc]$' && {
        break
    }
    test -z "$DATABASENAME_" && {
        DATABASENAME=$(date +"%Y_%m_%d_%H_%M_%S")
    }
    SL1=""
    read -e -p "是否需要创建一个新用户名与该数据库绑定？（Y/n）
        >"   SL1   ##是否创建新用户
    echo "$SL1" | grep -q -E '^[Nn]$' && { ##不创建
        echo "请在下面的列表里选择一个用户，并输入该用户的完整用户名"
        sudo mysql -e "select distinct user from mysql.user;"
        echo "如果现在想创建新用户，请输入新用户名，将会以随机密码创建一个指定用户名的用户"
        read -e -p "   >" USERNAME_
        echo $(sudo mysql -e "select distinct user from mysql.user;") | grep -q -E "$USERNAME_" && {
            USERNAME=$USERNAME_
        } || {
            USERNAME=$USERNAME_
            mysql -e "create user '$USERNAME'@localhost identified by "$( head -c 22 /dev/urandom | base64 | head -c 20 )";"
        }
    } || {   ##创建
        read -e -p "您选择了是，请输入一个您打算创建的新用户名，如为空将会自动生成一个随机值作为用户名
        >" USERNAME
        test -z "$USERNAME" && {
            USERNAME=user$RANDOM$RANDOM
        }
        read -e -p "为了您的数据库安全，请输入一个密码，安全的密码应包括大小写字母、数字及符号其中的至少两种
            如未进行任何输入，将会自行生成一串数字作为密码，但为了保证安全并防止忘记，请尽快修改
            >" PASSWORD
        test -z $PASSWORD && {  ##如为空则自动赋值随机值
            PASSWORD=$( head -c 22 /dev/urandom | base64 | head -c 20 )
        }
        mysql -e "create user '$USERNAME'@localhost identified by '$PASSWORD';"
    } 
    echo $(sudo mysql -e 'show databases') | grep -q -E "$DATABASENAME_" && {
        DATABASENAME=$DATABASENAME_
    } || {
        DATABASENAME=$DATABASENAME_
        sudo mysqladmin create "$DATABASENAME"
    }
    sudo mysql -e "grant select,insert,update,delete on $DATABASENAME.* to '$USERNAME'@'localhost' "

    echo "完成，数据库名为$DATABASENAME
      用户名为$USERNAME
      密码为$PASSWORD"
    flush
)

delsql()( ##手动移除一个数据库
    echo "请从下列数据库中选择需要删除的数据库
        *如未进行备份将无法回复！！"
    sudo mysql -e 'show databases'
    read -e -p "你想删除哪一个？" DATABASENAME
    echo $(sudo mysql -e 'show databases') | grep -q -E "$DATABASENAME" && {
        SL=""
        read -e -p "你真的要删除么？（y/N）" SL
        echo "$SL" | grep -q -E '^[Yy]$' && {
            sudo mysqladmin drop "$DATABASENAME" && {
                echo "已成功移除数据库"
            } || {
                echo "数据库不存在！"
            }
        }
    }
    
)

conf()(   ##数据库设置（虽然不知道应该放些什么进去）
    true
)

#### sql 控制面板用指令 ####/

vpn()(       ##用于控制ShadowS-lib(未完成)
    #wget ~/.yukicpl/shadowsocks-libev_cpl.sh https://raw.githubusercontent.com/hatsuyuki280/yukicpl/master/%E8%BF%90%E8%A1%8C%E7%BB%84%E4%BB%B6/shadowsocks-libev_cpl.sh
    _vpntest
    echo '
     ///////////////////////[ 初雪服务器控制面板 -VPN- ]\\\\\\\\\\\\\\\\\\\\\\\\
     ***********************[ Yuki -VPN- Control Panel ]************************
     ===========================================================================
    |   vpno  * 开启服务器*   vpnauto  * 自动部署       vpnins  * 安装SS服务端* |
    |   vpns  * 关闭服务器*      ----  * 功能开发中      vpnrm  * 卸载SS服务端* |
    |   vset  * 修改设置         ----  * 功能开发中       back  * 返回主菜单    |
     ==========================================================================='
)

#### SS 控制面板用指令 ####\

vpno()(
    true
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
    echo "$DN" | grep -q -E '^[.a-z0-9_]+[.a-z]$' && {
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

sqlf(){
    echo "当前MySQL服务器状态如下："
    mysql -e status ##查看MySQL服务器状态
}

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
            apt install -y libnginx-mod-rtmp -t stretch-backports
        } 
    }
        rm $NGSR/yukicpl_check_point/.liveadd.tmp
        read -e -p "是否需要同时直播至其他站点？[y/N]"   SL
        while [ "$SL" = "Y" -o "$SL" = "y" ] ; do  ##是否继续添加
            while test -z "$live_url" ; do  ##检查$SITE变量是否存在(不存在执行)
                echo "请输入需要转播的直播站点（rtmp协议，格式如下）"
                echo "(直接从直播地址的域名开始)live.example.com/直播码(直播密钥)"
                read -e live_url           
                echo "$live_url" | grep -q -E '^[.a-zA-Z0-9-\/]$' && { ##合法的有效域名
                echo "push rtmp://$live_url;">>$NGSR/yukicpl_check_point/.liveadd.tmp
                    } || {  ##不合法的
                    echo 输入的内容不合规范，请再检查一遍并重新输入
                    break ##离开当前循环&continue=继续循环
                    }
            done
        live_url="" ##初始化
        read -e -p "是否需要同时直播至其他站点？[y/N]" SL
        done

    live_url_ok=$(cat $NGSR/yukicpl_check_point/.liveadd.tmp ) ##将推流列表扔进变量里
    grep -q "rtmp" /etc/nginx/nginx.conf || cat >> /etc/nginx/nginx.conf <<OOO
rtmp {
 server{
     listen 1935;
     chunk_size 4096;

     application live {
           live on;

           $live_url_ok
          }
    }
}  
OOO
    ##修改nginx的配置为[可直播]
    test -e $NGSR/yukicpl_check_point/.livesite.conf || {  ##检查直播网站文件是否存在
        read -e -p "是否需要为直播服务添加一个站点？[Y/n]"   SL ##询问是否需要
        test "$SL" = "n" && {   ##满足否
        echo '将不配置www页面'
            } || {  ##需要
                ret=$(add | tee /dev/stderr)
                site_dir=`echo "$ret" |  grep '添加了站点.*目录位于' | grep -o '\/[0-9a-zA-Z./]*'`
                livesite=`echo "$ret" |  grep '添加了站点.*目录位于' | grep -o '[0-9a-zA-Z.]*' | head -1`
                mkdir -p "$NGSR/yukicpl_check_point"    ##记录检查点
                cat > "$NGSR/yukicpl_check_point/.livesite.conf" << OOO
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
    grep -h 直播站点 "$NGSR/yukicpl_check_point/.livesite.conf"
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
   |   ----  * 功能开发中       ----  * 功能开发中      bench  * 性能测试      |
   |   ----  * 功能开发中       ----  * 功能开发中       lang  * 安装其他语言  |
   |   ----  * 功能开发中       ----  * 功能开发中      timea  * 系统时区设置  |
   |   ----  * 功能开发中       ----  * 功能开发中       back  * 返回主菜单    |
    ==========================================================================='
)
##给常用系统设置功能用的命令##

bench()(    ##性能测试工具（bench.sh）
    echo "本工具需要从互联网执行 bench.sh 进行性能测试（脚本由 bench.sh 提供）"
    echo 测试内容包括 系统信息 IO 和 网络速度
    read -e -p "请按回车(Enter)键继续，拒绝或退出请输入c，开始后请等待完成
    >"   SL
    echo "$SL" | grep -q -E '^[cC]' && {
    true
    } || {
        wget -qO- bench.sh | bash
    }
)

lang()( ##修改系统使用的语言
    echo 请选择需要的语言
    dpkg-reconfigure locales
)

timea()( ##修改时区
    echo 当前时区为$(date -R)
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
    echo 为了顺利执行本面板的清理，请确定当前时区正确（$(date -R)）
    read -e -p "是否要修改当前时区[y/N]"   SL ##询问是否需要
    test "$SL" = "y" && {   ##满足是
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
            apt update
            apt purge --force-yes -y *nginx* php* mysql* *certbot*
            echo 程序已卸载完成
            apt autoremove -y
            rm -rf $WR
            echo 已删除默认站点目录$WR下的所有文件
            rm -rf /var/lib/mysql/
            echo 已清空数据库
            rm -rf $NGSR
            echo Nginx配置文件
            rm -rf $NGSR/yukicpl_check_point
            echo 已更新面板检查点
            rm -rf /etc/letsencrypt/
            echo 已清理ssl证书配置
            echo 面板清理已完成，请输入quit退出本面板，如有需要可手动执行“rm -f /usr/local/bin/[本面板的文件名]“彻底移除本面板
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
_flush()(
    USERNAME=""
    USERNAME_=""
    PASSWORD=""
    DATABASENAME=""
    DATABASENAME_=""
    SL=""
    SL1=""
)

_vpntest()(
    test $vpn_type = "ss" && {
        echo 更新SS控制面板
        wget ~/.yukicpl/shadowsocks-libev_cpl.sh https://raw.githubusercontent.com/hatsuyuki280/yukicpl/master/%E8%BF%90%E8%A1%8C%E7%BB%84%E4%BB%B6/shadowsocks-libev_cpl.sh
        chmod +x ~/.yukicpl/tool/shadowsocks-libev_cpl.sh
    } 
    test $vpn_type = "sstp" && {
        echo "sstp~"
        echo 你们等着吧。。。。sstp。。。还没简化到能随手使用。。。。。所以这里只是个样子。。。
        read -e -p "是否要切换到Shadowsocks-libev版？（Y/n）" SL
        echo "$SL" | grep -q -E '^[Nn]$' || {   ##否
            echo "将使用Shadowsocks作为默认vpn服务端。"
            vpn_type = "ss"
        }

    } 
)

_check_nginx(){
    ## 检测 nginx、php-fpm 等
    { which nginx && which php-fpm7.0 && { echo /etc/php/7.0/mods-available/* | grep gd.ini | grep sqlite3.ini | grep mbstring.ini ; }
    } >/dev/null || apt install -y  nginx-full php-fpm php-cgi php-curl php-gd php-mcrypt php-mbstring php-sqlite3 ##php7.0-mysql
    _check_mysql
}

_check_mysql()(
    test "$Sqlt" = "Y" && {
        which mysql >/dev/null || {
            echo 如果mysql服务器未安装将会自动进行安装
            test 
            apt install -y mysql-server
            ##      这里其实打算修改数据库的存储路径的
            ##sqls
            ##mkdir $Sqlp/
            ##mv /var/lib/mysql　$Sqlp/
            ##
            mysql_secure_installation   ##进行初期设置
            apt install -y php7.0-mysql
        }
    } || {
        ##将只安装sqlite
        apt install -y php-sqlite3
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
