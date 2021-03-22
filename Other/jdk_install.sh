#!/bin/bash
#调function 中的action 功能
. /etc/init.d/functions
pr() {
case $2 in
1)
        ex=true
        ;;
2)
        ex=false
        ;;
*)
        echo "printout函数参数错误"
        exit 1
        ;;
esac
action "$1" /bin/$ex
}

#解压文件
tarname=`ls -l |grep '^-.*jdk-8u.*-linux-x64.tar\.gz$'| awk '{print $9}'` 
tar xf $tarname && pr "解压源码包成功" 1  ||pr "解压源码包失败" 2

dir_jdk=`ls -l |grep '^d.*jdk1.8.0_.*'| awk '{print $9}'`

ln -s /opt/$dir_jdk /opt/jdk

echo 'export JAVA_HOME=/opt/jdk
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$PATH:$JAVA_HOME/bin' > /etc/profile.d/jdk.sh && \
pr "配置成功" 1 ||pr "配置失败" 2

source /etc/profile.d/jdk.sh && pr "启动成功" 1 ||pr "启动失败" 2
echo "如果 java -version 没显示版本 "
echo "请手动执行 source /etc/profile.d/jdk.sh"
