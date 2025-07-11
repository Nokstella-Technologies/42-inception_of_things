#!/bin/bash
set -e

echo "----[ Início da Instalação Docker + K3d ]----"

install_docker_ubuntu() {
  echo ">> Instalando Docker no Ubuntu/Debian..."
  sudo apt-get update
  sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg |
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io
  sudo systemctl enable --now docker
  sudo usermod -aG docker "$USER"
}

install_docker_arch() {
  echo ">> Instalando Docker no Arch Linux..."
  sudo pacman -Syu --noconfirm
  sudo pacman -S --needed --noconfirm docker
  sudo systemctl enable --now docker
  sudo usermod -aG docker "$USER"
}

install_k3d() {
  echo ">> Instalando k3d (universal)..."
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
}

if [ -f /etc/os-release ]; then
  . /etc/os-release
  case "$ID" in
  ubuntu | debian)
    install_docker_ubuntu
    ;;
  arch)
    install_docker_arch
    ;;
  *)
    echo "Distro não suportada automaticamente. Instale Docker e k3d manualmente."
    exit 1
    ;;
  esac
else
  echo "Não foi possível detectar a distribuição. Saindo."
  exit 1
fi

install_k3d

echo
echo ">> Docker e k3d instalados! (talvez precise relogar para ativar o grupo docker)"
echo "Teste: docker version && k3d version"
echo
echo "Para criar seu cluster, rode:"
echo "    k3d cluster create meu-cluster"
echo
echo "Para deletar:"
echo "    k3d cluster delete meu-cluster"
echo
echo "----[ FIM DA INSTALAÇÃO ]----"
