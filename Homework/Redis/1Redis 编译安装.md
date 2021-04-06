### Redis 编译安装2.2.2

#安装以包

```sh
yum -y install gcc jemalloc-devel
```

\#下载源码

```sh
wget http://download.redis.io/releases/redis-5.0.9.tar.gz
tar xvf redis-5.0.9.tar.g
```

#编译安装

```sh
cd redis-5.0.9/
make PREFIX=/apps/redis install #指定redis安装目录
```

\#配置变量

```sh
echo 'PATH=/apps/redis/bin:$PATH' > /etc/profile.d/redis.sh
. /etc/profile.d/redis.sh
```

\#准备相关目录和配置文件

```sh
mkdir /apps/redis/{etc,log,data,run}
cp redis.conf /apps/redis/etc/
```





### **2.2.2.5** **编辑** **redis** **服务启动文件**

\#复制CentOS8安装生成的redis.service文件，进行修改

vim /usr/lib/systemd/system/redis.service

```sh
[Unit]
Description=Redis persistent key-value database
After=network.target
[Service]
ExecStart=/apps/redis/bin/redis-server /apps/redis/etc/redis.conf --supervised systemd
ExecStop=/bin/kill -s QUIT $MAINPID
Type=notify
User=redis
Group=redis
RuntimeDirectory=redis
RuntimeDirectoryMode=0755
[Install]
WantedBy=multi-user.target
```

**验证** **redis** **启动**

```sh
systemctl daemon-reload 
systemctl start redis
systemctl status redis
```





