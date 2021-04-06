### 2.2.1 Nginx 架构

了解Master 和 worker 的关系

可以查看语句块使用范围： http://nginx.org/en/docs/

```
#allow 功能例子
Syntax:	allow address | CIDR | unix: | all;
Default:	—
Context:	http, server, location, limit_except
```

### 3.2 全局配置

nginx 优化

```shell
worker_rlimit_nofile 65536; #所有worker进程能打开的文件数量上限,包括:Nginx的所有连接（例如与代理服务器的连接等），而不仅仅是与客户端的连接,另一个考虑因素是实际的并发连接数不能超过系统级别的最大打开文件数的限制.最好与ulimit -n 或者limits.conf的值保持一致,
#最大连接数也由系统的可用socket连接数限制（~ 64K），所以设置不切实际的高没什么好处。
#链接数参考 https://blog.csdn.net/Just_shunjian/article/details/78288229

#修改pam限制
[root@centos8 ~]#cat /etc/security/limits.conf
* soft nofile 1000000
* hard nofile 1000000

events {
worker_connections 65536; #设置单个工作进程的最大并发连接数
use epoll; #使用epoll事件驱动，Nginx支持众多的事件驱动，比如:select、poll、epoll，只
能设置在events模块中设置。
accept_mutex on; #on为同一时刻一个请求轮流由work进程处理,而防止被同时唤醒所有worker,
避免多个睡眠进程被唤醒的设置，默认为off，新请求会唤醒所有worker进程,此过程也称为"惊群"，因此
nginx刚安装完以后要进行适当的优化。建议设置为on
multi_accept on; #ON时Nginx服务器的每个工作进程可以同时接受多个新的网络连接，此指令默
认为off，即默认为一个工作进程只能一次接受一个新的网络连接，打开后几个同时接受多个。建议设置为on
}
```

### 3.3 http 配置块

优化; 修改default_type 为文本 ;

```shell
#default_type        application/octet-stream; 
default_type         text/plain; #修改成txt
charset utf-8; #显示中文字符
server_tokens off; #是否在响应报文的Server首部显示nginx版本

#执行此命令查看
curl 192.168.64.101/info.php -I
```
### 3.4.1 新建一个 PC web 站点

创建 mobile 和 pc 网站; 

```sh
#先生成路径
mkdir -p /usr/share/nginx/html/{mobile,pc}

#网页
echo m.magedu.org > /usr/share/nginx/html/mobile/index.html
echo www.magedu.org > /usr/share/nginx/html/pc/index.html

```

配置server

```sh
vim /etc/nginx/conf.d/pc.conf
vim /etc/nginx/conf.d/mobile.conf

server {
	listen 80;
	server_name www.magedu.org; #改m.magedu.org
		location / {
			root /data/nginx/html/pc; #改mobile
	}
}
```



### 3.4.6 Nginx 账户认证功能

登录需要密码验证

```sh
[root@centos8 ~]# htpasswd -b /apps/nginx/conf/.htpasswd user2 123456
Adding password for user user2
[root@centos8 ~]# tail /apps/nginx/conf/.htpasswd
user1:$apr1$Rjm0u2Kr$VHvkAIc5OYg.3ZoaGwaGq/

location = /login/ {
	root /data/nginx/html/pc;
	index index.html;
	auth_basic "login password";
	auth_basic_user_file /apps/nginx/conf/.htpasswd; #需要添加密码配置
}
```



### 3.4.11 作为下载服务器配置

```sh
location / {
	root /data/nginx/html/pc;
	index index.html;
	try_files $uri $uri.html $uri/index.html /about/default.html;
	#try_files $uri $uri/index.html $uri.html =489;
}
```

### 3.4.9 检测文件是否存在

location / {
root /data/nginx/html/pc;
index index.html;
try_files $uri $uri.html $uri/index.html /about/default.html;
#try_files $uri $uri/index.html $uri.html =489;
}

### 3.4.11 作为下载服务器配置

```sh
location /download {
	autoindex on; #自动索引功能
	autoindex_exact_size on; 
	#计算文件确切大小（单位bytes），此为默认值,off只显示大概大小（单位kb、mb、gb）
	autoindex_localtime on; 
	#on表示显示本机时间而非GMT(格林威治)时间,默为为off显示GMT时间
	limit_rate 1024k; #限速,默认不限速
	root /data/nginx/html/pc;
}
```

### 4.1 Nginx 状态页

Reading 的值越大说明越worker 在排队，服务器需要提升了

Waiting 等待值有多是正常的

### 4.2 Nginx 第三方模块

开源的echo模块 https://github.com/openresty/echo-nginx-module

```sh
nginx -V #查看之前编译安装的内容

#编译安装的内容在加上 --add-module,安装后在测试
./configure #后面加上
--add-module=/usr/local/src/echo-nginx-module

make && make install
```



## 4.3.1 内置变量

使用echo 的方式显示内容

```sh
location /main {
	index index.html;
	default_type text/html;
	echo "hello world,main-->";
	echo $remote_addr ;
	echo $args ;
	echo $document_root;
	echo $document_uri;
	echo $host;
	echo $http_user_agent;
	echo $http_cookie;
	echo $request_filename;
	echo $scheme;
	echo $scheme://$host$document_uri?$args;
}
```

### 4.4 Nginx 自定义访问日志

日志分析 ELK 使用 json 格式，可以把日志记录成json 根式