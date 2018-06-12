<<<<<<< HEAD
#!/bin/bash
FLAG=$1     ##传参标记
DN=$2       ##绑定的域名
DIR=$3      ##站点根目录
SQLT=$4     ##数据库类型
SQLN=$5     ##数据库名
USER=$6     ##数据库用户
PASS=$7     ##数据库密码



echo " $FLAG" | grep -q ' -flag.on' && TEST=1
=======
#!/bin/bash
FLAG=$1     ##传参标记
SITEN=$2    ##一键包名
DN=$3       ##绑定的域名
DIR=$4      ##站点根目录
SQLT=$5     ##数据库类型
SQLN=$6     ##数据库名
USER=$7     ##数据库用户
PASS=$8     ##数据库密码



echo " $FLAG" | grep -q ' -flag.on' || {
    








}
>>>>>>> c4f8a7a3332442c084635ed39e32e9d7fa41721c
