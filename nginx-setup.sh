#!/bin/bash
set -euo pipefail

# Options: "stable" or "mainline"
NGINX_BRANCH="${1:-stable}"

echo "Installing nginx ($NGINX_BRANCH) on $(lsb_release -ds)..."

# Prerequisites
apt update
apt install -y curl gnupg2 ca-certificates lsb-release debian-archive-keyring

# Signing key
if [ ! -d ~/.gnupg ]; then
    mkdir ~/.gnupg && chmod 700 ~/.gnupg
fi

curl -fsSL https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
    | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

# Verify fingerprint
FINGERPRINT=$(gpg --dry-run --quiet --no-keyring --import --import-options import-show \
    /usr/share/keyrings/nginx-archive-keyring.gpg | grep -o '[0-9A-F]\{40\}')

# Repository - https://nginx.org/en/linux_packages.html
EXPECTED="573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62"
if [ "$FINGERPRINT" != "$EXPECTED" ]; then
    echo "ERROR: Key fingerprint mismatch! Got: $FINGERPRINT"
    exit 1
fi
echo "Key verified: $FINGERPRINT"

if [ "$NGINX_BRANCH" = "mainline" ]; then
    REPO_PATH="mainline/debian"
else
    REPO_PATH="debian"
fi

echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
https://nginx.org/packages/${REPO_PATH} $(lsb_release -cs) nginx" \
    > /etc/apt/sources.list.d/nginx.list

# Pinning
printf "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
    > /etc/apt/preferences.d/99nginx

# Install
apt update
apt install -y nginx

# Enable and start
systemctl enable --now nginx

echo "Done. $(nginx -v 2>&1)"