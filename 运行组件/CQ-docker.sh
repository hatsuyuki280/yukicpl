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

##基础配置
port="8080" ##端口
cqdir="/yuki/bot/coolq-data"    ##酷q的数据文件夹
PW="yuki233.com"    ##远程管理的时候的密码
QAQ=""  ##机器人QQ号
name="cq-01" ##容器名称
dir="/$name"  ##子目录（可选，从 / 开始， / 指的是 $cqdir 指定的目录本身 ）
type="cqa-tuling" ##酷Q版本-必选（ cqp-xiaoi | cqp-tuling | cqp-full | cqa-tuling | cqa-xiaoi ）

su - dockers -c "docker run --name=cq-$name -d -p $PORT:9000 -v $cqdir$dir:/home/user/coolq -e VNC_PASSWD=$PW -e COOLQ_ACCOUNT=$QAQ -e COOLQ_URL=http://dlsec.cqp.me/$type coolq/wine-coolq"

docker logs coolq
docker start coolq
docker stop coolq

##启用nginx代理
cat /etc/nginx/nginx.conf | grep -q -E 'close' && {
    echo " nginx.conf 中 websocket 相关的设置未更改，如过 websocket 无法正常工作，请手动添加"
} || {
    echo " nginx.conf 中 websocket 相关的设置已添加"
    
}

##su - dockers -c "docker run --name=cq_peipei -d -p 23380:9000 -v /yuki/bot/coolq-data/cq-pei:/home/user/coolq -e VNC_PASSWD=k79muj87823 -e COOLQ_ACCOUNT=671116825 -e COOLQ_URL='http://dlsec.cqp.me/cqp-xiaoi'  coolq/wine-coolq"

##杀死所有正在运行的容器
# docker kill $(docker ps -a -q)

##删除所有已经停止的容器
# docker rm $(docker ps -a -q)

##删除所有未打 dangling 标签的镜像
# docker rmi $(docker images -q -f dangling=true)

##删除所有镜像
# docker rmi $(docker images -q)