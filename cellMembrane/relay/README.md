# Commensal Relay — Deployment Kit

**Wave 171 — October 9, 2026**

Deploys a sovereign RustDesk relay (outer membrane) to any golgi body.

## What's In Here

```
relay/
├── README.md                          ← You are here
├── deploy-relay.sh                    ← One-shot deploy to any golgi via SSH
├── hbbs-membrane.service              ← Rendezvous service (registration, discovery, NAT)
├── hbbr-membrane.service              ← Relay service (encrypted traffic forwarding)
├── rustdesk-membrane-firewall.sh      ← RUSTDESK_MEMBRANE iptables chain
└── beacon-page/
    └── index.html                     ← Public info page at beacon.primals.eco
```

## Quick Deploy

```bash
# Deploy to golgiBody (NYC)
./deploy-relay.sh golgi 162.226.225.148

# Deploy to any new golgi
./deploy-relay.sh golgi-xx <house-wan-ip>
```

## Prerequisites on Target

1. **Binaries**: `/opt/membrane/hbbs` and `/opt/membrane/hbbr` (RustDesk server, static musl)
   - Download from [rustdesk-server releases](https://github.com/rustdesk/rustdesk-server/releases)
   - Extract, `chmod +x`, place in `/opt/membrane/`

2. **iptables** + `netfilter-persistent` (for firewall persistence)

3. **Caddy** (for beacon page HTTPS) — add the Caddyfile snippet printed by deploy script

4. **DNS**: `relay.primals.eco` + `beacon.primals.eco` → golgi IP

## Architecture

```
Client (any RustDesk)
  │
  │  relay.primals.eco:21116 (TCP+UDP)
  │  relay.primals.eco:21115 (TCP, NAT test)
  │  relay.primals.eco:21118 (WebSocket)
  ▼
┌─────────────────────────────────┐
│ RUSTDESK_MEMBRANE (iptables)    │
│  ├── ACCEPT house WAN IP        │
│  ├── REJECT :21114 (dead port)  │
│  ├── ACCEPT ESTABLISHED         │
│  ├── Rate-limit UDP 120/10s     │
│  ├── Rate-limit TCP 60/10s      │
│  ├── LOG before DROP             │
│  └── ACCEPT healthy traffic      │
└─────────────────────────────────┘
  │
  ▼
┌────────────┐   ┌────────────┐
│ hbbs       │   │ hbbr       │
│ rendezvous │   │ relay      │
│ :21115-18  │   │ :21117     │
└────────────┘   └────────────┘
  │
  │  E2E encrypted (relay sees ciphertext)
  ▼
Client B (peer)
```

## Three-Tier Privacy (Paper 47)

| Tier | Name | Entry | riboCipher |
|------|------|-------|-----------|
| 1 | Beacon | Keyless — `relay.primals.eco` | `0xEC` clear |
| 2 | Family | `.beacon.seed` via USB | `0xED` mito-obfuscated |
| 3 | Sovereign | bearDog lineage + WireGuard | `0xEE` nuclear-sealed |

This kit deploys **Tier 1** — the public beacon. Tier 2 and 3 ride on songBird and WireGuard (separate deployment).

## Key Management

- Server key pair generated on first hbbs run at `/opt/membrane/id_ed25519{,.pub}`
- Key is made immutable: `chattr +i /opt/membrane/id_ed25519`
- hbbs runs WITHOUT `-k` flag → clients may omit the key (Tier 1 keyless)
- Clients who include the key get server identity verification (optional hardening)
- Key is published on the beacon page for those who want it

## NAT Topology Trap (learned failure)

Multiple gates behind the same WAN IP amplify both UDP and TCP packet counts. Rate limits must account for NAT clustering:
- UDP: 120 packets/10s (was 30 — too low for 3+ gates behind NAT)
- TCP: 60 new connections/10s
- Port 21114: REJECT with tcp-reset (dead API port — silent timeout poisons TCP rate counter)

## Client Config

```toml
# ~/.config/rustdesk/RustDesk2.toml [options]
custom-rendezvous-server = 'relay.primals.eco'
relay-server = 'relay.primals.eco'
verification-method = 'use-permanent-password'

# Optional: verify relay identity (anti-MITM)
# key = 'utlNOAWUDdV+Q+ifG3zHrQ5HU0FtQnOTHiAnu6prV7Q='
```

**Important**: Stop `rustdesk.service` before editing config — it overwrites on restart.
