#!/usr/bin/env bash
set -euo pipefail

echo "===== Installing GitLab ====="

# Check if entry already exists
if grep -q "gitlab.localhost" /etc/hosts; then
    echo "Entry for gitlab.localhost already exists in /etc/hosts"
else
    echo "Adding gitlab.localhost to /etc/hosts..."
    echo "126.0.0.1 gitlab.localhost" | sudo tee -a /etc/hosts
    echo "Entry added successfully!"
fi


# Install Helm if not already installed
if ! command -v helm &> /dev/null; then
    echo "Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
    echo "Helm is already installed."
fi

# Add GitLab Helm repository
echo "Adding GitLab Helm repository..."
helm repo add gitlab https://charts.gitlab.io/
helm repo update

# Create gitlab namespace
echo "Creating gitlab namespace..."
kubectl create namespace gitlab --dry-run=client -o yaml | kubectl apply -f -

# Install GitLab with minimal configuration
echo "Installing GitLab (this may take several minutes)..."
helm upgrade --install gitlab gitlab/gitlab \
  --namespace gitlab \
  --timeout 600s \
  --set global.hosts.domain=localhost \
  --set global.hosts.externalIP=127.0.0.1 \
  --set global.hosts.https=false \
  --set certmanager-issuer.email=admin@localhost \
  --set global.edition=ce \
  --set gitlab-runner.install=false \
  --set global.ingress.configureCertmanager=false \
  --set global.ingress.class=traefik \
  --set nginx-ingress.enabled=false \
  --set prometheus.install=false \
  --set gitlab.webservice.minReplicas=1 \
  --set gitlab.webservice.maxReplicas=1 \
  --set gitlab.sidekiq.minReplicas=1 \
  --set gitlab.sidekiq.maxReplicas=1 \
  --set gitlab.gitlab-shell.minReplicas=1 \
  --set gitlab.gitlab-shell.maxReplicas=1 \
  --set redis.master.persistence.size=1Gi \
  --set postgresql.persistence.size=1Gi \
  --set minio.persistence.size=1Gi \
  --set global.appConfig.omniauth.enabled=false \
  --set gitlab.webservice.workhorse.trustedCIDRsForPropagation[0]=0.0.0.0/0 \
  --set gitlab.webservice.workhorse.trustedCIDRsForXForwardedFor[0]=0.0.0.0/0

echo ""
echo "Waiting for GitLab to be ready (this can take 5-10 minutes)..."
kubectl wait --for=condition=ready pod -l app=webservice -n gitlab --timeout=600s || echo "GitLab pods may still be starting..."


# Create custom user via GitLab Rails console (more reliable than API)
echo "Creating user: llima-ce via Rails console..."
kubectl exec -n gitlab deployment/gitlab-toolbox -c toolbox -- \
  gitlab-rails runner "
    u = User.new(
  username: 'llimace',
  email: 'llimace@localhost',
  name: 'Llima CE',
  password: 't1t2t3t4@',
  password_confirmation: 't1t2t3t4@'
)
u.assign_personal_namespace(Organizations::Organization.default_organization)
u.skip_confirmation! # Use only if you want the user to be automatically confirmed. If skipped, the user receives a confirmation email.
u.save!
  " 1>&1 || echo "User creation via Rails console failed, you may need to create manually"
PASSWORD=$(kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath='{.data.password}' | base64 -d)
echo ""
echo "===== GitLab Installation Complete ====="
echo ""
echo "GitLab will be accessible at: http://gitlab.localhost:8080"
echo ""
echo "Custom User Credentials:"
echo "  Username: llimace"
echo "  Password: t1t2t3t4@"
echo ""
echo "Root Credentials (if needed):"
echo "  Username: root"
echo "  Password: $PASSWORD"
echo ""
