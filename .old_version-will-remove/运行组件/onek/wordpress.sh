#!/bin/bash




echo 开始下载 Wordpress

wget https://wordpress.org/latest.zip

echo 正在解压

apt update
apt install -y unar

unar latest.zip
rm latest.zip
mv ./wordpress/* .
rm -rf ./wordpress