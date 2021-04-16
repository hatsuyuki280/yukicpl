#/bin/env python3

import argparse,os,ipaddress
from ipaddress import ip_address

parm = argparse.ArgumentParser(description="写给受喵的奇怪脚本quq")
parm.add_argument("--ip-addr","-a", metavar='ip',help="指定ip地址,默认为 127.0.0.1\nIPv6地址请包裹在方括号[]内", default="127.0.0.1",type=str)
parm.add_argument("--listen-on","-p",metavar='port',help="指定监听端口号,必选", type=int,required=True)
parm.add_argument("--debug",help="0为禁用，1为启用，启用后返回传入变量等信息。",default=0,type=int,choices=[0,1])


def main(args):
    """
    写给受喵的奇怪脚本quq
    """
    try:
        ip = str(ipaddress.ip_address(args.ip_addr))
    except Exception:
        print('错误的IP格式')
        exit(555)
    port = str(args.listen_on)
    try:
        file_target = os.open(os.path.join("./",ip+"-"+port+".conf"),os.O_CREAT)
        file_target = os.open(os.path.join("./",ip+"-"+port+".conf"),os.O_RDWR)
        os.write(file_target, bytes("""server {
    listen  """+ip+":"+port+""";
    server_name localhost;
    charset utf-8;
    location / {
        root   html/dist;
        index  index.html index.htm ;
        try_files $uri $uri/ /index.html;
    }
}""",encoding='utf8'))
        os.close(file_target)
    except IOError:
        print('写入错误')
        exit(404)
    else:
        print("写入成功!!文件名{}-{}.conf".format(ip,port))

if __name__ == "__main__" or __name__ == "":
    if parm.parse_args().debug !=0 : print(parm.parse_args())
    main(parm.parse_args())