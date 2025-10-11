#!/usr/bin/env bash
set -euo pipefail

echo "===== Cleaning Bonus Environment ====="

# Delete dev namespace resources
echo "Cleaning dev namespace..."
kubectl delete namespace dev --ignore-not-found=true || true

# Delete gitlab namespace
echo "Cleaning gitlab namespace..."
kubectl delete namespace gitlab --ignore-not-found=true || true

# Delete argocd namespace
echo "Cleaning argocd namespace..."
kubectl delete namespace argocd --ignore-not-found=true || true

# Delete the cluster
echo "Deleting K3d cluster iot-bonus..."
k3d cluster delete iot-bonus || true

echo ""
echo "===== Cleanup Complete ====="