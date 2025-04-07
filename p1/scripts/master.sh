#!/bin/sh

echo "vagrant:1" | chpasswd
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--flannel-iface eth1" sh - #use correct interface
sleep 10
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
NODE_TOKEN="/var/lib/rancher/k3s/server/node-token"
while [ ! -f $NODE_TOKEN ]; do
  echo "Waiting for node token to be created..."
  sleep 5
done
sudo cat $NODE_TOKEN
sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/
sudo cp /etc/rancher/k3s/k3s.yaml /vagrant/
echo "K3s master is ready!"