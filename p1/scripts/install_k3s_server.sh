#!/bin/bash
set -e

echo "=== [K3s Server] Stating Contoller mode ==="

echo "--> Install and Update packages"
sudo apt update -y
sudo apt install -y curl

export NODE_IP="192.168.56.110"

echo "--> Install K3s (modo controller)"
sudo curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644 --tls-san llima-ceS --node-ip=${NODE_IP} --advertise-address=${NODE_IP}" sh -

echo "--> create syms link kubectl → k3s"
if [ ! -e /usr/local/bin/kubectl ]; then
  ln -s /usr/local/bin/k3s /usr/local/bin/kubectl
else
  echo "[INFO] /usr/local/bin/kubectl already, has been created"
fi

echo "--> Given permission to vagrant run k3 as admi n"
chown vagrant:vagrant /etc/rancher/k3s/k3s.yaml
chown vagrant:vagrant /vagrant

echo "--> Taken the token for the worker connection and save in shared folder /vagrant"
SERVER_TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)
echo "${SERVER_TOKEN}" > /vagrant/node-token
chown vagrant:vagrant /vagrant/node-token

echo "--> creates a eth1 connection"
sudo ip link add eth1 type dummy && sudo ip addr add 192.168.56.110/24 dev eth1 && sudo ip link set eth1 up;

echo "=== [K3s Server] Provider completed ==="