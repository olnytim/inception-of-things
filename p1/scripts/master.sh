#!/bin/sh

echo "vagrant:1" | chpasswd
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--flannel-iface enp0s8" sh -
sleep 5
chmod 644 /etc/rancher/k3s/k3s.yaml
cp /var/lib/rancher/k3s/server/node-token /vagrant/
cp /etc/rancher/k3s/k3s.yaml /vagrant/
echo "K3s master is ready!!!"