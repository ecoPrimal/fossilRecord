# sporeGate Wave 170 — Reboot Resilience Triage + Test

**Date**: October 9, 2026
**Machine**: sporeGate (inner membrane / peptidoglycan gateway)
**Test**: Cold reboot from 19 days uptime, monitored from golgiBody via WireGuard ping
**Result**: ALL services auto-recovered. Total outage ~6 minutes.

---

## Triage — Pre-Reboot Assessment

### Initial Misdiagnosis

Initial triage without `sudo` showed nftables "empty" and WireGuard "0 peers," suggesting critical services were down. This was **wrong** — both `nft list tables` and `wg show` require root privileges. All services were healthy the entire time.

**Lesson**: Always use `sudo` when querying nftables and WireGuard state. Non-root queries return empty results without error.

### Actual State (Pre-Reboot)

| Component | Status | Notes |
|-----------|--------|-------|
| dnsmasq (DNS/DHCP) | HEALTHY | 10 active leases, listening on :53 |
| nftables (firewall) | HEALTHY | 7 chains, 37 rules, NAT, bogon drops, rate limiting |
| wg-quick@wg0 (WireGuard) | HEALTHY | 1 peer to golgiBody (157.230.3.183), handshake < 30s ago |
| stubby (DNS-over-TLS) | HEALTHY | Upstream on :5353, dnsmasq forwards to it |
| RustDesk | HEALTHY | Service running, key confirmed |
| enp1s0 (WAN) | INTENTIONALLY DOWN | Unmanaged in networkd, no cable. ATT BGW320 at .1 does WAN |

### Current Topology (corrected)

```
Internet → ATT BGW320 (192.168.4.1) → CRS310 L2 → sporeGate (.3) + LAN devices
                                                   ├── eno1 (wired LAN, .3)
                                                   ├── wlp3s0 (WiFi backup, .198)
                                                   └── wg0 (WireGuard, 10.13.37.2)
```

sporeGate provides DNS/DHCP/firewall/WireGuard to the LAN. It does NOT do WAN passthrough — the BGW320 at .1 handles NAT and routing to the ISP. This is simpler than the plan assumed (enp1s0 passthrough was an older topology).

---

## Reboot Test

### Pre-Reboot Snapshot

```
Timestamp:        2026-10-09T20:40:18Z
Uptime:           19 days, 8:36
DHCP leases:      10
WG handshake:     30 seconds ago
WG transfer:      289.84 MiB received, 603.65 MiB sent
nftables hash:    827ea99fdc3057dbff045ae76748f7d385101918d8fb7a210f6bcc3258afa655
Routes:           8 (default via .1, WG, LAN, WiFi backup, stranded subnet)
```

### Monitor Setup

Ping monitor deployed on golgiBody (157.230.3.183) pinging sporeGate's WireGuard address (10.13.37.2) every 3 seconds.

### Reboot Execution

User rebooted manually with peripherals plugged in (keyboard/monitor). Boot timestamp: 2026-10-09T20:43 UTC.

### Observed Downtime

```
20:41:38  UP    (last UP before shutdown)
20:41:43  DOWN  (shutdown begins)
...
~20:48:06 UP    (WG handshake re-established)
```

**Total WireGuard outage: ~6 minutes 23 seconds** (includes user physically plugging in peripherals and issuing reboot command).

**Boot-to-WG-handshake: ~5 minutes** (from 20:43 boot timestamp to ~20:48 first UP).

This is longer than the estimated 50-60s from the plan. The extra time is likely BIOS POST + GRUB + systemd service ordering + WireGuard initial handshake (25s keepalive interval).

### Post-Reboot Validation

| Check | Result | Match Pre-Reboot? |
|-------|--------|-------------------|
| dnsmasq | active (enabled) | YES |
| nftables | active (enabled) | YES |
| wg-quick@wg0 | active (enabled) | YES |
| stubby | active (enabled) | YES |
| DHCP leases | 10 | YES (identical) |
| nftables rules | 7 chains, 37 rules | YES (counter reset is only diff) |
| Interfaces | eno1 UP .3, wlp3s0 UP .198, wg0 UP 10.13.37.2 | YES |
| Routes | 8 routes, default via .1 | YES |
| DNS resolution | google.com → 142.250.217.110 | YES |
| Internet | ping 8.8.8.8 → 19.8ms | YES |
| WG handshake | 11 seconds ago | YES |

