---
layout: post
title: "Week3 - 架构师练习题"
excerpt: "Week3 - 架构师练习题"
categories:
  - Exercise
tags:
  - exercise
last_modified_at: 2021-03-27T12:00:00-05:00
---

## 架构师练习题

##  1.ansible 安装以及常用模块使用

Ansible命令参数：

- -v：输出详细信息（可以使用多个v）
- -i PATH：指定hosts文件位置
- -f NUM ：指定开启的进程数（默认为5）
- -m MOULE ：指定module的名称（默认为command）
- -m DIRECTORY：指定module的目录来加载module，默认是/usr/share/ansible
- -a,MODULE_ARGS：指定module模块的参数
- -k：提示输入ssh的密码，而不是使用基于ssh的密钥认证
- -u USERNAME：指定移动端的执行用户

#### 1、command模块

这个模块可以直接在远程主机上执行命令，并将结果返回本主机。注意，该命令不支持 | 管道命令

```sh
命令：ansible [主机] [-m 模块] [-a args]
ansible-doc -l #列出所有安装模块（q退出）
ansible-doc -s yum #列出yum模块描述信息和操作动作
ansible all -m command -a 'date' #查询date
ansible all -a 'ls /' #如果不加-m模块，默认运行command模块
```

#### 2、cron模块

该模块适用于管理cron计划任务的。

```sh
两种状态（state）：present表示添加        absent 表示移除
ansible-doc -s cron                      #查看cron模块信息
ansible all -m cron -a 'minute="*/1" job="/usr/bin/echo heihei >> /opt/test.txt" name="test cron"'          
#-a： 指定添加参数     */1：每分钟执行      job：执行内容

ansible mysql -a 'crontab -l'        #查看crontab信息
ansible mysql -m cron -a 'name="test cron" state=absent'
```

#### 3、user模块

该模块主要是用来管理用户账号。

```sh
ansible-doc -s user
ansible all -m user -a 'name=test' #创建用户

ansible mysql -m command -a 'tail /etc/passwd'
ansible mysql -m user -a 'name=test01 state=absent' #删除用户
```

### 4、group模块

该模块主要用于添加或删除组。

```sh
ansible mysql -m group -a 'name=mysql gid=330 system=yes'
ansible mysql -a 'tail /etc/group'


ansible mysql -m user -a 'name=test02 uid=330 group=mysql system=yes'
#新建用户test02；设定UID=306；将test02添加到mysql组
ansible mysql -a 'id test02'
```



### 5、copy模块

这个模块用于将文件复制到远程主机，同时支持给定内容生成文件和修改权限等。

```sh
ansible-doc -s copy
ansible all -m copy -a 'src=/etc/fstab dest=/opt/fstab.bk owner=root mode=644'
#src:原文件 dest：复制后目标文件 owner：属主 mode：权限
ansible mysql -a 'ls -l /opt' #在控制主机上查看

ansible mysql -m copy -a 'content="hello world!" dest=/opt/hello.txt'
#复制文件hello.txt中写入“hello world！”
ansible mysql -a 'cat /opt/test.txt' #在控制主机上查看
```



### 6、file模块

该模块主要用于设置文件的属性，比如创建文件、创建链接文件、删除文件等。

```sh
ansible-doc -s file
touch /opt/file.txt
ansible mysql -m file -a 'path=/opt/file.txt owner=test02 group=mysql mode=666'
#对test文件设置属主、属组、权限

ansible mysql -m file -a 'src=/opt/test.txt path=/opt/test.txt.link state=link'
#将src指的文件链接到path指的路径下

当然，也可以创建空文件，操作相对简单
ansible mysql -m file -a 'path=/opt/abc.txt state=touch' #创建空文件
ansible mysql -m file -a 'path=/opt/abc.txt state=absent' #删除
```



### 7、ping模块

```sh
//测试被管理主机是否在线
ansible all -m ping
```



### 8、yum模块

```sh
ansible-doc -s yum
ansible webserver -m yum -a 'name=httpd' #安装httpd
ansible webserver -m yum -a 'name=httpd state=absent' #移除httpd
```

### 9、shell模块

shell模块可以在远程主机上调用shell解释器运行命令，支持shell的各种功能，例如管道等。

```sh
ansible-doc -s shell
ansible webserver -m user -a 'name=jerry'
ansible webserver -m shell -a 'echo abc123 | passwd --stdin jerry'
#创建用户，免交互设置密码
```



### 10、script模块

该模块用于将本机的脚本在被管理端的机器上运行。

```sh
在自己服务器设置脚本，其他服务器去执行
ansible-doc -s script
#!/bin/bash
echo "this is test script" > /opt/script.txt
chmod 666 /opt/script.txt #设置权限
chmod +x test.sh #为脚本添加执行权限
ansible all -m script -a 'test.sh'
```

