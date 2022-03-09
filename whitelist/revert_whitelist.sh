#!/bin/bash
#
# Revert changes made by whitelist.sh script.
# It will uninstall dnsmasq and reactivate systemd-resolved.

# Remove dnsmasq package
echo "Removing dnsmasq..."
apt remove dnsmasq -y
apt autoremove

echo "Starting systemd-resolved..."
systemctl start systemd-resolved
