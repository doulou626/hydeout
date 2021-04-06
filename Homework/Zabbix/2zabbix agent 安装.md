#### 确认安装的版本和 zabbix server 一样
```sh 
wget https://cdn.zabbix.com/zabbix/binaries/stable/5.0/5.0.10/zabbix_agent-5.0.10-linux-3.0-amd64-static.tar.gz

mkdir  /usr/local/zabbix_agent
tar -xf zabbix_agent-5.0.10-linux-3.0-amd64-static.tar.gz -C  /usr/local/zabbix_agent

useradd zabbix -s /sbin/nologin
```

#### 先测试是否有开

```sh
/usr/local/zabbix_agent/sbin/zabbix_agentd -c /usr/local/zabbix_agent/conf/zabbix_agentd.conf
```



#### 安装unit file 

```sh
vim /usr/lib/systemd/system/zabbix-agentd.service

[Unit]
Description=Zabbix Agent
After=syslog.target network.target network-online.target
Wants=network.target network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/zabbix_agent/sbin/zabbix_agentd -c /usr/local/zabbix_agent/conf/zabbix_agentd.conf
RemainAfterExit=yes
PIDFile=/var/run/zabbix/zabbix_agentd.pid

[Install]
WantedBy=multi-user.target


```

#### 重启daemon 并启动agentd

```sh
systemctl daemon-reload 
systemctl start zabbix-agentd.service
```

