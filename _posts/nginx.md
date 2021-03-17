---
layout: post
title: "My 1st 运维日志"
excerpt: "测试运维日志"
categories:
  - 
tags:
  - nginx
last_modified_at: 2021-03-17T12:26:59-05:00
---


## Nginx 使用 shell 安装

``` bash
#!/bin/bash
#

insdir=/usr/local/nginx
pw=`pwd`

tarname=`ls -l |grep '^-.*nginx-1.*tar\.gz$'| awk '{print $9}'`
tar xf $tarname && pr "解压源码包成功" 1  ||pr "解压源码包失败" 2
tardir=`ls -l |grep '^d.*nginx-1.*'| awk '{print $9}'`
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

yum install -y  lrzsz  screen lsof gcc gcc-c++ \
glibc glibc-devel pcre pcre-devel openssl openssl-devel systemd-devel net-tools iotop bc \
zip unzip zlib-devel bash-completion nfs-utils automake libxml2 libxml2-devel \
libxslt libxslt-devel perl perl-ExtUtils-Embed -y >/dev/null 2>&1 && \
pr "安装开发包" 1 ||pr "安装开发包" 2

mkdir -p $insdir && pr "创建安装路基目录" 1 ||pr "创建安装路基目录" 2
echo "执行configure 请稍后 "

cd $pw/$tardir
./configure --prefix=$insdir/ \
--user=nginx \
--group=nginx \
--with-http_ssl_module \
--with-http_v2_module \
--with-http_realip_module \
--with-http_stub_status_module \
--with-http_gzip_static_module \
--with-pcre \
--with-stream \
--with-stream_ssl_module \
--with-stream_realip_module  >/dev/null 2>&1 && \
pr "执行configure" 1 ||pr "执行configure" 2
echo "make install 中 请稍等 "
make >/dev/null 2>&1 && make install >/dev/null 2>&1 && \
 pr "make install" 1 ||pr "make install" 2
 
useradd nginx -s /sbin/nologin -u 2000
chown nginx.nginx -R $insdir/ 

ln -s $insdir/sbin/nginx  /usr/sbin/nginx >/dev/null 2>&1
echo "[Unit] 
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=$insdir/logs/nginx.pid


ExecStartPre=/usr/bin/rm -f $insdir/logs/nginx.pid 
ExecStartPre=$insdir/sbin/nginx -t
ExecStart=$insdir/sbin/nginx
ExecReload=/bin/kill -s HUP \$MAINPID

#KillSignal=SIGQUIT
#TimeoutStopSec=5
KillMode=process
PrivateTmp=true

[Install]
WantedBy=multi-user.target" > /usr/lib/systemd/system/nginx.service && \
pr "创建服务脚本" 1 ||pr "创建服务脚本" 2

echo "export NGINX_HOME=$insdir
export PATH=\$PATH:\$NGINX_HOME/sbin" >/etc/profile.d/nginx.sh && \
pr "配置环境变量" 1 ||pr "配置环境变量" 2
source /etc/profile.d/nginx.sh
systemctl daemon-reload && \
systemctl start nginx  && \
systemctl enable nginx && \
pr "启动NGINX" 1 ||pr "启动NGINX" 2


```