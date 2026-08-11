# Fossil Record — Wave 66 Script Evacuation (June 2026)

wateringHole was cleaned to **zero code** per its role as the
comms/standards repo that initiates the waterFall cascade.

## What Was Fossilized

| Script | Lines | Rust Replacement | Owner |
|---|---|---|---|
| `hooks/forgejo/pepti-sync-relay.sh` | 95 | `membrane relay.mediate` | cellMembrane |
| `hooks/forgejo/ext-github-push.sh` | 91 | `membrane relay.ship` | cellMembrane |
| `hooks/forgejo/impulse-relay-hook.sh` | 52 | `membrane impulse.post` | cellMembrane |
| `hooks/forgejo/setup-push-mirrors.sh` | 111 | manifest-driven relay | cellMembrane |
| `hooks/forgejo/golgi-post-receive-relay.sh` | 37 | bash (Forgejo constraint) | cellMembrane |
| `scripts/cascade-pull.sh` | 1029 | `membrane temporal.cascade` | cellMembrane |
| `scripts/beacon_tunnel.sh` | 194 | sovereign S2 NAT | projectNUCLEUS |
| `scripts/s1-tls-gate-probe.sh` | 54 | `membrane tls.*` | cellMembrane |
| `cascade-pull.sh` (root copy) | 1029 | `membrane temporal.cascade` | cellMembrane |
| `bootstrap.sh` | 391 | `membrane provision.*` | cellMembrane |
| `compute-sharing/setup-jupyterhub.sh` | 143 | future primal | TBD |

## What Was Relocated

| Artifact | From | To | Reason |
|---|---|---|---|
| `golgi-post-receive-relay.sh` | `wateringHole/hooks/forgejo/` | `cellMembrane/deploy/hooks/forgejo/` | K-Derm deployment artifact |
| `context-sense.sh` | `wateringHole/hooks/cursor/` | `cellMembrane/deploy/hooks/cursor/` | Calls membrane binary |
| `cloudflared-config.yml.template` | `wateringHole/templates/` | fossilRecord | Sovereignty S2 supersedes |
| `wetspring-science-facade.service` | `wateringHole/templates/` | `springs/wetSpring/deploy/` | Belongs with its project |

## What Stays in wateringHole

- `ecosystem_manifest.toml` — central ecosystem config
- `systemd/cascade-pull.{service,timer}` — deployment templates (updated to use `membrane`)
- `hooks/cursor/{hooks.json,README.md,context-braid-workflow.rule.md}` — cursor hook standards
- `impulses/` — impulsePotential message store
- `handoffs/` — team handoff documents
- `context/` — gate context braids
- `genomeBin/` — compiled primal binary distribution
- All `.md` and `.toml` files — standards, docs, tracking
