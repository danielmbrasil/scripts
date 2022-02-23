#!/bin/bash
#
# /etc/firewall.sh
#
# This script set basic iptables rules using iptables-legacy for a full LXD
# Linux server.
#
# This script set all rules needed for LXD to operate corretly (LXD bridge IP 
# has to be set on this script).
#
# For LXD to operate corretly, you must disable firewall parameter on your LXD
# bridge configs (ipv4.firewall must be false).
#
# INPUT and FORWARD policies are DROP, with specific rules for these chains.
# DROP policy is ACCEPT by default.
#
# This script only offers basic filtering, further improvements will be made.

echo "Clearing any existing rules and setting default policy..."
iptables-legacy -F
iptables-legacy -X
iptables-legacy -P INPUT DROP
iptables-legacy -P FORWARD DROP
iptables-legacy -P OUTPUT ACCEPT

# Accept everything from loopback interface
echo "Setting up loopback interface..."
iptables-legacy -A INPUT -i lo -j ACCEPT
iptables-legacy -A OUTPUT -j lo -i ACCEPT

# For LXD to get IP addresses from DHCP
echo "Setting up policy and rules for lxdbr0..."
iptables-legacy -A INPUT -i lxdbr0 -j ACCEPT

# DNS rules
echo "Setting up DNS rules..."
iptables-legacy -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables-legacy -A INPUT -p tcp -j REJECT --reject-with tcp-reset
iptables-legacy -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable

# LXD rules
# These rules are the original LXD rules added automatically when ipv4.firewall
# is set to true.
echo "Setting up LXD rules..."
iptables-legacy  -A INPUT -j ACCEPT -p TCP --dport domain -m comment --comment "/*generated for LXD bridge*/"
iptables-legacy  -A INPUT -j ACCEPT -p UDP --dport domain -m comment --comment "*/generated for LXD bridge*/"
iptables-legacy  -A INPUT -j ACCEPT -p UDP --dport bootps -m comment --comment "/*generated for LXD bridge*/"

iptables-legacy  -A OUTPUT -j ACCEPT -p TCP --sport domain -m comment --comment "/*generated for LXD bridge*/"
iptables-legacy  -A OUTPUT -j ACCEPT -p UDP --sport domain -m comment --comment "/*generated for LXD bridge*/"
iptables-legacy  -A OUTPUT -j ACCEPT -p UDP --sport bootps -m comment --comment "/*generated for LXD bridge*/"

iptables-legacy  -A FORWARD -j ACCEPT -m comment --comment "/*generated for LXD bridge*/"

# Replace LXD.BRIDGE.IP wtih your bridge's private IP.
iptables-legacy  -t nat -A POSTROUTING -s LXD.BRIDGE.IP/24 ! -d LXD.BRIDGE.IP/24 -m comment --comment "/*generated for LXD bridge*/" -j MASQUERADE

# Forward incoming packets.
# If you want to forward specific packets (e.g. forward incoming packets on port 80)
# to a container this rule can be used (tcp packets).
# Replace HOST.INTERFACE with your host interface's name (e.g. eth0)
# Replace HOST.INTERNAL.IP with your host IP.
# Replace HOST.PORT with your host's port (e.g. 80 for HTTP).
# Replace CONTAINER.IP with container's IP.
# Replace COTAINER.PORT with container's port.
echo "Setting up PREROUTING rules to forward incoming packets..."
iptables-legacy -t nat -I PREROUTING -i HOST.INTERFACE -p TCP -d HOST.INTERNAL.IP --dport HOST.PORT -j DNAT --to-destination CONTAINER.IP:CONTAINER.PORT 

# Save iptables rules to /etc/iptables-legacy.conf
iptables-legacy-save > /etc/iptables-legacy.conf
