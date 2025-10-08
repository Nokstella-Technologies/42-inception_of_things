#!/usr/bin/env bash
set -euo pipefail

echo "===== Creating K3d Cluster ====="

# Delete existing cluster if it exists
if k3d cluster list | grep -q "iot-p3"; then
    echo "Deleting existing cluster iot-p3..."
    k3d cluster delete iot-p3
fi

# Create K3d cluster with correct port mapping
# Port 8888 on host -> Port 80 on loadbalancer (Traefik ingress)
echo "Creating new K3d cluster..."
k3d cluster create iot-p3 \
    --servers 1 \
    --agents 0 \
    --api-port 6550 \
    -p "8888:80@loadbalancer"

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

