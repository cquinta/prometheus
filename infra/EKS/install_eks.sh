#!/bin/bash
apt-get update -y
apt-get install curl -y 
apt-get install unzip -y
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
aws configure
eksctl create cluster --name=eks-cluster --version=1.27 --region=us-east-1 --nodegroup-name=eks-cluster-nodegroup --node-type=t3.medium --nodes=2 --nodes-min=1 --nodes-max=3 --managed

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

chmod +x ./kubectl

mv ./kubectl /usr/local/bin/kubectl

aws eks --region us-east-1 update-kubeconfig --name eks-cluster

apt-get install -y git
git clone https://github.com/prometheus-operator/kube-prometheus

kubectl create -f ./kube-prometheus/manifests/setup
kubectl apply -f ./kube-prometheus/manifests


