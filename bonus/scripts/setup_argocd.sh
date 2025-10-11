#!/usr/bin/env bash
set -euo pipefail

echo "===== Creating K3d Cluster for Bonus ====="

# Delete existing cluster if it exists
if k3d cluster list | grep -q "iot-bonus"; then
    echo "Deleting existing cluster iot-bonus..."
    k3d cluster delete iot-bonus
fi

# Create K3d cluster with port mappings for GitLab and application
# Port 8080 on host -> Port 80 on loadbalancer (for GitLab HTTP)
# Port 8888 on host -> Port 8888 on loadbalancer (for application)
# Port 2222 on host -> Port 22 on loadbalancer (for GitLab SSH)
echo "Creating new K3d cluster..."
k3d cluster create iot-bonus \
    --servers 1 \
    --agents 0 \
    --api-port 6550 \
    -p "8080:80@loadbalancer" \
    -p "8888:8888@loadbalancer" \
    -p "2222:22@loadbalancer"

# Verify cluster is running
echo ""
echo "Verifying cluster..."
kubectl cluster-info
kubectl get nodes

echo ""
echo "===== Installing Argo CD ====="

# Create argocd namespace
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install Argo CD
echo "Installing Argo CD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for Argo CD to be ready
echo ""
echo "Waiting for Argo CD to be ready (this may take a few minutes)..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

echo ""
echo "===== Argo CD Installation Complete ====="

