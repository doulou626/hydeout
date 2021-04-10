wget https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-amd64.tar.gz

wget https://github.com/prometheus/alertmanager/releases/download/v0.21.0/alertmanager-0.21.0.linux-amd64.tar.gz

wget https://github.com/prometheus/prometheus/releases/download/v2.26.0/prometheus-2.26.0.linux-amd64.tar.gz



设定国际时间 ， 首先安装ntp

yum install -y ntp

systemctl enable ntpd

systemctl start ntpd

设定

timedatectl set-ntp yes



\------------------------------------------------------------

安装 Prometheus



useradd prometheus -s /sbin/nologin

tar zxvf prometheus-2.26.0.linux-amd64.tar.gz -C /data

mv /data/prometheus-2.26.0.linux-amd64 /data/prometheus

chown prometheus:prometheus -R /data/prometheus



vim /usr/lib/systemd/system/prometheus.service



[Unit]

Description=Prometheus

After=network.target

[Service]

ExecStart=/data/prometheus/prometheus --config.file=/data/prometheus/prometheus.yml --storage.tsdb.path=/data/prometheus/data

User=prometheus

[Install]

WantedBy=multi-user.target





\------------------------------------------------

安装Node Exporter





tar zxvf node_exporter-1.1.2.linux-amd64.tar.gz -C /data/

mv /data/node_exporter-1.1.2.linux-amd64 /data/node_exporter

chown prometheus:prometheus -R /data/node_exporter





vim /usr/lib/systemd/system/node-exporter.service



[Unit]

Description=Prometheus Node Exporter

After=network.target

[Service]

ExecStart=/data/node_exporter/node_exporter

User=prometheus

[Install]

WantedBy=multi-user.target





在 Prometheus 服务器 - 添加节点

vi /data/prometheus/prometheus.yml



global:

  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.

  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.

alerting:

  alertmanagers:

  \- static_configs:

​    \- targets:

​      \# - alertmanager:9093

rule_files:

scrape_configs:

  \- job_name: 'prometheus'

​    static_configs:

​    \- targets: ['localhost:9090']

  \- job_name: 'node_exporter'

​    static_configs:

​    \- targets:

​      \- 'localhost:9100'





\---------------------------------------------

安装 alertmanager

\# tar -xzvf alertmanager-0.21.0.linux-amd64.tar.gz

\# mkdir /usr/local/prometheus

\# mv alertmanager-0.21.0.linux-amd64 /usr/local/prometheus/alertmanager

mkdir -p /data/prometheus/alertmanager/data

chown -R prometheus:prometheus /usr/local/prometheus /data/prometheus



安装 Unit file

*vim /usr/lib/systemd/system/alertmanager.service*



[Unit]

Description=Alertmanager

After=network.target



[Service]

Type=simple

User=prometheus

ExecStart=/usr/local/prometheus/alertmanager/alertmanager --config.file=/usr/local/prometheus/alertmanager/alertmanager.yml --storage.path=/data/prometheus/alertmanager/data

Restart=on-failure



[Install]

WantedBy=multi-user.target





配置邮件报警



global:

  smtp_smarthost: 'smtp.gmail.com:465'

  smtp_from: 'teapod626@gmail.com'

  smtp_auth_username: 'teapod626@gmail.com'

  smtp_auth_password: 'zfdebqlbkiqtegba'

  resolve_timeout: 5m



route:

  group_by: ['alertname']

  group_wait: 10s

  group_interval: 10s

  repeat_interval: 1h

  receiver: 'web.hook'

receivers:

  \- name: 'web.hook'

​    email_configs:

​    \- to: 'teapod626@gmail.com'

​      from: 'teapod626@gmail.com'

​      smarthost: smtp.gmail.com:587

​      auth_username: "teapod626@gmail.com"

​      auth_identity: "teapod626@gmail.com"

​      auth_password: "zfdebqlbkiqtegba"

inhibit_rules:

  \- source_match:

​      severity: 'critical'

​    target_match:

​      severity: 'warning'

​    equal: ['alertname', 'dev', 'instance']





\--------------------------------------------------

安装 Grafana 



wget https://dl.grafana.com/oss/release/grafana-7.5.3-1.x86_64.rpm 

yum install grafana-7.5.3-1.x86_64.rpm



systemctl start grafana-server



修改密码登录



到Prometheus 添加grafana job配置

/etc/prometheus/prometheus.yml

...

scrape_configs:

...

  \- job_name: grafana

​    scrape_interval: 15s

​    scrape_timeout: 5s

​    static_configs:

​      \- targets: ['localhost:3000']