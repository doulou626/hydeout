## 全程班
### 1.统计 /etc/passwd 文件中其默认shell 为非 /sbin/login 的用户个数，并将用户都显示出来

```sh
grep -v '/sbin/nologin' /etc/passwd |wc -l
grep -v '/sbin/nologin' /etc/passwd |cut -d: -f1
```

### 2.查出用户UID最大值得用户，UID 及 shell 类型

```sh
getent passwd | sort -t: -k3 -n | tail -1 | cut -d: -f1,3,7
```

思路
1.要查有UID、用户名及shellodga，就想到了passwd，自然一开始就要getent passwd或者cat /etc/passwd
 2.要找UID最大值，就先排个序，于是就用sort，以:号分列，-t:，UID在第3列，-k3，按数字排序-n
 3.自然UID最大值的会排到最后，于是tail -1找到
 4.最后，用cut按需分别把代表：用户名、UID、shell类型的1、3、7列找出来



### 3.统计当前链接本机的每个远程主机IP的链接数，并按大到小排序

```sh
#第一种查看
ss -atun | grep ESTAB| tr -s ""|cut -d "" -f 5| cut -d : -f 1 | uniq -c | sort -nr
#第二种查看
netstat -atunl | grep "ESTABLISHED" | tr -s ""| cut -d "" -f5| cut -d: -f1 | uniq -c |sort -nr
#第三种查看
netstat -t | grep ':ssh'|tr -s ' '|cut -d ' ' -f5|cut -d: -f1 | uniq -c|sort -rn
```



### 4.编写脚本 disk.sh , 显示当前硬盘区中空间利用率最大的值

```sh
#！/bin/bash
df -h | awk '{print $5,$6}' | sed -n '2,$p' > disk.txt
temp=0
for x in `awk -F '%' '{print $1}' disk.txt`
do
    if [ $x -gt $temp ] ;then
        let temp=$x 
    fi 
done
name=`cat disk.txt | awk -F ${temp}% '{print $2}'`
echo "挂载点：$name 磁盘空间利用率最大,利用率为:$temp%"
```



### 5.编写脚本 systeminfo.sh, 显示当前主机系统信息，包过：主机名，IPv4，操控系统版本，内核版本，CPU型号，内存大小，硬盘大小

```sh
#!/bin/bash
#显示当前主机系统信息，包括:主机名，IPv4地址，操作系统版本，内核版本，CPU型号，内存大小，硬盘大小
BEGINCOLOR="\e[1;35m"
ENDCOLOR="\e[0m"

echo -e "My hostname is ${BEGINCOLOR}`hostname`$ENDCOLOR"
echo -e "IP address is ${BEGINCOLOR}`ifconfig ens33 |grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}'|head -n1`$ENDCOLOR"
echo -e "OS version is ${BEGINCOLOR}`cat /etc/redhat-release`$ENDCOLOR"
echo -e "Kernel version is ${BEGINCOLOR}`uname -r`$ENDCOLOR"
echo -e "CPU type is ${BEGINCOLOR}`lscpu|grep "Model name" |cut -d: -f2 |tr -s " "`$ENDCOLOR"
echo -e "Memtotol is ${BEGINCOLOR}`cat /proc/meminfo |head -n1 |grep -Eo '[0-9]+.*'`$ENDCOLOR"
echo -e "Disk space is ${BEGINCOLOR}`lsblk |grep 'sda\>'|grep -Eo '[0-9]+[[:upper:]]'`$ENDCOLOR"

```



### 6. 编写脚本 createuser.sh，实现如下功能:使用一个用户名做为参数，如果 指定参数的用户存在，就显示其存在，否则添加之;显示添加的用户的id号等 信息**

```sh
#!/bin/bash

#定义变量
read -p "请输入用户名字：" USERNAME
#判断用户是否存在
if `id $USERNAME &> /dev/null` ; then
#若存再显示其ID等信息
echo "用户存在，用户的ID信息为" `id $USERNAME`
#若不存在这创建用户，设定密码为随机8位数，下次登录提示修改密码，同事显示ID等信息
else
PASSWORD=`cat /dev/urandom | tr -cd [:alpha:]| head -c8`
`useradd $USERNAME &> /dev/null`
`echo "$PASSWORD" | passwd --stdin $USERNAME &> /dev/null`
echo "用户名：$USERNAME 密码： $PASSWORD" >> user.txt
`chage -d 0 $USERNAME`
echo "用户已创建，用户的ID信息为: `id $USERNAME` 密码: $PASSWORD"
fi

#删除变量
unset name passwd
```

