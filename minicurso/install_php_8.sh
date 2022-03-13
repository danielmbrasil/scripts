#!/bin/bash
#
# The following script install PHP 8 from Ondrej PPA for Nginx.
#
# This script must be run as root.
#
# Install required packages for adding a PPA repository.
echo "Updating sources list and installing required packages..."
apt update
apt upgrade -y
apt install ca-certificates apt-transport-https software-properties-common -y

# Add Ondrej repository
echo "Adding Ondrej repository..."
add-apt-repository ppa:ondrej/php

# Update and upgrade packages again
echo "Updating sources list and upgrading packages..."
apt update
apt upgrade -y

# Install PHP
echo "Installing PHP..."
apt install php8.0-fpm -y

# Start and enable service
echo "Enabling PHP service..."
systemctl start php8.0-fpm
systemctl enable php8.0-fpm
systemctl status php8.9-fpm

# Install PHP extensions
echo "Installing PHP extensions..."
apt install php-memcached php8.0-mysql php8.0-snmp php8.0-curl -y
