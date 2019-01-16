#!/bin/bash

########
### test
########

echo "Hello World"

## 发送登陆数据
curl 
'http://hkda.yunloli.com:2222/CMD_LOGIN' 
-c '.cookie.tmp'
-H 'Connection: keep-alive' 
-H 'Cache-Control: max-age=0' 
-H 'Origin: http://hkda.yunloli.com:2222' 
-H 'Upgrade-Insecure-Requests: 1' 
-H 'Content-Type: application/x-www-form-urlencoded' 
-H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36' 
-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' 
-H 'Referer: http://hkda.yunloli.com:2222/' 
-H 'Accept-Encoding: gzip, deflate' 
-H 'Accept-Language: zh-CN,zh;q=0.9,ja;q=0.8,en;q=0.7' 
-H 'x-hd-token: rent-your-own-vps' 
--data 'referer=%2F&LOGOUT_URL=%2F&username=yukiyuki&password=3L5Tkekrvejjvurh' 
--compressed
Cookie=$( sed 's/\t/\n/g' .cookie.tmp | grep session -A 1 | tail -1 )
## 发送 Cert 和 Key
-----BEGIN+PRIVATE+KEY-----
##每一行尾都有%0A
-----END+PRIVATE+KEY-----
%0A%0A
-----BEGIN+CERTIFICATE-----
##每一行尾都有%0A
-----END+CERTIFICATE-----



## 获取 cookie 的范例
curl -k -X POST -c cookie.txt --header 'Content-Type: application/json' --header 'Accept: application/json' -d 
        {“username”="admin","password"="123"} https://www.XXX.com



test python3 || {
    test apt && {
        apt install python3 -y
    } || {
        yum install epel-release -y
        yum install python35 -y
    }
}



## 设置 用户名 密码 站点域名
Username='yukiyuki'
Password='3L5Tkekrvejjvurh'
Domain='yuki.yuki233.com'

## python 的url处理模块
url_quote(){
     python3 -c 'import urllib.parse, sys; print(urllib.parse.quote_plus(sys.stdin.read()))'
}
##

## 模拟登陆 获取cookie
curl 'http://hkda.yunloli.com:2222/CMD_LOGIN' -c '.cookie.tmp' -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' -H 'Origin: http://hkda.yunloli.com:2222' -H 'Upgrade-Insecure-Requests: 1' -H 'Content-Type: application/x-www-form-urlencoded' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Referer: http://hkda.yunloli.com:2222/' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: zh-CN,zh;q=0.9,ja;q=0.8,en;q=0.7' -H 'x-hd-token: rent-your-own-vps' --data "referer=%2F&LOGOUT_URL=%2F&username=$Username&password=$Password" --compressed
## 读入cookie
Cookie=$( sed 's/\t/\n/g' .cookie.tmp | grep session -A 1 | tail -1 )
## 读入 私钥
Key=$( cat privkey.pem | url_quote | sed 's/$/\%0A/g' | tr -d '\n' )
## 读入 证书
Cert=$( cat fullchain.pem | url_quote | sed 's/$/\%0A/g' | tr -d '\n' | sed 's/-----%0A-----/-----%0A%0A-----/g' )
## post 数据
curl 'http://hkda.yunloli.com:2222/CMD_SSL?json=yes' -H 'Origin: http://hkda.yunloli.com:2222' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: zh-CN,zh;q=0.9,ja;q=0.8,en;q=0.7' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: application/json' -H 'Referer: http://hkda.yunloli.com:2222/user/ssl/paste' -H "Cookie: session=$Cookie" -H 'x-hd-token: rent-your-own-vps' -H 'Connection: keep-alive' --data "domain=$Domain&json=yes&action=save&type=paste&certificate=$Key$Cert" --compressed
curl '127.0.0.1:2222' -H 'Origin: http://hkda.yunloli.com:2222' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: zh-CN,zh;q=0.9,ja;q=0.8,en;q=0.7' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: application/json' -H 'Referer: http://hkda.yunloli.com:2222/user/ssl/paste' -H "Cookie: session=$Cookie" -H 'x-hd-token: rent-your-own-vps' -H 'Connection: keep-alive' --data "domain=$Domain&json=yes&action=save&type=paste&certificate=$Key$Cert" --compressed

