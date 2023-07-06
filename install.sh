#!/bin/sh

# Criando os Diretórios do Prometheus
mkdir /etc/prometheus
mkdir /var/lib/prometheus
mkdir /var/log/prometheus

# Criando os Diretórios do AlertManager

mkdir /etc/alertmanager
mkdir /etc/alertmanager/templates
mkdir /var/lib/alertmanager

# Criando os Diretórios do Node_exporter
mkdir /etc/node_exporter


# Criando usuário e grupo para o prometheus
addgroup prometheus
adduser --shell /sbin/nologin --system --ingroup prometheus prometheus

# Criando usuário e grupo para o node_exporter
addgroup node_exporter
adduser --shell /sbin/nologin --system --ingroup node_exporter node_exporter

# Criando usuário e grupo para o alertmanager
addgroup alertmanager
adduser --shell /sbin/nologin --system --ingroup alertmanager alertmanager

# Ajustando o group e user owner para os diretórios criados. 

chown -R prometheus:prometheus /etc/prometheus
chown -R prometheus:prometheus /var/lib/prometheus
chown -R prometheus:prometheus /usr/local/bin/prometheus
chown -R prometheus:prometheus /usr/local/bin/promtool
chown -R node_exporter:node_exporter /etc/node_exporter
chown -R alertmanager:alertmanager /etc/alertmanager
chown -R alertmanager:alertmanager /var/lib/alertmanager


# Instalação do Prometheus
curl -LO https://github.com/prometheus/prometheus/releases/download/v2.38.0/prometheus-2.38.0.linux-amd64.tar.gz
tar -xvf prometheus-2.38.0.linux-amd64.tar.gz
mv ./prometheus-2.38.0.linux-amd64/prometheus /usr/local/bin
mv ./prometheus-2.38.0.linux-amd64/promtool /usr/local/bin
mv ./prometheus-2.38.0.linux-amd64/consoles /etc/prometheus
mv ./prometheus-2.38.0.linux-amd64/console_libraries /etc/prometheus
cp ./config/prometheus.yml /etc/prometheus/prometheus.yml
cp ./config/alertas.yml /etc/prometheus/alertas.yml
cp ./config/prometheus.service /etc/systemd/system/prometheus.service
systemctl daemon-reload
systemctl enable prometheus.service
systemctl start prometheus





# Instalação do node_exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.0/node_exporter-1.6.0.linux-amd64.tar.gz
tar -xvf node_exporter-1.6.0.linux-amd64.tar.gz
mv node_exporter-1.6.0.linux-amd64/node_exporter /usr/local/bin
cp ./config/node_exporter_options /etc/node_exporter/node_exporter_options 
cp ./config/node_exporter.service /etc/systemd/system/node_exporter.service 
systemctl daemon-reload
systemctl enable node_exporter.service
systemctl start node_exporter
systemctl restart prometheus

# Instalação do Alertmanager
wget https://github.com/prometheus/alertmanager/releases/download/v0.25.0/alertmanager-0.25.0.linux-amd64.tar.gz
tar xvzf alertmanager*
mv ./alertmanager-0.25.0.linux-amd64/alertmanager /usr/local/bin
mv ./alertmanager-0.25.0.linux-amd64/amtool /usr/local/bin
cp ./config/alertmanager.yml /etc/alertmanager
cp ./config/alertmanager.service /etc/systemd/system/alertmanager.service
systemctl daemon-reload
systemctl enable alertmanager.service
systemctl start alertmanager