### 11、setup模块

该模块主要用于收集信息，是通过调用facts组件来实现的。
　　facts组件是Ansible用于采集被管机器设备信息的一个功能，我们可以使用setup模块查机器的所有facts信息，可以使用filter来查看指定信息。整个facts信息被包装在一个JSON格式的数据结构中，ansible_facts是最上层的值。

```sh
ansible-doc -s setup
ansible mysql -m setup #查看mysql服务器上所有信息
```

### 12、service模块

该模块用于服务程序的管理。

```sh
ansible-doc -s service
ansible webserver -m service -a 'name=httpd enabled=true state=started'
#开启httpd服务 ； enabled：开机自启动
ansible webserver -m service -a 'name=httpd enabled=true state=stopped' #关闭httpd服务
```



## 2.使用ansible-playbook 安装Apache，并实现修改配置文件重启服务

```yml
---
- name: Enable internet services
  hosts: webserver
  become: yes
  tasks:
    - name: lastst version of httpd and firewalld #检测httpd和firewalld是否安装最新版本
      yum:
        name:
          - httpd
          - firewalld
        state: latest

    - name: test html page is configured #检测是否配置默认发布页面
      copy:
        content: "Welcome to westos!\n"
        dest: /var/www/html/index.html

    - name: firewalld enabled and running #检测火墙是否开启且处于enabled状态
      service:
        name: firewalld
        enabled: true
        state: started

    - name: firewalld permit access to httpd #检测火墙是否允许httpd服务访问
      firewalld:
        service: http
        permanent: true
        state: enabled
        immediate: yes
    - name: httpd enabled and running #检测httpd是否开启和设置开机启动
      service:
        name: httpd
        enabled: true
        state: started

- name: Test internet webserver #测试
  hosts: localhost
  become: no
  tasks:
    - name: connect to internet webserver
      uri:
        url: http://serverb.org
        return_content: yes
        status_code: 200
```



## 3.redis编译安装多实例

```sh
#!/usr/bin/env bash
#编译安装redis加上redis多实例，一台机器使用启动多个redis实例
#你要创建的实例的端口使用的位置变量

############# 编译安装 ###################
path=/usr/local/
package_name=redis-6.0.8
example_path=/app/redis #多实例的路径
IF(){
if [ $? -ne 0 ];then
    exit
fi
}
PING(){
ping -c2 www.baidu.com &>/dev/null

}
PING
IF
yum -y install gcc glibc glibc-kernheaders  glibc-common glibc-devel make
IF
yum -y install centos-release-scl
IF
yum -y install devtoolset-9-gcc devtoolset-9-gcc-c++ devtoolset-9-binutils 
IF
#echo "scl enable devtoolset-9 bash" >>~/.bashrc
source /opt/rh/devtoolset-9/enable
echo "source /opt/rh/devtoolset-9/enable" >>/etc/profile
IF
rpm -qa |grep wget
if [ $? -ne 0 ];then
    yum -y install wget
fi
wget -nc http://download.redis.io/releases/${package_name}.tar.gz
IF
tar -zxf ${package_name}.tar.gz -C ${path}

cd /usr/local/${package_name}/
make && make all
IF
######################### 多实例 ########################

if [ $# -eq 0 ];then
    echo "想要多实例,别忘了加上位置参数哟"
    echo "例如:sh 脚本名字.sh 6380 6381 6382"
    exit
fi
id redis &>/dev/null
if [ $? -ne 0 ];then
    useradd -s /sbin/nologin redis
fi

for i in $* 
do
    ls $example_path/$i/{conf,date,logs} &>/dev/null
    if [[ $? -ne 0 ]];then
        mkdir -p $example_path/$i/{conf,date,logs}
    fi
    # 复制启动程序到各实例
    cp ${path}redis-6.0.8/src/redis-server $example_path/
    # 复制配置文件。注意：此处基于单实例配置完成；
    cp ${path}redis-6.0.8/redis.conf  $example_path/$i/conf/
    # 修改程序存储目录
    sed -i  "s#^dir .*#dir $example_path/$i/date/#g" $example_path/$i/conf/redis.conf 
    # 修改其他端口信息
    sed -i  "s#6379#$i#g" $example_path/$i/conf/redis.conf
    # 允许后台允许,开启守护进程
    sed -i '/daemonize/s#no#yes#g' $example_path/$i/conf/redis.conf
    # 允许远程连接redis
    sed -i '/protected-mode/s#yes#no#g' $example_path/$i/conf/redis.conf
    # 配置日志文件
    sed -i "s#logfile \"\"#logfile \"$example_path/$i/logs/redis_$i.log\"#g" $example_path/$i/conf/redis.conf
    chown -R redis.redis $example_path/*
done
echo "redis没有启动,可以手动启动,启动$example_path/redis-server + 配置文件"
```

