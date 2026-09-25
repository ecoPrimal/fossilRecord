# Wave 157: Full Standardization Pass — Publish Pipeline + Caddy Deploy + SEO Surface

> **Fossil record (Wave 157).** Operational snapshot of the static site standardization
> pass. Captured Sep 25, 2026. Deployed to sporeGate + golgiBody.

**Date**: Sep 25, 2026
**Commit**: `84f04b1` (cellMembrane), `67c55d1` (detroit)
**Binary**: `membrane 0.1.0 (5b2a8a4)`, `detroit-build 0.1.0`
**Scope**: Webhook publish pipeline, Caddy vhost management, SEO notification

---

## What Changed

### Publish Pipeline (6-step automated)

The webhook pipeline was extended from 4 steps to 6:

```
Step 0:   Caddy vhost check     — warns if host not provisioned
Step 1:   Git fetch + reset     — worktree on golgiBody
Step 2:   Zola build            — HTML from content/
Step 2.5: Artifact generation   — detroit-build (graph, site-api, llms, manifest)
Step 3:   Evidence push + braid — SCP + provenance trio
Step 4:   SEO notify            — IndexNow + GSC + Google URL Notify
Step 5:   Verify consistency    — sitemap vs site.json cross-check
```

### New Commands

| Command | Function |
|---------|----------|
| `caddy.deploy <site\|--all> [--dry-run]` | Generate + SSH deploy Caddy vhost block |
| `seo.url_notify` | Google Indexing API `urlNotifications:publish` |

### New Modules

| File | Lines | Purpose |
|------|-------|---------|
| `webhook/publish_artifacts.rs` | 75 | Invoke site-specific build tools as subprocess |
| `webhook/verify_consistency.rs` | 130 | Post-build sitemap vs site.json cross-check |
| `evidence/provenance.rs` | ~400 | UDS JSON-RPC braid pipeline (trio integration) |
| `caddy/mod.rs` (additions) | ~200 | `generate_static_site_block()` + `caddy.deploy` dispatch |
| `seo/gsc.rs` (additions) | ~50 | `url_notify()` via Google Indexing API |

### PublishSite Registry Extension

Added `artifact_command: Option<&[&str]>` field to `PublishSite`:
```rust
PublishSite {
    // ...existing fields...
    artifact_command: Some(&["detroit-build", "--root", "."]),
}
```

### Deployment Targets

| Host | Binary | Path | Protection |
|------|--------|------|------------|
| sporeGate | membrane | `/usr/local/bin/membrane` | standard |
| sporeGate | detroit-build | `/usr/local/bin/detroit-build` | standard |
| golgiBody | membrane | `/usr/local/bin/membrane` | `chattr +i` |
| golgiBody | detroit-build | `/usr/local/bin/detroit-build` | standard |

### Verified Endpoints (Sep 25, 2026)

detroit.primals.eco: 120 sitemap URLs, 32 content pages, 43 graph nodes,
57 edges, 5/5 security headers, all endpoints 200.

---

## Bugs Found & Fixed During Wave

1. **Stale membrane binaries**: 3 copies in `~/.local/bin`, `~/bin`, `~/.cargo/bin`
   shadowed `/usr/local/bin/membrane`. Cleaned up.
2. **detroit-build missing on golgiBody**: artifact_command runs in worktree
   (golgiBody), but binary was only on sporeGate. Deployed to both.
3. **Caddy /evidence/ file browser**: `handle /evidence/*` intercepted bare
   `/evidence/` path. Fixed by adding explicit `handle /evidence/` block first.

---

*Fossil — Wave 157 standardization. 6-step pipeline proven. 3 tracks complete.*
