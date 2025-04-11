#!/bin/bash

set -e

# 1) Creation of k3d cluster
echo "Creating k3d cluster..."
k3d cluster create iot
sleep 5

# 2) Setup kubectl context
echo "Setting up context kubectl..."
kubectl config use-context k3d-iot

# 3) Create namespace for ArgoCD
echo "Creating namespace ArgoCD and Dev..."
kubectl create namespace argocd
kubectl create namespace dev

# 4) Install ArgoCD
echo "Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 5) Add entry to /etc/hosts
echo "Adding entry to /etc/hosts..."
HOST_ENTRY="127.0.0.1 argocd.mydomain.com"
HOSTS_FILE="/etc/hosts"

if grep -q "$HOST_ENTRY" "$HOSTS_FILE"; then
    echo "exist $HOSTS_FILE"
else
    echo "adding $HOSTS_FILE"
    echo "$HOST_ENTRY" | sudo tee -a "$HOSTS_FILE"
fi

# 6) Wait for ArgoCD to be ready
echo "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=ready --timeout=600s pod --all -n argocd

# 7) Show basic auth
echo "Showing basic auth..."
kubectl -n argocd \
    get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode
echo

## 8) Confirmation ArgoCD application
echo "Confirming ArgoCD application..."
# argocd localhost:8085 or argocd.mydomain.com:8085
kubectl port-forward svc/argocd-server -n argocd 8085:443 > /dev/null 2>&1 &
kubectl apply -f confs/application.yaml

echo ">>> Setup script has finished successfully."
echo ">>> ArgoCD server is now running in namespace 'argocd'."
echo "You can access ArgoCD UI by port-forward or by NodePort."
echo "Then login with user 'admin' and the above printed password."