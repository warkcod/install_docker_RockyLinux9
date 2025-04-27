#!/bin/bash

# Script Description:
# This script installs Docker on Rocky Linux 9, including necessary configurations and optional components.
# WARNING: This script will remove Podman and its related packages.

echo -e "\033[31mWARNING: This script will remove Podman and its related packages. Continue? (y/N)\033[0m"
read -r response
if [[ "$response" != "y" ]]; then
    echo "Installation aborted."
    exit 1
fi

# Remove Podman
sudo dnf remove -y podman*
sudo dnf install -y yum-utils device-mapper-persistent-data lvm2 jq

# Official installation example
# curl -fsSL https://get.docker.com -o get-docker.sh
# sh ./get-docker.sh --dry-run

# Add Docker repository
sudo dnf config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
sudo sed -i 's+download.docker.com+mirrors.aliyun.com/docker-ce+' /etc/yum.repos.d/docker-ce.repo

# Update and install Docker-CE
sudo dnf makecache
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install and lock version
sudo dnf install -y python3-dnf-plugin-versionlock
sudo dnf versionlock add docker-ce

# Configure kernel modules
if ! grep -q "overlay" /etc/modules-load.d/containerd.conf 2>/dev/null; then
    sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
fi

# Load modules
sudo modprobe br_netfilter

# Configure sysctl settings
if ! grep -q "net.bridge.bridge-nf-call-ip6tables" /etc/sysctl.conf 2>/dev/null; then
    sudo tee -a /etc/sysctl.conf <<EOF 
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
fi

# Configure Docker registry mirrors
sudo mkdir -p /etc/docker
if [ ! -f /etc/docker/daemon.json ]; then
    sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "group": "docker",
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "https://docker.1ms.run",
    "https://docker.xuanyuan.me",
    "https://docker.nju.edu.cn"
  ],
  "exec-opts": ["native.cgroupdriver=systemd"]  
}
EOF
fi

# Reload and configure startup
sudo systemctl daemon-reload
sudo systemctl enable --now docker

# Test Docker installation
#docker pull traefik/whoami
#docker run -itd --rm -p 80:80 traefik/whoami:latest
#curl localhost

# Ask user if they want to add current user to docker group
echo "Do you want to add the current user to the docker group? (y/N)"
read -r add_to_docker_group
if [[ "$add_to_docker_group" == "y" ]]; then
    sudo usermod -aG docker $USER
    newgrp docker
fi

# Ask user if they want to install Portainer (Docker UI)
echo "Do you want to install Portainer (Docker UI)? (y/N)"
read -r install_portainer
if [[ "$install_portainer" == "y" ]]; then
    sudo docker pull docker.io/portainer/portainer
    sudo docker run -d -p 9000:9000 --restart=always -v /var/run/docker.sock:/var/run/docker.sock --name docker-ui portainer/portainer
fi

echo $DOCKER_HOST
export DOCKER_HOST=unix:///var/run/docker.sock
sudo systemctl restart docker
