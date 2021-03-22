#!/bin/bash

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

#解压
tar_tomcat=`ls -l |grep '^-.*apache-tomcat-.*tar\.gz$'| awk '{print $9}'`
tar xf $tar_tomcat && pr "解压成功" 1 ||pr "解压失败" 2
dir_tomcat=`ls -l |grep '^d.*apache-tomcat-.*'| awk '{print $9}'`

#软连接
mv $dir_tomcat /usr/local/
ln -s /usr/local/$dir_tomcat /usr/local/tomcat && pr "软连接创建成功" 1 ||pr "软连接创建失败" 2

#添加配置,并且生效
echo "export TOMCAT_HOME=/usr/local/tomcat" > /etc/profile.d/tomcat.sh && pr "配置成功" 1 ||pr "配置失败" 2

source /etc/profile.d/tomcat.sh && pr "启动成功" 1 ||pr "启动失败" 2


groupadd tomcat
useradd -s /sbin/nologin -g tomcat -d /usr/local/apache-tomcat-9.0.36/ tomcat

chown -R tomcat:tomcat /usr/local/$dir_tomcat

echo "[Unit]
Description=Tomcat 9 servlet container
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/opt/jdk"
Environment=JAVA_OPTS=-Djava.security.egd=file:///dev/urandom
Environment=CATALINA_BASE=/usr/local/tomcat
Environment=CATALINA_HOME=/usr/local/tomcat
Environment=CATALINA_PID=/usr/local/tomcat/temp/tomcat.pid
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'

ExecStart=/usr/local/tomcat/bin/startup.sh
ExecStop=/usr/local/tomcat/bin/shutdown.sh

[Install]
WantedBy=multi-user.target" > /usr/lib/systemd/system/tomcat.service && pr "Unit File 配置成功" 1 ||pr "Unit File 配置失败" 2

#新的Unit file 需要重启才能识别
systemctl daemon-reload && \
systemctl start tomcat.service  && \
systemctl enable tomcat.service && \
pr "启动Tomcat 成功" 1 ||pr "启动Tomcat 失败" 2