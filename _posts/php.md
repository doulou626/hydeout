---
layout: post
title: "My 1st 运维日志"
excerpt: "测试运维日志"
categories:
  - System Admin
tags:
  - php
last_modified_at: 2021-03-17T12:26:59-05:00
---

## PHP 使用shell 脚本安装

```bash 

#!/bin/bash

prefix=/usr/local/php
config_file_path=/usr/local/php/etc
config_file_scan_dir=/usr/local/php/etc/conf.d
user=www
phpfpm_tar_name=`ls -l |grep '^-.*php.*tar\.gz$'| awk '{print $9}'`
tar xf $phpfpm_tar_name
phpfpm_dir_name=`ls -l |grep '^d.*php.*'| awk '{print $9}'`
pw=`pwd`
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

bianyi()  {
	yum install -y gcc gcc-c++  make zlib zlib-devel pcre pcre-devel  libjpeg libjpeg-devel \
	libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel glibc glibc-devel glib2 \
	glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel \
	krb5 krb5-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers \
	pcre pcre-devel openssl openssl-devel libicu-devel gcc gcc-c++ autoconf libjpeg libjpeg-devel \
	libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel \
	glib2 glib2-devel ncurses ncurses-devel curl curl-devel krb5-devel libidn libidn-devel openldap \
	openldap-devel nss_ldap jemalloc-devel cmake boost-devel bison automake libevent libevent-devel \
	gd gd-devel libtool* libmcrypt libmcrypt-devel mcrypt mhash libxslt libxslt-devel readline \
	readline-devel gmp gmp-devel libcurl libcurl-devel openjpeg-devel sqlite-devel >/dev/null 2>&1 && pr "安装依赖开发包完成" 1 || pr "安装依赖开发包失败" 2
	

	cd $pw/$phpfpm_dir_name
	
	./configure  --prefix=$prefix --with-config-file-path=$config_file_path \
	--with-config-file-scan-dir=$config_file_scan_dir --enable-fpm --with-fpm-user=www \
	--with-fpm-group=www --with-pear --with-curl  --with-png-dir --with-freetype-dir --with-iconv   \
	--with-mhash   --with-zlib --with-xmlrpc --with-xsl --with-openssl  --with-mysqli --with-pdo-mysql \
	--disable-debug --enable-zip --enable-sockets --enable-soap   --enable-inline-optimization  \
	--enable-xml --enable-ftp --enable-exif --enable-wddx --enable-bcmath --enable-calendar   \
	--enable-shmop --enable-dba --enable-sysvsem --enable-sysvshm --enable-sysvmsg >/dev/null 2>&1 && pr "执行configure成功" 1 || pr "执行configure失败" 2
	
	pr "正在执行编译和安装过程" 1 && make >/dev/null 2>&1 && make install >/dev/null 2>&1 && pr "编译并安装成功" 1 || pr "编译或安装失败失败" 2

}

conf() {
	if id $user >/dev/null 2>&1 
	then
		pr "用户已经存在无需创建" 1
	else
		useradd $user -s /usr/sbin/nologin
	fi
	

	cp $prefix/etc/php-fpm.conf.default $prefix/etc/php-fpm.conf
	cp $prefix/etc/php-fpm.d/www.conf.default $prefix/etc/php-fpm.d/www.conf
	sed -i "s/user = www/user = $user/g" $prefix/etc/php-fpm.d/www.conf
	sed -i "s/group = www/group = $user/g" $prefix/etc/php-fpm.d/www.conf
	
	#service file
	echo "[Unit]

Description=php-fpm - Hypertext Preprocessor
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=simple
PIDFile=$prefix/var/run/php-fpm.pid
ExecStart=$prefix/sbin/php-fpm --nodaemonize --fpm-config $prefix/etc/php-fpm.conf
ExecReload=/bin/kill -USR2 $MAINPID
ExecStop=/bin/kill -SIGINT $MAINPID
PrivateTmp=false

[Install]
WantedBy=multi-user.target" > /usr/lib/systemd/system/php-fpm.service && \
	pr "服务文件创建成功" 1 || pr "服务文件生成失败" 2
}

server() {
	systemctl daemon-reload && \
	systemctl start php-fpm && \
	systemctl enable php-fpm && \
	pr "服务启动成功 并设为开机启动" 1 || pr "服务启动失败" 2
}

bianyi && \
conf && \
server && \
pr "安装过程全部完成" 1 || pr "有失败的安装过程,停止安装" 2 

```

