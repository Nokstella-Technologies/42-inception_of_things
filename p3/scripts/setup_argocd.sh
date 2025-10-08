#!/usr/bin/env bash
set -euo pipefail

echo "===== Installing Argo CD ====="

# Create argocd namespace
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install Argo CD
echo "Installing Argo CD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for Argo CD to be ready
echo "Waiting for Argo CD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Patch argocd-server service to use NodePort
echo "Configuring Argo CD server service..."
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

# Get initial admin password
echo ""
echo "===== Argo CD Installation Complete ====="
echo ""
echo "To access Argo CD:"
echo "1. Port-forward the service:"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo "2. Access Argo CD at: https://localhost:8080"
echo "   Username: admin"
echo "   Password: (run the command below)"
echo ""
echo "Get admin password:"
echo "   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d && echo"
echo ""
