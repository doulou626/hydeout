参考： https://www.laofuxi.com/819.html

#### Docker 安装方式

```sh
docker run --name mysql-server -t --restart=always \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD="T5tQwSQLBLd7" \
      -e MYSQL_ROOT_PASSWORD="JTzXp8CchMVx" \
      -d mysql:5.7 \
      --character-set-server=utf8 --collation-server=utf8_bin

docker run --name zabbix-java-gateway -t --restart=always \
      -d zabbix/zabbix-java-gateway:centos-5.0-latest
	  
docker run --name zabbix-server-mysql -t --restart=always \
      -e DB_SERVER_HOST="mysql-server" \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD="T5tQwSQLBLd7" \
      -e MYSQL_ROOT_PASSWORD="JTzXp8CchMVx" \
      -e ZBX_JAVAGATEWAY="zabbix-java-gateway" \
      --link mysql-server:mysql \
      --link zabbix-java-gateway:zabbix-java-gateway \
      -p 10051:10051 \
      -d zabbix/zabbix-server-mysql:centos-5.0-latest

docker run --name zabbix-web-nginx-mysql -t --restart=always \
      -e DB_SERVER_HOST="mysql-server" \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD="T5tQwSQLBLd7" \
      -e MYSQL_ROOT_PASSWORD="JTzXp8CchMVx" \
      --link mysql-server:mysql \
      --link zabbix-server-mysql:zabbix-server \
      -p 8080:8080 \
      -d zabbix/zabbix-web-nginx-mysql:centos-5.0-latest

```

#### 查看镜像版本

```sh
docker image inspect zabbix/zabbix-web-nginx-mysql:centos-5.0-latest|grep -i version
```

