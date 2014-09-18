#!/bin/sh
### BEGIN INIT INFO
# Provides: myfirewall
# Required-Start: $remote_fs $syslog $network
# Required-Stop: $remote_fs $syslog $network
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: firewall initscript
# Description: Custom Firewall
### END INIT INFO

#########################
# Firewall
#########################

# Initialise la table Filter
echo " + Initialisation de la table Filter"
iptables -t filter -F
iptables -t filter -X
iptables -t filter -P INPUT DROP
iptables -t filter -P FORWARD DROP
iptables -t filter -P OUTPUT ACCEPT
iptables -t nat -P OUTPUT ACCEPT
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT

echo " + Activation du routage"
echo "1" > /proc/sys/net/ipv4/ip_forward

# Creation des regles
echo " + Regles localhost"
iptables -t filter -A INPUT -i lo -p all -j ACCEPT

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

echo " + Regles du ping"
iptables -A INPUT -p icmp -j ACCEPT

# Limiter le SYN FLOOD
iptables -A FORWARD -p tcp --syn -m limit --limit 1/second -j ACCEPT
iptables -A FORWARD -p udp -m limit --limit 1/second -j ACCEPT
iptables -A FORWARD -p icmp --icmp-type echo-request -m limit --limit 1/second -j ACCEPT

# Bloquer le scan de port
iptables -A FORWARD -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s -j ACCEPT

# Service
# SSH
echo " + Ouverture serveur SSH"
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT

echo " + Ouverture serveur HTTP"
iptables -t filter -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 443 -j ACCEPT

echo " + Ouverture serveur FTP"
iptables -t filter -A INPUT -p tcp --dport 20 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 20 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 21 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 21 -j ACCEPT
iptables -t filter -A INPUT -p udp --dport 20 -j ACCEPT
iptables -t filter -A OUTPUT -p udp --dport 20 -j ACCEPT
iptables -t filter -A INPUT -p udp --dport 21 -j ACCEPT
iptables -t filter -A OUTPUT -p udp --dport 21 -j ACCEPT

echo " + Ouverture serveur DNS"
iptables -t filter -A INPUT -p tcp --dport 53 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 53 -j ACCEPT

echo " + Transmission"
iptables -t filter -A INPUT -p tcp --dport 9091 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 9091 -j ACCEPT
iptables -t filter -A INPUT -p udp --dport 9091 -j ACCEPT
iptables -t filter -A OUTPUT -p udp --dport 9091 -j ACCEPT

echo " + OpenVPN"
iptables -I FORWARD -i tun0 -j ACCEPT
iptables -I FORWARD -o tun0 -j ACCEPT
iptables -I OUTPUT -o tun0 -j ACCEPT

iptables -A FORWARD -i tun0 -o eth0 -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.8.0.2/24 -o eth0 -j MASQUERADE

echo " + Serveur Fb-flo"
iptables -t filter -A INPUT -p tcp --dport 8888 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 8888 -j ACCEPT
iptables -t filter -A INPUT -p udp --dport 8888 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 8888 -j ACCEPT
