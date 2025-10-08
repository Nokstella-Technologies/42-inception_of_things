#!/usr/bin/env bash
set -euo pipefail

echo "===== Deploying Application ====="

# Create dev namespace
echo "Creating dev namespace..."
kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -

# Apply Argo CD Application (GitOps)
echo "Applying Argo CD Application..."
kubectl apply -f confs/application.yaml


echo "Waiting for application pods to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/wil-playground -n dev 2>/dev/null || echo "Deployment not found yet, checking status..."


echo "Testing application at http://localhost:8888..."
RESPONSE=$(curl -s http://localhost:8888 || echo "Connection failed")
echo "Response: $RESPONSE"

echo "Starting Argo CD port-forward..."
kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &

echo ""
echo "===== Argo CD Access Information ====="
echo ""
echo "Argo CD UI: https://localhost:8080"
echo "Username: admin"
echo ""
echo "Password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d && echo
echo ""
echo ""
echo "===== Application URL ====="
echo "Application: http://localhost:8888"
echo ""
echo "Commands:"
echo "  - Test app: curl http://localhost:8888"
echo "  - Check pods: kubectl get pods -n dev"
echo "  - Check logs: kubectl logs -n dev deployment/wil-playground"
echo ""
