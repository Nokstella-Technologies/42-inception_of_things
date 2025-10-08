#!/usr/bin/env bash
set -euo pipefail

echo "===== Deploying Application ====="

# Create dev namespace

kubectl apply -f confs/application.yaml

echo ""
echo "===== Application is ready! ====="
echo "Access the application at: http://localhost:8888"
echo ""
echo "Test with: curl http://localhost:8888"
echo ""
kubectl port-forward svc/argocd-server -n argocd 8078:443