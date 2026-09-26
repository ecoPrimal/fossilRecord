# Wave 158 — Detroit Evidence Library Convergence

**Date**: Sep 25–26, 2026
**Gate**: sporeGate
**Wave**: 158
**Scope**: detroit.primals.eco expansion + SEO activation + evidence braiding + northGate integration

---

## Session Summary

Two-day sprint: expanded detroit from 121→128 pages, completed full SEO activation, built evidence braiding pipeline, and spec'd northGate OSINT integration.

## Deliverables

### Content (7 new pages)

1. `/analysis/credential-audit/` — MOECS staff qualification audit
2. `/analysis/funding-flow/` — Purpose Group fee structure analysis
3. `/analysis/words-vs-numbers/` — MDE praise vs performance data
4. `/analysis/land-deal/` — PCA building purchase option analysis
5. `/analysis/detroit-literacy/` — systemic charter oversight failure
6. `/books/it-had-2-happen/` — Banks autobiography critique
7. `/books/black-mafia-family/` — Welch BMF narrative analysis

### Graph Data

- 3 new entities: Escuela Avancemos, Chandler Park Academy, DPSCD
- 5 new edges with epistemic status tracking

### SEO Activation (complete)

- Google Indexing API: SA promoted to Owner, 120/120 URLs notified
- Bing Webmaster Tools: verified via XML file
- Priority-tiered URL notification: 4-tier system (Critical/High/Medium/Low)
- Meta descriptions, JSON-LD, OG tags, twitter:image, keywords — all fixed
- IndexNow submitting to Bing/DuckDuckGo/Yandex on every push

### Evidence Pipeline

- 27 files (60.8 MB) in depot, BLAKE3-hashed
- 2 braided collections: mde-foia-sep25 + credential-audit-sep26
- evidence-manifest.toml + braids.json tracking all files
- Local BLAKE3 via b3sum (provenance trio workaround)

### Infrastructure Docs

- `wateringHole/specs/OSINT_DATA_PIPELINE_SPEC.md` — full pipeline spec
- `wateringHole/handoffs/NORTHGATE_OSINT_MESH_INTEGRATION_BLURB.md` — team handoff
- `wateringHole/handoffs/SPOREGATE_WAVE158_STATUS_RESPONSE.md` — overwatch response

### Code Changes

- `cellMembrane/crates/membrane-shadow/src/seo/mod.rs` — UrlTier enum, tiered notification
- `cellMembrane/crates/membrane-shadow/src/seo/gsc.rs` — early-stop on 429
- `detroit/site/templates/` — 7 template files (SEO tags, JSON-LD fixes)
- `detroit/site/content/` — 7 new pages, 19 pages edited
- `detroit/site/static/` — BingSiteAuth.xml, security.txt
- `detroit/data/edges.toml` — 5 new edges
- `detroit/site/config.toml` — 3 new entities

## Convergence

Detroit evidence pipeline is a specific instance of the general primal data ingestion pattern (Acquire → Hash → Store → Braid → Publish). Same architecture as westGate AlphaFold and strandGate QCD, with a public evidence library as the output layer.

## Open Items

- cellMembrane UDS→TCP fallback for Windows health probes (P2)
- sweetGrass auto-announce in depot binary (P2)
- northGate full mesh enrollment (pending nucleus-deploy Windows fix + WG enrollment)
- northgate.toml hardware discrepancy needs team confirmation

---

*Wave 158. sporeGate ONLINE. detroit 128 pages, 2 braids, SEO complete. northGate OSINT pipeline spec'd. Convergence proven: legal primal = science primal + evidence library.*
