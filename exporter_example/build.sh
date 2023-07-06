#!/bin/bash

# Instalando pacotes necessários
apt-get update -y
snap install docker

#apt-get install -y python3-pip - retirar no próximo commit
#pip install prometheus-client - retirar no próximo commit
#snap install jq - retirar no próximo commit

# Buildando container do exporter em python
cd exporter_example_python
docker build -t primeiro-exporter:0.1 .

cd ..

# Buildando container do exporter em python
cd exporter_example_go
docker build -t segundo-exporter:0.1 .
docker run -d -p 8899:8899 --name primeiro-exporter primeiro-exporter:0.1
docker run -d -p 7788:7788 --name segundo-exporter segundo-exporter:0.1