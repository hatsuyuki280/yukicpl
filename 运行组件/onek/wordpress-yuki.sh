




echo 开始下载 Wordpress

wget https://wordpress.org/latest.zip

echo 正在解压

apt update
apt install -y unar

unar latest.zip
rm latest.zip
mv ./wordpress/* .
rm -rf ./wordpress

echo 正在获取某dalao的主题包

git clone https://github.com/xb2016/kratos-pjax.git ./wp-content/themes/kratos-pjax/

typeset -l R18
echo 内含可爱的live2d角色的那种插件也一起装上好啦~
read -e -p "要不要使用R18模型？
 新版本的动态角色将会有R18内容在里面，
 请谨慎选择。（N/y）" R18
test "$R18" = "y" && {      ##安装R18
    wget -P ./wp-content/plugins https://github.com/xb2016/poster-girl-l2d-2233/archive/1.5.zip ##补充辅助下载链接|| wget -o ./wp-content/plugins/1.3.zip https://github.com/xb2016/poster-girl-l2d-2233/archive/1.3.zip
} || {      ##不安装R18
    wget -P ./wp-content/plugins https://github.com/xb2016/poster-girl-l2d-2233/archive/1.3.zip ##补充辅助下载链接|| wget -o ./wp-content/plugins/1.3.zip https://github.com/xb2016/poster-girl-l2d-2233/archive/1.3.zip
}

echo "还有一些咱觉得常用的软件包也一并附上好了，如果不需要直接在网站前台的管理界面执行删除插件就可以了。"

echo "忘了有什么常用的插件了。。。先这样好了。。。"

unar -o ./wp-content/plugins/ ./wp-content/plugins/*
rm ./wp-content/plugins/*.zip