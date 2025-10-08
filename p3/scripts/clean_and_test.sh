#!/usr/bin/env bash
set -euo pipefail

echo "===== Cleaning everything ====="

# Delete the cluster
kubectl delete pods --all -n dev
kubectl delete svc --all -n dev
kubectl delete ingress --all -n dev
kubectl delete deployment --all -n dev
kubectl delete namespace dev

echo "Deleting K3d cluster..."
k3d cluster delete iot-p3 || true

echo ""
echo "===== deleted cluster ====="