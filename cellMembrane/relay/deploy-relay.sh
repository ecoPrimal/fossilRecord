#!/bin/bash
# deploy-relay.sh — Deploy commensal RustDesk relay to any golgi body
#
# This script deploys the full outer membrane relay:
#   - hbbs (rendezvous) + hbbr (relay) systemd services
#   - RUSTDESK_MEMBRANE firewall chain
#   - Beacon info page
#   - Server key pair (generated if missing, immutable once set)
#
# Prerequisites on target:
#   - /opt/membrane/hbbs and /opt/membrane/hbbr binaries (static musl)
#   - iptables + netfilter-persistent
#   - Caddy (for beacon page HTTPS)
#
# Usage: ./deploy-relay.sh <ssh-host> [house-wan-ip]
# Example: ./deploy-relay.sh golgi 162.226.225.148
# Example: ./deploy-relay.sh golgi-de 162.226.225.148

set -euo pipefail

TARGET="${1:?Usage: $0 <ssh-host> [house-wan-ip]}"
HOUSE_IP="${2:-162.226.225.148}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Deploying commensal relay to ${TARGET} ==="
echo "    House WAN IP: ${HOUSE_IP}"

# 1. Service files
echo "[1/5] Installing service files..."
scp -q "${SCRIPT_DIR}/hbbs-membrane.service" "${TARGET}:/tmp/hbbs-membrane.service"
scp -q "${SCRIPT_DIR}/hbbr-membrane.service" "${TARGET}:/tmp/hbbr-membrane.service"
ssh "${TARGET}" '
  sudo mv /tmp/hbbs-membrane.service /etc/systemd/system/hbbs-membrane.service
  sudo mv /tmp/hbbr-membrane.service /etc/systemd/system/hbbr-membrane.service
  sudo systemctl daemon-reload
'

# 2. Key pair (generate if missing, never overwrite)
echo "[2/5] Checking key pair..."
ssh "${TARGET}" '
  if [ ! -f /opt/membrane/id_ed25519 ]; then
    echo "  Generating new key pair..."
    cd /opt/membrane && sudo ./hbbs --help >/dev/null 2>&1 || true
    # hbbs generates keys on first run in working dir
    sudo timeout 3 /opt/membrane/hbbs 2>/dev/null || true
    if [ -f /opt/membrane/id_ed25519 ]; then
      sudo chattr +i /opt/membrane/id_ed25519
      echo "  Key generated and immutable."
      echo "  Public key: $(cat /opt/membrane/id_ed25519.pub)"
    else
      echo "  WARNING: Key generation failed. Run hbbs manually once."
    fi
  else
    echo "  Key exists (immutable). Public: $(cat /opt/membrane/id_ed25519.pub)"
  fi
'

# 3. Firewall
echo "[3/5] Installing RUSTDESK_MEMBRANE firewall chain..."
scp -q "${SCRIPT_DIR}/rustdesk-membrane-firewall.sh" "${TARGET}:/tmp/rustdesk-membrane-firewall.sh"
ssh "${TARGET}" "
  sudo bash /tmp/rustdesk-membrane-firewall.sh '${HOUSE_IP}'
  sudo netfilter-persistent save 2>/dev/null || echo '  (netfilter-persistent not available — save manually)'
  rm /tmp/rustdesk-membrane-firewall.sh
"

# 4. Beacon page
echo "[4/5] Installing beacon page..."
ssh "${TARGET}" 'sudo mkdir -p /opt/membrane/beacon-page'
scp -q "${SCRIPT_DIR}/beacon-page/index.html" "${TARGET}:/tmp/beacon-index.html"
ssh "${TARGET}" 'sudo mv /tmp/beacon-index.html /opt/membrane/beacon-page/index.html'

# 5. Start services
echo "[5/5] Starting services..."
ssh "${TARGET}" '
  sudo systemctl enable --now hbbs-membrane hbbr-membrane
  echo "  hbbs: $(systemctl is-active hbbs-membrane)"
  echo "  hbbr: $(systemctl is-active hbbr-membrane)"
  echo
  echo "  Ports:"
  ss -tlnp 2>/dev/null | grep -E "21115|21116|21117|21118" | sed "s/^/    /"
  ss -ulnp 2>/dev/null | grep "21116" | sed "s/^/    /"
'

echo
echo "=== Relay deployed to ${TARGET} ==="
echo
echo "Caddy config needed (add to Caddyfile on ${TARGET}):"
echo
cat << 'CADDY'
# === Commensal Relay Beacon Page ===
beacon.primals.eco {
    import security_headers
    import access_log
    root * /opt/membrane/beacon-page
    file_server
}

# === relay.primals.eco redirect to beacon page ===
relay.primals.eco {
    redir https://beacon.primals.eco{uri} permanent
}
CADDY
echo
echo "DNS needed:"
echo "  relay.primals.eco  → A → <golgi-ip>"
echo "  beacon.primals.eco → A → <golgi-ip>"
echo
echo "Client config:"
echo "  custom-rendezvous-server = 'relay.primals.eco'"
echo "  relay-server = 'relay.primals.eco'"
echo "  (no key needed — Tier 1 keyless)"
