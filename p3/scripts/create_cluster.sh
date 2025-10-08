#!/bin/bash
set -e

# Delete existing cluster if it exists
if k3d cluster list | grep -q "iot-p3"; then
    echo "Deleting existing cluster..."
    k3d cluster delete iot-p3
fi

# Create K3d cluster with proper port mappings
# Port 8888 maps to port 80 of the Traefik ingress controller
k3d cluster create iot-p3 \
  --servers 1 \
  --agents 0 \
  --api-port 6550 \
  -p "8888:80@loadbalancer"

# kubeconfig pronto
echo "Cluster criado. KUBECONFIG: $(k3d kubeconfig write iot-p3)"
kubectl cluster-info