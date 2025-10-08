#!/usr/bin/env bash
set -euo pipefail

echo "===== Deploying Application ====="

# Create dev namespace
echo "Creating dev namespace..."
kubectl apply -f confs/dev-namespace.yaml

# Option 1: Deploy using Argo CD (GitOps approach)
if kubectl get namespace argocd &>/dev/null; then
    echo "Deploying application via Argo CD..."
    kubectl apply -f confs/application.yaml
    
    echo ""
    echo "Application deployed via Argo CD!"
    echo "Check status with: kubectl get applications -n argocd"
    echo "Or access Argo CD UI at: https://localhost:8080 (after port-forward)"
else
    # Option 2: Deploy directly with kubectl
    echo "Argo CD not found. Deploying directly with kubectl..."
    kubectl apply -f confs/deployment.yaml
    kubectl apply -f confs/service.yaml
    kubectl apply -f confs/ingress.yaml
    
    echo ""
    echo "Application deployed directly!"
fi

# Wait for deployment to be ready
echo ""
echo "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/wil-playground -n dev || true

# Show status
echo ""
echo "===== Deployment Status ====="
kubectl get all -n dev
echo ""
echo "===== Ingress ====="
kubectl get ingress -n dev

echo ""
echo "===== Application is ready! ====="
echo "Access the application at: http://localhost:8888"
echo ""
echo "Test with: curl http://localhost:8888"
echo ""
