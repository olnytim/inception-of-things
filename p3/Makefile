# **************************************************************************** #
#                                Makefile                                      #
# **************************************************************************** #

SHELL := /bin/bash

# Цвета для вывода (ANSI Escape Codes)
GREEN=\033[0;32m
YELLOW=\033[1;33m
RED=\033[0;31m
NC=\033[0m

# ~~~ ПЕРЕМЕННЫЕ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ARGOCD_VERSION    = v2.14.9
ARGOCD_BIN        = /usr/local/bin/argocd
K3D_BIN           = /usr/local/bin/k3d
KUBECTL_BIN       = /usr/local/bin/kubectl
DOCKER_BIN        := /usr/local/bin/docker
DOCKER   := docker
K3D      := k3d
KUBECTL  := kubectl
ARGOCD   := argocd
ARCH     := arm64

# ~~~ ПРАВИЛА ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
all: setup check project
	@echo -e "$(GREEN)All components installed and checked!$(NC)"

setup: install_docker install_k3d install_kubectl install_argocd
	@echo -e "$(GREEN)All components installed!$(NC)"

check: check_docker check_k3d check_kubectl check_argocd
	@echo -e "$(GREEN)All checks finished!$(NC)"

project:
	@echo -e "$(YELLOW)>>> Project setup...$(NC)"
	./scripts/setup.sh
	@echo -e "$(GREEN)>>> Project setup finished!$(NC)"

fclean: remove_argocd remove_k3d remove_kubectl remove_docker
	@echo -e "$(GREEN)All components removed!$(NC)"

re: fclean all

# ~~~ УСТАНОВКА ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
install_docker:
	@echo -e "$(YELLOW)>>> Installing Docker...$(NC)"
	sudo apt-get remove -y docker docker-engine docker.io containerd runc || true
	sudo apt-get update -y
	sudo apt-get install -y \
		ca-certificates \
		curl \
		gnupg \
		lsb-release
	sudo mkdir -p /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
		sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable" | \
	  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update -y
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io
	sudo usermod -aG docker $$USER
	@echo -e "$(GREEN)>>> Docker installed!$(NC)"

install_k3d:
	@echo -e "$(YELLOW)>>> Installing k3d...$(NC)"
	curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
	@echo -e "$(GREEN)>>> k3d installed!$(NC)"

install_kubectl:
	@echo -e "$(YELLOW)>>> Installing kubectl...$(NC)"
	curl -LO "https://dl.k8s.io/release/v1.32.3/bin/linux/${ARCH}/kubectl"
	sudo install -m 0755 kubectl /usr/local/bin/kubectl
	rm -f kubectl
	@echo -e "$(GREEN)>>> kubectl installed!$(NC)"

install_argocd:
	@echo -e "$(YELLOW)>>> Installing Argo CD CLI...$(NC)"
	curl -sSL -o argocd \
	  "https://github.com/argoproj/argo-cd/releases/download/$(ARGOCD_VERSION)/argocd-linux-${ARCH}"
	sudo install -m 0755 argocd $(ARGOCD_BIN)
	rm -f argocd
	@echo -e "$(GREEN)>>> Argo CD CLI installed!$(NC)"

# ~~~ ПРОВЕРКИ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
check_docker:
	@echo -e "$(YELLOW)>>> Checking Docker...$(NC)"
	@command -v $(DOCKER) &> /dev/null && \
		($(DOCKER) --version && echo -e "$(GREEN)Docker is installed!$(NC)") || \
		(echo -e "$(RED)Error: Docker not found$(NC)" && exit 1)

check_k3d:
	@echo -e "$(YELLOW)>>> Checking k3d...$(NC)"
	@command -v $(K3D) &> /dev/null && \
		($(K3D) version && echo -e "$(GREEN)k3d is installed!$(NC)") || \
		(echo -e "$(RED)Error: k3d not found$(NC)" && exit 1)

check_kubectl:
	@echo -e "$(YELLOW)>>> Checking kubectl...$(NC)"
	@command -v $(KUBECTL) &> /dev/null && \
		($(KUBECTL) version --client && echo -e "$(GREEN)kubectl is installed!$(NC)") || \
		(echo -e "$(RED)Error: kubectl not found$(NC)" && exit 1)

check_argocd:
	@echo -e "$(YELLOW)>>> Checking Argo CD CLI...$(NC)"
	@command -v $(ARGOCD) &> /dev/null && \
		($(ARGOCD) version --client && echo -e "$(GREEN)Argo CD CLI is installed!$(NC)") || \
		(echo -e "$(RED)Error: Argo CD CLI not found$(NC)" && exit 1)

# ~~~ УДАЛЕНИЕ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
remove_docker:
	@echo -e "$(YELLOW)>>> Removing Docker...$(NC)"
	sudo apt-get purge -y docker-ce docker-ce-cli containerd.io || true
	sudo apt-get autoremove -y
	sudo rm -rf /var/lib/docker
	sudo rm -rf /var/lib/containerd
	sudo rm -f /etc/apt/sources.list.d/docker.list
	sudo rm -f /etc/apt/keyrings/docker.gpg
	@echo -e "$(GREEN)>>> Docker removed!$(NC)"

remove_k3d:
	@echo -e "$(YELLOW)>>> Removing k3d...$(NC)"
	sudo rm -f $(K3D_BIN)
	@echo -e "$(GREEN)>>> k3d removed!$(NC)"

remove_kubectl:
	@echo -e "$(YELLOW)>>> Removing kubectl...$(NC)"
	sudo rm -f $(KUBECTL_BIN)
	@echo -e "$(GREEN)>>> kubectl removed!$(NC)"

remove_argocd:
	@echo -e "$(YELLOW)>>> Removing Argo CD CLI...$(NC)"
	sudo rm -f $(ARGOCD_BIN)
	@echo -e "$(GREEN)>>> Argo CD CLI removed!$(NC)"

# **************************************************************************** #

.PHONY: all fclean re install_docker install_k3d install_kubectl install_argocd \
	remove_docker remove_k3d remove_kubectl remove_argocd
