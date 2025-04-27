#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${YELLOW}Creating k3d cluster...${NC}"
k3d cluster create iot
sleep 5

echo -e "${YELLOW}Setting up context kubectl...${NC}"
kubectl config use-context k3d-iot

echo -e "${YELLOW}Creating namespace ArgoCD and Dev...${NC}"
kubectl create namespace argocd
kubectl create namespace dev

echo -e "${YELLOW}Installing ArgoCD...${NC}"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo -e "${YELLOW}Adding entry to /etc/hosts...${NC}"
HOST_ENTRY="127.0.0.1 argocd.mydomain.com"
HOSTS_FILE="/etc/hosts"

if grep -q "$HOST_ENTRY" "$HOSTS_FILE"; then
    echo -e "${GREEN}Entry exists in $HOSTS_FILE${NC}"
else
    echo -e "${YELLOW}Adding entry to $HOSTS_FILE${NC}"
    echo "$HOST_ENTRY" | sudo tee -a "$HOSTS_FILE"
fi

echo -e "${YELLOW}Waiting for ArgoCD to be ready...${NC}"
kubectl wait --for=condition=ready --timeout=600s pod --all -n argocd

echo
echo -e "${YELLOW}Showing basic auth:${PURPLE}"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode
echo -e "${NC}"
echo

echo -e "${YELLOW}Confirming ArgoCD application...${NC}"
kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8085:443 > /dev/null 2>&1 &

kubectl apply -f confs/application.yaml

echo -e "${YELLOW}Waiting for svc-wil...${NC}"
while ! kubectl get svc svc-wil -n dev > /dev/null 2>&1; do
    sleep 5
    echo -e "${YELLOW}Service svc-wil not ready yet. Please wait...${NC}"
done

echo -e "${YELLOW}Service svc-wil ready, launching port-forward...${NC}"
kubectl wait --for=condition=ready --timeout=600s pod --all -n dev
echo -e "${YELLOW}Launching port-forward for svc-wil...${NC}"
kubectl port-forward --address 0.0.0.0 -n dev svc/svc-wil 8888:8080 > /dev/null 2>&1 &

echo -e "${GREEN}>>> Setup script has finished successfully.${NC}"
echo -e "${GREEN}>>> ArgoCD server is now running in namespace 'argocd'.${NC}"
echo -e "${GREEN}You can access ArgoCD UI by port-forward or by NodePort.${NC}"
echo -e "${GREEN}Then login with user 'admin' and the above printed password.${NC}"
