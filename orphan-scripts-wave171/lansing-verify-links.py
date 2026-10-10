#!/usr/bin/env python3
"""Cross-site link verification via content manifests.

Extracts all primals.eco URLs from markdown content, resolves each
to the target site's content-manifest.toml, verifies the page exists,
and emits link-braids.json (PROV-O derivation chains for verified links).

Dead links are reported to stderr.

Usage:
    python3 verify-links.py [site_dir]
    python3 verify-links.py  # defaults to all sites

The manifests are read locally (not fetched over HTTP) so all repos
must be checked out under the ecoPrimals directory tree.
"""

import json, os, re, sys, subprocess
from datetime import datetime, timezone
from collections import defaultdict

BASE = "/home/sporegate/Development/ecoPrimals/infra"

# Site topology — URL domain → local content dir + manifest path
SITES = {
    "detroit.primals.eco": {
        "content": f"{BASE}/detroit/site/content",
        "manifest": f"{BASE}/detroit/content-manifest.toml",
    },
    "barry.primals.eco": {
        "content": f"{BASE}/tuebor/site/content",
        "manifest": f"{BASE}/tuebor/content-manifest.toml",
    },
    "tuebor.primals.eco": {
        "content": f"{BASE}/tuebor/site/content",
        "manifest": f"{BASE}/tuebor/content-manifest.toml",
    },
    "lansing.primals.eco": {
        "content": f"{BASE}/lansing/site/content",
        "manifest": f"{BASE}/lansing/content-manifest.toml",
    },
    "signal.primals.eco": {
        "content": f"{BASE}/signal/site/content",
        "manifest": f"{BASE}/signal/content-manifest.toml",
    },
    "sporeprint.primals.eco": {
        "content": f"{BASE}/sporePrint/content",
        "manifest": f"{BASE}/sporePrint/content-manifest.toml",
    },
    "thesis.primals.eco": {
        "content": f"{BASE}/thesis/content" if os.path.exists(f"{BASE}/thesis") else None,
        "manifest": None,
    },
}


def load_manifest(path):
    """Parse a content-manifest.toml into {content_path: blake3_hash}."""
    if not path or not os.path.exists(path):
        return {}
    manifest = {}
    current_key = None
    with open(path) as f:
        for line in f:
            m = re.match(r'\[pages\."([^"]+)"\]', line)
            if m:
                current_key = m.group(1)
            elif current_key and line.startswith("blake3"):
                manifest[current_key] = line.split("=")[1].strip().strip('"')
    return manifest


def url_to_content_path(url_path, content_dir):
    """Convert a URL path like /analysis/leak-in-the-dyke/ to a content file path."""
    path = url_path.strip("/")
    if not path:
        return "content/_index.md"

    candidates = [
        os.path.join(content_dir, f"{path}.md"),
        os.path.join(content_dir, path, "_index.md"),
        os.path.join(content_dir, f"{path.replace('-', '_')}.md"),
    ]
    for c in candidates:
        if os.path.exists(c):
            return os.path.relpath(c, os.path.dirname(content_dir))

    # Check if it's a taxonomy page (actors/tom-barrett → actors taxonomy term)
    parts = path.split("/")
    if len(parts) == 2:
        section_index = os.path.join(content_dir, parts[0], "_index.md")
        page = os.path.join(content_dir, parts[0], f"{parts[1]}.md")
        if os.path.exists(page):
            return os.path.relpath(page, os.path.dirname(content_dir))

    return None


def extract_links(content_dir):
    """Extract all primals.eco URLs from markdown files in content_dir."""
    links = []
    url_pattern = re.compile(r'https?://(\w+\.primals\.eco)(/[^\s\)"\]]*)?')

    for root, dirs, files in os.walk(content_dir):
        for f in files:
            if not f.endswith(".md"):
                continue
            fpath = os.path.join(root, f)
            relpath = os.path.relpath(fpath, os.path.dirname(content_dir))
            with open(fpath) as fp:
                for i, line in enumerate(fp, 1):
                    for match in url_pattern.finditer(line):
                        domain = match.group(1)
                        path = match.group(2) or "/"
                        # Skip self-links and root-only links
                        links.append({
                            "source_file": relpath,
                            "source_line": i,
                            "target_domain": domain,
                            "target_path": path,
                            "target_url": f"https://{domain}{path}",
                        })
    return links


