#!/usr/bin/env bash
# membrane-census-serve.sh — local commensal census + HTTP serve
# Runs on nucleus and linode (non-golgi nodes).
# 1. Runs the local census, writes commensals.json
# 2. Serves it on port 9753 (mesh-internal only)
#
# The HTTP server is a one-shot: generates fresh JSON and serves it.
# Cron runs this every 5 minutes to keep the file fresh.
# A tiny socat/nc listener runs continuously for on-demand fetches.

set -euo pipefail

python3 << 'CENSUS'
import subprocess, os, re, json
from datetime import datetime, timezone

now = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')

def run(cmd):
    try:
        r = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=10)
        return r.stdout.strip()
    except:
        return ''

ROLES = {
    'caddy': ('GUARDIAN', 'reverse proxy, TLS, routing'),
    'skunky-ingest': ('GUARDIAN', 'log ingest'),
    'fail2ban-server': ('GUARDIAN', 'brute-force defense'),
    'nestgate': ('GUARDIAN', 'perimeter security'),
    'beardog': ('GUARDIAN', 'watchdog'),
    'step-ca': ('GUARDIAN', 'internal CA'),
    'opsonize-rs': ('IMMUNE', 'entity tagging'),
    'barracuda': ('IMMUNE', 'classifier'),
    'skunkbat': ('IMMUNE', 'batch immune'),
    'petaltongue': ('NERVE', 'API layer'),
    'signal-relay': ('NERVE', 'signal routing'),
    'songbird': ('NERVE', 'federation'),
    'swarmvine': ('NERVE', 'gossip mesh'),
    'dnsmasq': ('NERVE', 'mesh DNS'),
    'knotd': ('NERVE', 'DNS authority'),
    'squirrel': ('BRAIN', 'observation engine'),
    'sweetgrass': ('MEMORY', 'attribution braids'),
    'rhizocrypt': ('MEMORY', 'content addressing'),
    'loamspine': ('MEMORY', 'append-only ledger'),
    'forgejo': ('MEMORY', 'git forge'),
    'hbbs': ('COMMENSAL', 'RustDesk signaling'),
    'hbbr': ('COMMENSAL', 'RustDesk relay'),
    'cron': ('AUTONOMIC', 'scheduler'),
    'systemd': ('AUTONOMIC', 'init'),
    'sshd': ('AUTONOMIC', 'SSH server'),
}

SKIP = {'grep','awk','sort','uniq','ps','head','sed','bash','sh','cat',
        'python3','timeout','sleep','sudo','sshd:','(sd-pam)','wc','cut',
        'tee','systemd-journald','systemd-resolved','systemd-networkd',
        'systemd-timesyncd','systemd-udevd','systemd-logind',
        'agetty','dbus-daemon','unattended-upgrade-shutdown'}

procs = {}
for line in run('ps aux --no-headers').split('\n'):
    parts = line.split()
    if len(parts) < 11:
        continue
    cmd = ' '.join(parts[10:])
    if cmd.startswith('[') or not cmd.strip():
        continue
    name = os.path.basename(parts[10].split('/')[-1])
    if name in SKIP:
        continue
    if name not in procs:
        procs[name] = {'count': 0, 'rss_kb': 0}
    procs[name]['count'] += 1
    try:
        procs[name]['rss_kb'] += int(parts[5])
    except:
        pass

type_counts = {}
organism_count = 0
for name, info in procs.items():
    role_type = 'UNKNOWN'
    for key, (rt, _) in ROLES.items():
        if key in name:
            role_type = rt
            break
    type_counts[role_type] = type_counts.get(role_type, 0) + 1
    organism_count += 1

f2b = run('fail2ban-client status sshd 2>/dev/null')
banned = 0
total_banned = 0
for line in f2b.split('\n'):
    if 'Currently banned' in line:
        try: banned = int(line.split(':')[1].strip())
        except: pass
    if 'Total banned' in line:
        try: total_banned = int(line.split(':')[1].strip())
        except: pass

census = {
    'host': subprocess.run(['hostname'], capture_output=True, text=True).stdout.strip(),
    'timestamp': now,
    'organism_count': organism_count,
    'type_counts': type_counts,
    'immune': {
        'fail2ban_banned': banned,
        'fail2ban_total_banned': total_banned,
    },
}

with open('/opt/membrane/commensals.json', 'w') as f:
    json.dump(census, f, indent=2)
CENSUS
