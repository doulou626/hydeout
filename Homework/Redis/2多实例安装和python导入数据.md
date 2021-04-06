

### 2.2.5 redis 的多实例

给配置文件加上端口名

```sh
mv redis.conf  redis_6379.conf
```

修改的配置

```sh
daemonize yes #yes 可以在后台运行Redis
pidfile /apps/redis/run/redis_6379.pid #根据自己写好的路径配置
logfile /apps/redis/log/redis-6379.log #根据自己写好的路径配置
dbfilename dump_6379.rdb    #备份文件名
dir /apps/redis/data/  #指定牌坊路径
```

使用sed 修改内容，生产 6380 和 6381 配置文件

```sh
sed 's/6379/6380/g' redis_6379.conf > redis_6380.conf
sed 's/6379/6381/g' redis_6379.conf > redis_6381.conf
```

运行起来

```sh
/apps/redis/bin/redis-server /apps/redis/etc/redis_6379.conf 
/apps/redis/bin/redis-server /apps/redis/etc/redis_6380.conf 
/apps/redis/bin/redis-server /apps/redis/etc/redis_6381.conf 
```

设定默认的 Unit-file 快速修改内容 - 多实例

```sh
 mv redis.service redis6379.service
 vim redis6379.service 
 #修改文件名字
 ExecStart=/apps/redis/bin/redis-server /apps/redis/etc/redis_6379.conf --supervised systemd
 
```

复制其他端口的unit file

```sh
 cp redis6379.service redis6380.service 
 cp redis6379.service redis6381.service
 sed -i 's/6379/6380/' /lib/systemd/system/redis6380.service 
 sed -i 's/6379/6381/' /lib/systemd/system/redis6381.service
```

运行起来

```sh
systemctl daemon-reload 
systemctl enable --now redis6379 redis6380 redis6381
```



### 3.3.6.3.2 执行数据导入

for loop 的方式导入 100个数据

```sh
NUM=100
PASS=
for i in `seq $NUM`;do
    redis-cli -h 127.0.0.1 -p 6379 -a "$PASS" set key${i} value${i}
    echo "key${i} value${i} 打印"
done
echo "$NUM个key写入到Redis完成"
```



### 2.2.2.10 实战案例：一键编译安装Redis脚本

使用脚本安装，注意配置里不设定密码

/apps/redis/etc/redis.conf 注释调 requirepass 

### 2.2.4.2.2 python 连接方式

安装python环境

```sh
yum install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gcc make
wget https://www.python.org/ftp/python/3.6.2/Python-3.6.2.tar.xz
tar -xvJf Python-3.6.2.tar.xz
cd Python-3.6.2
./configure prefix=/usr/local/python3
make && make install
ln -s /usr/local/python3/bin/python3 /usr/bin/python

```



安装 Python的Redis客户端

我们需要先安装 setuptools 辅助包

```sh
wget https://bootstrap.pypa.io/ez_setup.py 
```

下载完成后执行

```sh
python ez_setup.py #执行后会安装好相应的 setuptools 辅助包
```

```sh
unzip setuptools-33.1.1.zip
cd setuptools-33.1.1
python easy_install.py redis
```



写入10000 个测试速度 , 执行命令: python redis_test.py

```python
import redis
#import time
pool = redis.ConnectionPool(host="127.0.0.1",port=6379,password="123456")
r = redis.Redis(connection_pool=pool)
for i in range(10000):
 r.set("k%d" % i,"v%d" % i)
# time.sleep(1)
 data=r.get("k%d" % i)
 print(data)
```



测试使用python 安装快很多

```sh
chmod +x redis_test.py
time ./redis_test.py
```