**Verdict: PASS — all services auto-recovered with zero manual intervention.**

---

## Issues Found

### 1. RustDesk Key Mismatch on northGate (LOW)

After reboot, northGate reported "key mismatch" when trying to RustDesk to sporeGate. This is a client-side config issue on northGate — the server key `utlNOAWUDdV+Q+ifG3zHrQ5HU0FtQnOTHiAnu6prV7Q=` needs to be in northGate's RustDesk2.toml options:

```toml
custom-rendezvous-server = 'beacon.primals.eco'
relay-server = 'beacon.primals.eco'
key = 'utlNOAWUDdV+Q+ifG3zHrQ5HU0FtQnOTHiAnu6prV7Q='
```

Note: RustDesk overwrites its config file on service restart, so edits must be made while the service is stopped.

### 2. Boot Time Exceeds Estimate (~5min vs ~60s)

The plan estimated 50-60s total downtime. Actual boot-to-WG was ~5 minutes. Root cause likely:
- BIOS POST on this hardware (HP EliteDesk?) is slow
- GRUB timeout (default 5s)
- systemd service startup chain with dependencies
- WireGuard persistent keepalive interval (25s) means first handshake takes up to 25s after the interface is UP

**Action**: Could reduce GRUB timeout to 1s, investigate BIOS fast boot options. The 5-minute window is acceptable for an inner membrane — LAN clients keep their DHCP leases (12h TTL) and only lose DNS resolution during this window.

### 3. sudo Required for Visibility (LEARNING)

Both `nft list tables` and `wg show` return empty results without sudo, giving no error. This creates a false impression that services are down. Monitoring/health probes must use sudo or run as root.

---

## Resilience Assessment

### What Survived

- All 4 critical services (dnsmasq, nftables, WireGuard, stubby) auto-started via systemd
- DHCP lease file persisted through reboot (file-backed at `/var/lib/dnsmasq/dnsmasq.leases`)
- nftables loaded from `/etc/nftables.conf` (structurally identical, only counters reset)
- WireGuard config preserved, handshake re-established via persistent keepalive
- Route table restored (static routes in networkd, WG route via wg-quick)
- WiFi backup path (wlp3s0) came back as secondary route

### What Breaks During Downtime

- LAN DNS resolution (~5 min) — clients can't resolve names
- DHCP renewals blocked (~5 min) — but 12h lease TTL means no client loses its IP
- WireGuard tunnel to golgiBody (~5 min) — inner membrane severed temporarily
- RustDesk connectivity — depends on relay, not local state

### Impact on the Mesh

During the 5-minute window:
- golgiBody observed sporeGate's WG endpoint as DOWN
- No impact on golgi federation (layers don't route through sporeGate)
- LAN devices keep internet (BGW320 at .1 handles routing independently)
- LAN devices lose DNS (must wait or use fallback)

---

## Anderson Frame: Reboot as Membrane Permeability Event

In the Anderson framework from Paper 46:
- A reboot sets P → 0 for ALL modes (total impermeability, not selective)
- Selectivity S → 0 (not because everything passes, but because nothing does)
- The imaginary dimension spikes (massive negative residual — "active defense" beyond equilibrium, but actually it's a blackout)
- Recovery: P returns to pre-reboot values as services restart
- The 5-minute window is the "refractory period" of the membrane

This is a fundamentally different failure mode from a security breach (where P → 1 for parasites). A reboot is a **temporary total localization** — everything is blocked, nothing propagates. The membrane recovers its selective permeability as services come back online in the correct order.

---

## Invariants Preserved

- No PII in this writeup
- No raw IPs from DHCP clients (only device names from lease file, which are self-declared)
- Schwann cell isolation maintained — RustDesk IDs not published
- We don't rewrite the past — this is a new observation, not a modification of prior work
