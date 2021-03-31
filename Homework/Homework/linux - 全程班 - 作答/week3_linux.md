### Linux

#### 1.显示/etc目录下，以非字母开头，后面跟了一个字母以及其他任意长度任意字符的文件或目录

```sh
ls /etc/[^[:alpha:]]* -l
```

#### 2.复制 /etc 目录下所有以p开头，以非数字结尾的文字或目录到/tmp/mytest1目录中。

```sh
cp -rf p*[^0-9] /tmp/mytest1/
```

#### 3.将/etc/issue 文件中的内容转换为大写后保存至/tep/issue.out 文件中

```sh
tr 'a-z' 'A-Z' < /etc/issue > /tmp/issue.out
```

#### 4.请总结描述用户的组管理类命令的使用方式并完成以下练习：

## 用户

用户创建：useradd
用户属性修改：usermod
删除用户：userdel
查看用户相关的ID信息：id
切换用户或以其他用户身份执行命令：su
设置密码：passwd
修改用户密码策略：chage

## 组

创建组：groupadd
修改组：groupmod
删除组：groupdel
更改组密码：gpasswd
更改和查看组成员：groupmems

##### （1）创建组distro，其GID为2019

```sh
groupadd distro -g 2019
getent group distro #验证distro的GID
cat /etc/group #验证
```

##### （2）创建用户mandriva， 其ID号为1005； 基本组为distro；

```sh
useradd mandriva -u 1005 -g distro
id mandriva #验证mandriva的UID号和基本组
cat /etc/passwd #验证
```

##### （3）创建用户mageia，其ID号为1100，家目录为/home/linux;

```sh
useradd mageia -u 1100 -d /home/linux
getent passwd mageia #验证结果
```

##### （4）给用户mageia添加密码，密码为mageedu，并设置用户密码7天后过期

```sh
echo "mageedu" | passwd mageia --stdin -x 7
getent shadow mageia #验证结果
```

##### （5）删除mandriva， 但保留其家目录

```sh
userdel mandriva
ls /home/ #验证结果 mandriva目录依旧存在
```

##### （6）创建用户slackware，其ID号为2002，基本组为distro，附加组peguin

```sh
groupadd peguin
useradd slackware -u 2002 -g distro -G peguin
id slackware #验证结果
```

##### （7）修改slackware的默认shell为/bin/tcsh;

```sh
#方式1
chsh slackware -s /bin/tcsh
getent passwd slackware #验证结果

#方式2
usermod -s /bin/tcsh slackware
```

##### （8）为用户slackware 新增附加组admins,并设置不可以登录

```sh
groupadd admins
usermod slackware -G admins -s /sbin/nologin
```



##### 5.创建用户user1，user2，user3. 在/data/ 下创建目录test

```sh
name=user;for i in {1,2,3};do useradd $name$i;done
```

##### （1）目录/data/test 属主，属组为user1

```sh
mkdir /data/test
chown user1:user1 /data/test/
```

##### （2）在目录属主，属组不变的情况下，user2对文件有读取的权限

```sh
setfacl -m u:user2:rx /data/test
```

##### （3）user1在/data/test 目录下创建文件a1.sh,a2.sh,a3.sh,a4.sh, 设定所有用户都不可以删除1.sh,2.sh文件，除了user1以及root之外，所有用户都不可以删除，a3.sh,a4.sh

```sh
touch a{1..4}.sh
chattr +i a1.sh a2.sh 
chmod a+t a3.sh a4.sh
```

##### (4)user3增加附加user1，同时user1不能访问/data/test 目录及其下所有文件

```sh
usermod -aG user1 user3
setfacl -mR u:user1:--- /data/test/
```

##### (5)清理/data/test 目录及其下所有文件的acl权限

 ```sh
chattr -i a1.sh a2.sh 
setfacl -Rb /data/test/
 ```



 

 