# kubectl, aliased to kubecolor for coloured output
# shellcheck shell=bash

# Neither is packaged in Fedora. kubectl comes from the upstream Kubernetes
# repo, which is published per minor version: point it at the current stable
# one (re-running the script moves it to a newer minor).
K8S_MINOR=$(curl -fsSL https://dl.k8s.io/release/stable.txt | sed -nE 's/^v([0-9]+\.[0-9]+)\..*/\1/p')
if [ -n "${K8S_MINOR}" ]; then
    sudo tee /etc/yum.repos.d/kubernetes.repo > /dev/null << EOF
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v${K8S_MINOR}/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v${K8S_MINOR}/rpm/repodata/repomd.xml.key
EOF
    sudo dnf -y install kubectl || warn "kubectl install failed"
else
    warn "could not look up the Kubernetes version, skipping kubectl"
fi

# kubecolor: RPM from the latest GitHub release
case "$(uname -m)" in
    x86_64) KC_ARCH=amd64 ;;
    aarch64) KC_ARCH=arm64 ;;
    *) KC_ARCH= ;;
esac
KC_VERSION=$(curl -fsSL https://api.github.com/repos/kubecolor/kubecolor/releases/latest \
    | sed -nE 's/.*"tag_name": *"v([^"]+)".*/\1/p')
if [ -z "${KC_ARCH}" ] || [ -z "${KC_VERSION}" ]; then
    warn "could not find a kubecolor release for $(uname -m), skipping it"
elif [ "$(rpm -q --qf '%{VERSION}' kubecolor 2> /dev/null)" != "${KC_VERSION}" ]; then
    sudo dnf -y install "https://github.com/kubecolor/kubecolor/releases/download/v${KC_VERSION}/kubecolor_${KC_VERSION}_linux_${KC_ARCH}.rpm" \
        || warn "kubecolor install failed"
fi

# The alias, with tab completion kept
install -m 644 "${ROOT}/files/bashrc.d/kubecolor" "${HOME}/.bashrc.d/kubecolor"
