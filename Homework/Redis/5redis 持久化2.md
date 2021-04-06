### 2.3.4.2.4 实现RDB方式

使用python 导入数据生产500万调数据，数据多可以就可以看到子进程生成的过程

bgsave: 进程后台执行,不影响其它命令的执行

```sh
#手动测试保存
redis-cli -a 123456 bgsave
```

![image-20210401114307501](image\image-20210401114307501.png)

### 2.3.4.2.4 实现RDB方式

PDF 执行脚本保存，可以做定时任务保存

```sh
. /etc/init.d/functions
BACKUP=/backup/redis-rdb
DIR=/apps/redis/data
FILE=dump-6379.rdb
PASS=123456

redis-cli -h 127.0.0.1 -a $PASS --no-auth-warning bgsave 
result=`redis-cli -a 123456 --no-auth-warning info Persistence |grep rdb_bgsave_in_progress| sed -rn 's/.*:([0-9]+).*/\1/p'`
until [ $result -eq 0 ] ;do
    sleep 1
    result=`redis-cli -a 123456 --no-auth-warning info Persistence |grep rdb_bgsave_in_progress| sed -rn 's/.*:([0-9]+).*/\1/p'`
done
DATE=`date +%F_%H-%M-%S`
[ -e $BACKUP ] || { mkdir -p $BACKUP ; chown -R redis.redis $BACKUP; }
mv $DIR/$FILE $BACKUP/dump_6379-${DATE}.rdb
action "Backup redis RDB"
```



把dump.rdb删除，然后重启redis。 redis-cli info 查看 #keyspace 值是空的

还原方式是把 dump.rdb 转移回来dump.rdb 的路径重启就会恢复。 注意：名字和路径要放对



### 2.3.4.2 AOF 模式

AOF 是追加模式，会快很多

开启AOF 到 redis.conf

```sh
appendonly yes #改为yes
```

### 范例: 启用AOF功能的正确方式

<font color="#dd0000">要注意不能通过配置文件修改，不能通过配置文件修改会把文件rdb 文件给覆盖</font>

1. 先通过redis-cli 里做修改，这举动会从rdb复制一份去aof
2. 在到配置文件里做修改，然后操作重启也不会影响了

```sh
#在redis-cli 模式里开启
config set appendonly yes
config get appendonly #确认是yes

#查看路径会看到appendonly 日志
-rw-r--r-- 1 redis redis 87989196 Apr  5 22:27 appendonly.aof
-rw-r--r-- 1 redis redis 87989196 Apr  4 00:29 dump-6379.rdb

#永久生效才到redis.conf 修改为yes
appendonly yes
```



查看实时数据

```sh
pstree -p |grep redis-server
```

### AOF rewrite 过程

比如你要删除以前的数据，但是无法正常删除，只能通过 rewrite的方式来处理

### 2.3.4.2.3 AOF 相关配置

主要的配置系信息可以参考 2.3.1

比如你要删除以前的数据，但是无法正常删除，只能通过 rewrite的方式来处理

```sh
appendonly yes
appendfilename "appendonly-${port}.aof"
appendfsync everysec
dir /path
no-appendfsync-on-rewrite yes
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
```

修改名让人不轻易收入执行

```sh
rename-command keys "XxxXxxX"  #keys * 同时显示所有的值会导致服务器崩溃
rename-command flushdb "ansonyeancommand"
rename-command flushall ""
```

#### redis攻击或入侵

避免被攻击，一定要设定redis 安全密码和运行使用redis