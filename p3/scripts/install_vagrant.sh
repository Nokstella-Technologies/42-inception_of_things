#!/bin/bash
set -e

echo "----[ Início da Instalação do Vagrant ]----"

install_vagrant_ubuntu() {
  echo ">> Instalando Vagrant no Ubuntu/Debian..."
  sudo apt-get update
  sudo apt-get install -y wget gnupg2 lsb-release software-properties-common

  # Adiciona o repositório oficial da Hashicorp (Vagrant)
  wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" |
    sudo tee /etc/apt/sources.list.d/hashicorp.list

  sudo apt-get update
  sudo apt-get install -y vagrant
}

install_vagrant_arch() {
  echo ">> Instalando Vagrant no Arch Linux..."
  sudo pacman -Syu --noconfirm
  sudo pacman -S --needed --noconfirm vagrant
}

if [ -f /etc/os-release ]; then
  . /etc/os-release
  case "$ID" in
  ubuntu | debian)
    install_vagrant_ubuntu
    ;;
  arch)
    install_vagrant_arch
    ;;
  *)
    echo "Distro não suportada automaticamente. Instale o Vagrant manualmente."
    exit 1
    ;;
  esac
else
  echo "Não foi possível detectar a distribuição. Saindo."
  exit 1
fi

echo
echo "Vagrant instalado!"
echo "Teste: vagrant --version"
echo "----[ FIM DA INSTALAÇÃO ]----"
