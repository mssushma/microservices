#!/bin/bash

set -eux

# Update system

apt-get update -y
apt-get upgrade -y

# Disable swap

swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

# Kernel modules

cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# Kubernetes networking requirements

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

######################################################
# Containerd
######################################################

apt-get install -y \
  curl \
  wget \
  apt-transport-https \
  ca-certificates \
  gnupg \
  lsb-release

mkdir -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) \
signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | \
tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y

apt-get install -y \
containerd.io

mkdir -p /etc/containerd

containerd config default > /etc/containerd/config.toml

sed -i \
's/SystemdCgroup = false/SystemdCgroup = true/g' \
/etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd

######################################################
# Kubernetes
######################################################

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | \
gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo \
'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | \
tee /etc/apt/sources.list.d/kubernetes.list

apt-get update -y

apt-get install -y \
kubelet \
kubeadm \
kubectl

apt-mark hold kubelet kubeadm kubectl

######################################################
# Kubernetes Init
######################################################

PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

kubeadm init \
  --pod-network-cidr=192.168.0.0/16 \
  --apiserver-cert-extra-sans=$PUBLIC_IP

######################################################
# kubeconfig
######################################################

mkdir -p /home/ubuntu/.kube

cp -i /etc/kubernetes/admin.conf \
/home/ubuntu/.kube/config

chown ubuntu:ubuntu \
/home/ubuntu/.kube/config

export KUBECONFIG=/etc/kubernetes/admin.conf

######################################################
# Remove control-plane taint
######################################################

kubectl taint nodes --all node-role.kubernetes.io/control-plane- || true

######################################################
# Calico CNI
######################################################

kubectl apply -f \
https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/calico.yaml

######################################################
# NGINX Ingress
######################################################

kubectl apply -f \
https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

######################################################
# Metrics Server
######################################################

kubectl apply -f \
https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

sleep 30

kubectl patch deployment metrics-server \
-n kube-system \
--type='json' \
-p='[
{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}
]'

######################################################
# Helm
######################################################

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "Bootstrap completed"
