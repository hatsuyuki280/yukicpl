apt update
apt upgrade
apt install -y postfix libsasl2-2 sasl2-bin libsasl2-modules dovecot-imapd dovecot-pop3d dovecot-common

postfix stop
service dovecot stop

mv /etc/postfix/main.cf "/etc/postfix/main.cf.$(date)"

typeset -l DDNS_ADDR    ##设置输入类型为全部小写
read -e -p "为防止意外发生，请在这里输入MX记录对应的地址，
 如yuki.yuki233.com 的 MX 解析为 mail.yuki233.com ，则
 请在这里输入 mail.yuki233.com ，如果有多个解析值，请以 
 解析值1, 解析值2, 解析值3 的样子依次输入，注意两个解析值
 之间以一个 英文 “,” 加一个半角空格 “ ” 予以区分。如解析值
 也以CNAME被解析，同样也建议一并将其解析结果按照上述结果一并
 写入   >>>" DDNS_ADDR

##接受一个域名

cat > /etc/postfix/main.cf <<000
myhostname = lolipet.moe

# TLS parameters
smtpd_tls_cert_file=/etc/letsencrypt/live/$myhostname/fullchain.pem
smtpd_tls_key_file=/etc/letsencrypt/live/$myhostname/privkey.pem
smtpd_use_tls=yes
smtpd_tls_session_cache_database = btree:${data_directory}/smtpd_scache
smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache

myorigin = $myhostname

inet_interfaces = all

mydestination = $myhostname, localhost, $DDNS_ADDR

smtpd_sasl_type = dovecot
　　smtpd_sasl_path = private/auth
　　smtpd_sasl_auth_enable = yes
　　smtpd_sasl_local_domain = $myhostname
smtpd_recipient_restrictions = permit_mynetworks,permit_sasl_authenticated,reject_unauth_destination
　　smtpd_sasl_security_options = noanonymous
      message_size_limit = 10240000
000


# postfix check   #检查 postfix 相关的档案、权限等是否正确！
# postfix start   #开始 postfix 的执行
# postfix stop    #关闭 postfix
# postfix flush   #强制将目前正在邮件队列的邮件寄出！
# postfix reload  #重新读入配置文件，也就是 /etc/postfix/main.cf
