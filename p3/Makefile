# **************************************************************************** #
#                                Makefile                                      #
# **************************************************************************** #

SHELL := /bin/bash

# ~~~ ПЕРЕМЕННЫЕ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Можно указать конкретные версии, либо оставить latest для большинства
# случаев. При необходимости скорректируйте URL до определённого релиза
# АргоCD, если хотите зафиксировать конкретную версию.

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
	@echo "All components installed and checked!"

setup: install_docker install_k3d install_kubectl install_argocd
	@echo "All components installed!"

check: check_docker check_k3d check_kubectl check_argocd
	@echo "All checks finished!"

project:
	@echo ">>> Project setup..."
	./scripts/setup.sh
	@echo ">>> Project setup finished!"

fclean: remove_argocd remove_k3d remove_kubectl remove_docker
	@echo "All components removed!"

re: fclean all

# ~~~ УСТАНОВКА ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

install_docker:
	@echo ">>> Installing Docker..."
	# Удаляем старые версии (если есть)
	sudo apt-get remove -y docker docker-engine docker.io containerd runc || true

	# Обновляем индексы пакетов
	sudo apt-get update -y

	# Ставим утилиты для использования Docker-репозитория
	sudo apt-get install -y \
		ca-certificates \
		curl \
		gnupg \
		lsb-release

	# Добавляем GPG-ключ Docker
	sudo mkdir -p /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
		sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

	# Добавляем репозиторий Docker
	echo \
	  "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] \
	  https://download.docker.com/linux/ubuntu \
	  jammy stable" | \
	  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

	# Устанавливаем Docker
	sudo apt-get update -y
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io

	# Добавляем текущего пользователя в группу docker (чтобы не писать sudo)
	sudo usermod -aG docker $$USER
	@echo ">>> Docker installed!"

install_k3d:
	@echo ">>> Installing k3d..."
	# Ставим k3d в /usr/local/bin
	curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
	@echo ">>> k3d installed!"

install_kubectl:
	@echo ">>> Installing kubectl..."
	# Можно ставить через snap или напрямую через бинарник:
	# Пример установки через официальные бинарники:
	curl -LO "https://dl.k8s.io/release/v1.32.3/bin/linux/${ARCH}/kubectl"
	sudo install -m 0755 kubectl /usr/local/bin/kubectl
	rm -f kubectl
	@echo ">>> kubectl installed!"

install_argocd:
	@echo ">>> Installing Argo CD CLI..."
	# Пример установки определённой версии:
	curl -sSL -o argocd \
	  "https://github.com/argoproj/argo-cd/releases/download/$(ARGOCD_VERSION)/argocd-linux-${ARCH}"
	sudo install -m 0755 argocd $(ARGOCD_BIN)
	rm -f argocd
	@echo ">>> Argo CD CLI installed!"

# ~~~ ПРОВЕРКИ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

check_docker:
	@echo ">>> Checking Docker..."
	@command -v $(DOCKER) &> /dev/null && \
		($(DOCKER) --version && echo "Docker is installed!") || \
		(echo "Error: Docker not found" && exit 1)

check_k3d:
	@echo ">>> Checking k3d..."
	@command -v $(K3D) &> /dev/null && \
		($(K3D) version && echo "k3d is installed!") || \
		(echo "Error: k3d not found" && exit 1)

check_kubectl:
	@echo ">>> Checking kubectl..."
	@command -v $(KUBECTL) &> /dev/null && \
		($(KUBECTL) version --client && echo "kubectl is installed!") || \
		(echo "Error: kubectl not found" && exit 1)

check_argocd:
	@echo ">>> Checking Argo CD CLI..."
	@command -v $(ARGOCD) &> /dev/null && \
		($(ARGOCD) version --client && echo "Argo CD CLI is installed!") || \
		(echo "Error: Argo CD CLI not found" && exit 1)

# ~~~ УДАЛЕНИЕ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

remove_docker:
	@echo ">>> Removing Docker..."
	# Удаляем пакеты Docker
	sudo apt-get purge -y docker-ce docker-ce-cli containerd.io || true
	sudo apt-get autoremove -y
	# Удаляем папку docker, если хотим совсем начисто
	sudo rm -rf /var/lib/docker
	sudo rm -rf /var/lib/containerd
	# Удаляем репозиторий Docker
	sudo rm -f /etc/apt/sources.list.d/docker.list
	sudo rm -f /etc/apt/keyrings/docker.gpg
	@echo ">>> Docker removed!"

remove_k3d:
	@echo ">>> Removing k3d..."
	# Достаточно удалить бинарник из /usr/local/bin
	sudo rm -f $(K3D_BIN)
	@echo ">>> k3d removed!"

remove_kubectl:
	@echo ">>> Removing kubectl..."
	sudo rm -f $(KUBECTL_BIN)
	@echo ">>> kubectl removed!"

remove_argocd:
	@echo ">>> Removing Argo CD CLI..."
	sudo rm -f $(ARGOCD_BIN)
	@echo ">>> Argo CD CLI removed!"

# **************************************************************************** #

.PHONY: all fclean re install_docker install_k3d install_kubectl install_argocd \
	remove_docker remove_k3d remove_kubectl remove_argocd