#!/bin/bash
#
# This script install Docker Compose standalone version (docker-compose)
# The installed version is v2.11.2
#
# Author: Daniel M Brasil

echo "Downloading Docker Compose ..."
curl -SL https://github.com/docker/compose/releases/download/v2.11.2/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose

echo "Applying executable permissions..."
sudo chmod a+x /usr/local/bin/docker-compose

sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose # to avoid path related issues

echo "Testing Docker Compose..."

docker-compose --version

exit 0
