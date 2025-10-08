#!/bin/bash
set -e

echo "=== [K3s Server] Stating Contoller mode ==="

echo "--> Install and Update packages"
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y curl
sudo apt install -y docker.io
systemctl enable docker
systemctl start docker
usermod -aG docker vagrant

echo "--> Install K3s (modo controller)"
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644 --node-ip=192.168.56.110 --advertise-address=192.168.56.110 --tls-san=192.168.56.110" sh -
echo "--> create syms link kubectl → k3s"
if [ ! -e /usr/local/bin/kubectl ]; then
  ln -s /usr/local/bin/k3s /usr/local/bin/kubectl
else
  echo "[INFO] /usr/local/bin/kubectl already, has been created"
fi

echo "--> Given permission to vagrant run k3 as admin"
chown vagrant:vagrant /etc/rancher/k3s/k3s.yaml

sleep 30
#build images
for app in app1 app2 app3; do
  # build no Docker
  echo "---- build image with build-arg"
  docker build --build-arg APP_NAME=$app -t src-$app:local /vagrant/src

  # exporta e importa no containerd do K3s
  docker save -o $app.tar src-$app:local
  echo "--- docker save"
  k3s ctr images import $app.tar

done

# comeca aqui a parte 2
kubectl apply -f /vagrant/confs/app1.yaml
kubectl apply -f /vagrant/confs/app2.yaml
kubectl apply -f /vagrant/confs/app3.yaml
kubectl apply -f /vagrant/confs/ingress.yaml

sleep 30
until curl -sf "192.168.56.110" >/dev/null; do
  echo "Aguardando 192.168.56.110..."
  sleep 5
done

echo "Sucesso: $URL respondeu!"

echo "--> validate status of the control-plane"
kubectl get pods

echo "=== [K3s Server] Provider completed ==="
