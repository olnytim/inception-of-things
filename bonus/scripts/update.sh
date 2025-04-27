#!/bin/bash

PURPLE='\033[0;35m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

set -euo pipefail

if [ "$#" -lt 1 ]; then
	echo -e "${RED}Error: no repository name${NC}"
	echo -e "${YELLOW}Try: $0 <gilab-repo-name>${NC}"
	exit 1
fi

REPO_NAME="$1"
NAMESPACE="gitlab"
GL_HOST="gitlab.k3d.gitlab.com"

clone_or_exit() {
	local url=$1 dest=$2
	if ! git clone "$url" "$dest"; then
		echo -e "${RED}Error: trouble with clone repo $url${NC}"
		exit 1
	fi
}

GITLAB_PASS=$(kubectl get secret gitlab-gitlab-initial-root-password -n ${NAMESPACE} -o jsonpath="{.data.password}" | base64 --decode)

cat <<EOF > ~/.netrc
machine ${GL_HOST}
login root
password ${GITLAB_PASS}"
EOF
sudo chmod 777 ~/.netrc
sudo cp -r ~/.netrc /root/

clone_or_exit http://${GL_HOST}:8080/root/${REPO_NAME}.git git_repo

clone_or_exit https://github.com/olnytim/inception-of-things.git iot

mv iot/p3/confs/dev git_repo
rm -rf iot

cd git_repo
git add .
git commit -m "update dev"
git push
cd ..

kubectl apply -f ../confs/deployment.yaml

echo -e "${GREEN}ENTER: ${PURPLE}kubectl port-forward --address 0.0.0.0 svc/svc-wil -n dev 8887:8080${NC}"
