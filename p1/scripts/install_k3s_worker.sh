#!/bin/bash
set -e

echo "=== [K3s Agent] Iniciando provisão do nó worker ==="
echo "--> Atualizando pacotes e instalando curl"
sudo apt update -y
sudo apt install -y curl

if [ ! -f /vagrant/node-token ]; then
  echo "[ERRO] Arquivo /vagrant/node-token não encontrado!"
  echo "Certifique-se de que o 'install_k3s_server.sh' já rodou com sucesso"
  exit 1
fi

echo "--> Token do server: ${K3S_TOKEN}"
echo "--> URL do server: ${K3S_URL}"
sudo ufw allow 6443/tcp

echo "--> Instalando K3s (modo agent → worker)"
sudo curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --server https://192.168.56.110:6443 -t $(cat /vagrant/node-token) --node-ip=192.168.56.111" sh -

echo "--> change ip type to eth1"
sudo ip link add eth1 type dummy && sudo ip addr add 192.168.56.111/24 dev eth1 && sudo ip link set eth1 up

echo "=== [K3s Agent] Provisionamento concluído ==="
