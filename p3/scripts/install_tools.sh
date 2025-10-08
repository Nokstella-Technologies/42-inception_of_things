#!/usr/bin/env bash
set -euo pipefail

# 1) Instalar Docker
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing..."
    if [ -f /etc/os-release ]; then . /etc/os-release; fi
    case "${ID:-}" in
      ubuntu|debian)
        sudo apt-get update -y
        sudo apt-get install -y ca-certificates curl gnupg lsb-release
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/${ID}/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/${ID} $(lsb_release -cs) stable" \
        | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
        sudo apt-get update -y
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io
        ;;
      arch)
        sudo pacman -Syu --noconfirm
        sudo pacman -S --needed --noconfirm docker
        ;;
      *)
        echo "Distro não suportada automaticamente"; exit 1;;
    esac
else
    echo "Docker is already installed." 
fi

# Start and enable Docker if not already active
if ! systemctl is-active --quiet docker; then
    echo "Starting and enabling Docker service..."
    sudo systemctl enable --now docker
else
    echo "Docker service is already active."
fi

# Add user to docker group if not already a member
if ! groups "$USER" | grep -q '\bdocker\b'; then
    echo "Adding user '$USER' to the 'docker' group..."
    sudo usermod -aG docker "$USER"
    echo "User added to docker group. You may need to log out and back in for this to take effect."
else
    echo "User '$USER' is already in the 'docker' group."
fi

# 2) Instalar kubectl
if ! command -v kubectl &> /dev/null; then
    echo "\n----- Installing kubectl -----"
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
else
    echo "\nkubectl is already installed."
fi

# 3) Instalar k3d
if ! command -v k3d &> /dev/null; then
    echo "\n----- Installing k3d -----"
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
    k3d cluster create iot-p3 \
        --servers 1 --agents 0 \
        --api-port 6550 \
        -p "8888:80@loadbalancer"
else
    echo "\nk3d is already installed."
fi
