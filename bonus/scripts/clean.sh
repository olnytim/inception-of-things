#!/bin/bash
set -e

GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

echo -e "${GREEN}Удаляем helm release gitlab...${RESET}"
helm uninstall gitlab -n gitlab

echo -e "${GREEN}Удаляем namespace gitlab...${RESET}"
kubectl delete namespace gitlab

echo -e "${GREEN}Удаляем запись из /etc/hosts...${RESET}"
sudo sed -i '/127\.0\.0\.1 gitlab\.k3d\.gitlab\.com/d' /etc/hosts

echo -e "${GREEN}Удаляем helm, установленный через snap...${RESET}"
sudo snap remove helm

echo -e "${GREEN}Завершаем фоновый port-forward...${RESET}"
pkill -f "kubectl port-forward svc/gitlab-webservice-default -n gitlab" || true

sudo rm -rf iot git_repo

echo -e "${GREEN}Удаление завершено!${RESET}"
