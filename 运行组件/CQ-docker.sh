#!/bin/bash 


##利用一键脚本配置docker
curl -fsSL get.docker.com -o get-docker.sh
sudo sh get-docker.sh --mirror Aliyun
sudo useradd dockers
sudo usermod -aG docker dockers
sudo systemctl enable docker
sudo systemctl start docker
echo $( su - dockers -c "docker run hello-world" ) | grep -q -E 'Hello from Docker!' && {
    echo "安装成功"
} || {
    echo "不知道发生了什么，不过安装失败了，所以安装终止了"
    install=fail
}
##安装 酷Q 的docker镜像并创建存储数据的文件夹
test "$install" = "fail" || {
    docker pull coolq/wine-coolq
    mkdir -p /yuki/bot/coolq-data
}