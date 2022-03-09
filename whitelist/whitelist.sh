#!/bin/bash
#
# Use dnsmasq to create a whitelist of allowed websites. Any other website
# that is not mentioned in the list will be blocked.

# Function to check if a given serive exists. It's used to check if systemd-resolved is running.
service_exists() {
	local n=$1
	if [[ $(systemctl list-units --all -t service --full --no-legend "$n.service" | sed 's/^\s*//g' | cut -f1 -d' ') == $n.service ]]; then
		return 0
	else
	   	return 1
	fi
}

# Install dnsmasq
echo "Installing dnsmasq..."
apt update
apt install dnsmasq -y

# Check if systemd-resolved is running, if so, stop it.
if service_exists systemd-resolved; then
	echo "Stopping systemd-resolved..."
	systemctl stop systemd-resolved
fi

# Start dnsmasq
echo "Starting dnsmasq..."
systemctl start dnsmasq

# Append whitelist to /etc/dnsmasq.conf
# First, make all websites redirect to localhost
echo "address=/#/127.0.0.1" >> /etc/dnsmasq.conf

# Now, provide what websites are allowed with a specific DNS server IP
# To add more websites, keep appending them to /etc/dnsmasq.conf
# The websites below are for the Beecrowd platform to work properly.
echo "server=/www.beecrowd.com.br/8.8.8.8" >> /etc/dnsmasq.conf
echo "server=/resources.beecrowd.com.br/8.8.8.8" >> /etc/dnsmasq.conf
echo "server=/www.gravatar.com/8.8.8.8" >> /etc/dnsmasq.conf
echo "server=/code.jquery.com/8.8.8.8" >> /etc/dnsmasq.conf

echo "Whitelist set up, restarting dnsmasq..."
systemctl restart dnsmasq

