#!/bin/sh

echo "vagrant:1" | chpasswd
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--flannel-iface enp0s8" K3S_URL=https://192.168.56.110:6443 K3S_TOKEN=$(sudo cat /vagrant/node-token) sh -
sleep 5
echo "K3s-agent is ready!"