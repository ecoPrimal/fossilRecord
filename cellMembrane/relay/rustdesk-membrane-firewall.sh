#!/bin/bash
# RUSTDESK_MEMBRANE — NAT-aware firewall chain for the commensal relay
# Run as root on any golgi body hosting hbbs/hbbr.
#
# What it does:
#   - ACCEPT all from HOUSE_WAN_IP (self — never rate-limit our own gates)
#   - REJECT tcp:21114 (dead API port — instant rejection, not silent timeout)
#   - ACCEPT RELATED,ESTABLISHED (existing connections pass)
#   - Rate-limit UDP :21116 at 120/10s per source IP (NAT-aware)
#   - Rate-limit TCP :21115-21118 new connections at 60/10s per source IP
#   - LOG before DROP (visibility)
#   - ACCEPT healthy traffic
#
# NAT Topology Trap (learned failure — TWO incidents):
#   Multiple gates behind the same WAN IP amplify packet counts.
#   Rate limits must account for NAT clustering.
#   Port 21114 MUST get instant REJECT, not silent timeout.
#
# Usage: sudo ./rustdesk-membrane-firewall.sh [HOUSE_WAN_IP]
# Example: sudo ./rustdesk-membrane-firewall.sh 162.226.225.148
#
# After running: sudo netfilter-persistent save

set -euo pipefail

HOUSE_IP="${1:-162.226.225.148}"

echo "=== Installing RUSTDESK_MEMBRANE chain (house IP: ${HOUSE_IP}) ==="

# Remove existing chain if present
iptables -D INPUT -p tcp -m multiport --dports 21115,21116,21117,21118 -j RUSTDESK_MEMBRANE 2>/dev/null || true
iptables -D INPUT -p udp -m udp --dport 21116 -j RUSTDESK_MEMBRANE 2>/dev/null || true
iptables -F RUSTDESK_MEMBRANE 2>/dev/null || true
iptables -X RUSTDESK_MEMBRANE 2>/dev/null || true

# Create chain
iptables -N RUSTDESK_MEMBRANE

# Rule 1: ACCEPT all from house network (self)
iptables -A RUSTDESK_MEMBRANE -s "${HOUSE_IP}/32" -j ACCEPT

# Rule 2: REJECT tcp:21114 (dead API port — instant rejection)
iptables -A RUSTDESK_MEMBRANE -p tcp --dport 21114 -j REJECT --reject-with tcp-reset

# Rule 3: ACCEPT RELATED,ESTABLISHED
iptables -A RUSTDESK_MEMBRANE -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Rule 4-6: UDP rate limiting (21116 heartbeats)
iptables -A RUSTDESK_MEMBRANE -p udp --dport 21116 \
  -m recent --set --name rd_membrane_udp --rsource
iptables -A RUSTDESK_MEMBRANE -p udp --dport 21116 \
  -m recent --update --seconds 10 --hitcount 120 --name rd_membrane_udp --rsource \
  -j LOG --log-prefix "RUSTDESK_UDP_RATELIMIT: "
iptables -A RUSTDESK_MEMBRANE -p udp --dport 21116 \
  -m recent --update --seconds 10 --hitcount 120 --name rd_membrane_udp --rsource \
  -j DROP
iptables -A RUSTDESK_MEMBRANE -p udp --dport 21116 -j ACCEPT

# Rule 7-10: TCP rate limiting (new connections to 21115-21118)
iptables -A RUSTDESK_MEMBRANE -p tcp -m multiport --dports 21115,21116,21117,21118 \
  -m conntrack --ctstate NEW \
  -m recent --set --name rd_membrane_tcp --rsource
iptables -A RUSTDESK_MEMBRANE -p tcp -m multiport --dports 21115,21116,21117,21118 \
  -m conntrack --ctstate NEW \
  -m recent --update --seconds 10 --hitcount 60 --name rd_membrane_tcp --rsource \
  -j LOG --log-prefix "RUSTDESK_TCP_RATELIMIT: "
iptables -A RUSTDESK_MEMBRANE -p tcp -m multiport --dports 21115,21116,21117,21118 \
  -m conntrack --ctstate NEW \
  -m recent --update --seconds 10 --hitcount 60 --name rd_membrane_tcp --rsource \
  -j DROP
iptables -A RUSTDESK_MEMBRANE -p tcp -m multiport --dports 21115,21116,21117,21118 -j ACCEPT

# Wire chain into INPUT
iptables -A INPUT -p tcp -m multiport --dports 21115,21116,21117,21118 -j RUSTDESK_MEMBRANE
iptables -A INPUT -p udp -m udp --dport 21116 -j RUSTDESK_MEMBRANE

echo "=== RUSTDESK_MEMBRANE installed ==="
iptables -L RUSTDESK_MEMBRANE -nvx
echo
echo "Run 'netfilter-persistent save' to persist across reboots."
