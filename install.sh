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
scrape_configs:
  - job_name: "prometheus"
    static_configs: 
      - targets: ["localhost:9090"]
EOF
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
apt-get install -y python3-pip
pip install prometheus-client
snap install jq

