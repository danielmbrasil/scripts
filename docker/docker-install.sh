#!/bin/bash
#
# Installation of Docker Engine for Debian-base distro
# This script follows the official docs that can be found at: https://docs.docker.com/engine/install/debian/
#
# Post-installation: this script appends $USER to the docker group
#
# Author: Daniel M Brasil

echo "Uninstalling old Docker versions (if any exists)..."

apt-get remove docker docker-engine docker.io containerd runc

echo "Setting up Docker repository..."

apt-get update
apt-get install ca-certificates curl gnupg lsb-release

echo "Adding Docker's official GPG key..."

mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

chmod a+r /etc/apt/keyrings/docker.gpg # to avoid GPG erros

echo "Installing Docker..."
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "Appending ${USER} to Docker group..."
usermod -aG docker $USER

echo "Testing instalation..."
docker run hello-world

echo "Installation completed"
exit 0