def verify_links(site_dirs=None):
    """Verify all cross-site links and emit braids for verified ones."""
    if site_dirs is None:
        site_dirs = [
            f"{BASE}/lansing/site",
            f"{BASE}/tuebor/site",
            f"{BASE}/detroit/site",
        ]

    # Load all manifests
    manifests = {}
    for domain, info in SITES.items():
        if info["manifest"]:
            manifests[domain] = load_manifest(info["manifest"])

    results = {"working": [], "dead": [], "no_manifest": []}
    braids = []
    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    for site_dir in site_dirs:
        content_dir = os.path.join(site_dir, "content")
        site_name = os.path.basename(os.path.dirname(site_dir))

        links = extract_links(content_dir)

        for link in links:
            domain = link["target_domain"]
            path = link["target_path"]

            # Skip root-only links (homepage)
            if path == "/" or path == "":
                results["working"].append(link)
                continue

            site_info = SITES.get(domain)
            if not site_info or not site_info["content"]:
                results["no_manifest"].append(link)
                continue

            # Try to resolve the URL path to a content file
            content_path = url_to_content_path(path, site_info["content"])

            if content_path:
                # Working link — look up hash from manifest
                manifest = manifests.get(domain, {})
                h = manifest.get(content_path, "")

                link["resolved_path"] = content_path
                link["blake3"] = h
                results["working"].append(link)

                # Emit a braid for this verified cross-site derivation
                if h:
                    braid = {
                        "data_hash": f"blake3:link:{h[:32]}",
                        "mime_type": "text/markdown",
                        "braided_at": now,
                        "was_generated_by": {
                            "agent": f"did:web:{site_name}.primals.eco",
                            "plan": "cross-site link verification",
                            "software": "verify-links/0.1.0",
                        },
                        "was_derived_from": [{
                            "id": f"urn:content:{domain.split('.')[0]}:{os.path.basename(content_path).replace('.md','')}",
                            "hash": h,
                        }],
                        "was_attributed_to": f"did:web:{site_name}.primals.eco",
                        "metadata": {
                            "title": f"{link['source_file']} → {link['target_url']}",
                            "tags": ["cross-site", "verified", site_name],
                            "custom": {
                                "source_file": link["source_file"],
                                "source_line": link["source_line"],
                                "target_url": link["target_url"],
                                "target_hash": h,
                            }
                        }
                    }
                    braids.append(braid)
            else:
                link["resolved_path"] = None
                results["dead"].append(link)

    return results, braids


if __name__ == "__main__":
    if len(sys.argv) > 1:
        site_dirs = [sys.argv[1]]
    else:
        site_dirs = None

    results, braids = verify_links(site_dirs)

    # Report
    print(f"\n{'='*60}")
    print(f"CROSS-SITE LINK VERIFICATION REPORT")
    print(f"{'='*60}")
    print(f"Working links: {len(results['working'])}")
    print(f"Dead links:    {len(results['dead'])}")
    print(f"No manifest:   {len(results['no_manifest'])}")
    print(f"Braids emitted: {len(braids)}")

    if results["dead"]:
        print(f"\n{'='*60}")
        print("DEAD LINKS:")
        print(f"{'='*60}")
        for link in results["dead"]:
            print(f"  {link['source_file']}:{link['source_line']}")
            print(f"    → {link['target_url']}")
            print()

    if results["no_manifest"]:
        domains = set(l["target_domain"] for l in results["no_manifest"])
        print(f"\nSites without manifests: {', '.join(sorted(domains))}")

    # Write link-braids.json
    out_dir = sys.argv[1] if len(sys.argv) > 1 else f"{BASE}/lansing"
    out_path = os.path.join(out_dir, "link-braids.json")
    with open(out_path, "w") as f:
        json.dump(braids, f, indent=2)
    print(f"\nWrote {out_path}: {len(braids)} verified link braids")
