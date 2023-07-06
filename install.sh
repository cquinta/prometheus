#!/bin/sh
mkdir /etc/prometheus
mkdir /var/lib/prometheus
mkdir /var/log/prometheus
addgroup prometheus
adduser --shell /sbin/nologin --system --ingroup prometheus prometheus
curl -LO https://github.com/prometheus/prometheus/releases/download/v2.38.0/prometheus-2.38.0.linux-amd64.tar.gz
tar -xvf prometheus-2.38.0.linux-amd64.tar.gz
mv ./prometheus-2.38.0.linux-amd64/prometheus /usr/local/bin
mv ./prometheus-2.38.0.linux-amd64/promtool /usr/local/bin
mv ./prometheus-2.38.0.linux-amd64/consoles /etc/prometheus
mv ./prometheus-2.38.0.linux-amd64/console_libraries /etc/prometheus

cat <<EOF >> /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s 
  evaluation_interval: 15s 

rule_files:
  - alertas.yml
scrape_configs:
  - job_name: "prometheus"
    static_configs: 
      - targets: ["localhost:9090"]
  - job_name: "Meu primeiro Exporter"
    static_configs:
      - targets: ["localhost:8899"]
  - job_name: "Meu segundo Exporter"
    static_configs:
      - targets: ["localhost:7788"]
  - job_name: "node-exporter"
    static_configs:
      - targets: ["localhost:9100"]
EOF

cat <<EOF >> /etc/prometheus/alertas.yml
groups: 
  - name: Meus primeiros alertas
    rules: 
    - alert: InstanceDown
      expr: up == 0
      for: 1m
      annotations:
        title: 'A máquina {{ $labels.instance}} está fora do ar'
        description: 'Urgente, precisamos voltar a máquina {{ $labels.instance }} está fora !'
      labels:
        severity: 'critical'
    - alert: LoadAverage
      expr: node_load1 > 0.5
      for: 1m
      annotations: 
        tittle: ' A {{ $labels.instance }} está com o load_average alto'
        description: ' Faça alguma coisa Mutly '
        summary: ' {{ $labels.instance }} está com o load alto'
        value: '{{ $value }}'
    - alert: DiskUsage
      expr: (node_filesystem_size_bytes - node_filesystem_free_bytes ) * 100 / node_filesystem_size_bytes > 70.0
      for: 1m
      labels:
        instance: '{{ $labels.instance }}:{{ $labels.mountpoint }}'
      annotations:
        value: '{{ humanize $value }}'
  
EOFq

cat <<EOF >> /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP \$MAINPID
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.listen-address=0.0.0.0:9090 \
  --web.external-url=

SyslogIdentifier=prometheus
Restart=always

[Install]
WantedBy=multi-user.target
EOF
chown -R prometheus:prometheus /etc/prometheus
chown -R prometheus:prometheus /var/lib/prometheus
chown -R prometheus:prometheus /usr/local/bin/prometheus
chown -R prometheus:prometheus /usr/local/bin/promtool
systemctl daemon-reload
systemctl enable prometheus.service
systemctl start prometheus
apt-get update -y
snap install docker
apt-get install -y python3-pip
pip install prometheus-client
snap install jq
cd exporter_example
cd exporter_example_python
docker build -t primeiro-exporter:0.1 .
cd ..
cd exporter_example_go
docker build -t segundo-exporter:0.1 .
docker run -d -p 8899:8899 --name primeiro-exporter primeiro-exporter:0.1
docker run -d -p 7788:7788 --name segundo-exporter segundo-exporter:0.1
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.0/node_exporter-1.6.0.linux-amd64.tar.gz
tar -xvf node_exporter-1.6.0.linux-amd64.tar.gz
mkdir /etc/node_exporter
mv node_exporter-1.6.0.linux-amd64/node_exporter /usr/local/bin
addgroup node_exporter
adduser --shell /sbin/nologin --system --ingroup node_exporter node_exporter

cat <<EOF >> /etc/node_exporter/node_exporter_options
OPTIONS="--collector.systemd"
EOF

chown -R node_exporter:node_exporter /etc/node_exporter
cat <<EOF >> /etc/systemd/system/node_exporter.service
[Unit]
Description=Node_Exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=node_exporter
Group=node_exporter
ExecReload=/bin/kill -HUP \$MAINPID
EnvironmentFile=/etc/node_exporter/node_exporter_options
ExecStart=/usr/local/bin/node_exporter $OPTIONS

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable node_exporter.service
systemctl start node_exporter
systemctl restart prometheus

wget https://github.com/prometheus/alertmanager/releases/download/v0.25.0/alertmanager-0.25.0.linux-amd64.tar.gz
tar xvzf alertmanager*
mv alertmanager /usr/local/bin
mv amtool /usr/local/bin
mkdir /etc/alertmanager
mv alertmanager.yml /etc/alertmanager
mkdir /etc/alertmanager/templates
mkdir /var/lib/alertmanager
addgroup alertmanager
adduser --shell /sbin/nologin --system --ingroup alertmanager alertmanager
chown -R alertmanager:alertmanager /etc/alertmanager
chown -R alertmanager:alertmanager /var/lib/alertmanager

cat <<EOF >> /etc/systemd/system/alertmanager.service
[Unit]
Description=Alert Manager Service
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=alertmanager
Group=alertmanager
ExecStart=/usr/local/bin/alertmanager \
          --config.file=/etc/alertmanager/alertmanager.yml \
          --web.route-prefix=/


[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable alertmanager.service
systemctl start alertmanager



# Configuração para alertas
