#!/bin/bash 

apt install -y aria2    ##安装Aria2




mkdir -p /yuki/site/dl.sm.moeyuki.works   ##创建站点目录



sudo adduser dl ##创建一个名为dl的用户

sudo chown -R dl  /yuki/site/dl.sm.moeyuki.works/download/    ##授权用户dl拥有./download/的访问权