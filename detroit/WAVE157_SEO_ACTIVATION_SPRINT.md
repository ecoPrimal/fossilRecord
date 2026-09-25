# Wave 157 — SEO Activation Sprint (detroit.primals.eco)

**Date:** 2026-09-25
**Scope:** detroit.primals.eco — full on-page SEO remediation + backlink cultivation + Indexing API unlock
**Trigger:** 120 subpages stuck in "Discovered - currently not indexed" state; homepage indexed Sep 23

## Starting State

- Homepage: indexed by Google (verdict PASS, last crawl Sep 23)
- 120 subpages: "Discovered - currently not indexed" (Google knows they exist but hasn't crawled)
- 41 impressions, 2 clicks in 7 days
- IndexNow: working (Bing/DuckDuckGo/Yandex)
- Google Indexing API: blocked (API disabled on GCP, SA was siteFullUser not siteOwner)
- Meta descriptions: 9 pages truncated/broken (sentences ending with `,."` or `— .`)
- Keywords meta: 10 pages over-stuffed (up to 2093 chars)
- Taxonomy templates: missing OG/Twitter title/description blocks (47 pages affected)
- JSON-LD: URL encoding bug (`&#x2F;` instead of `/`)

## Changes Made

### Phase 1 — On-Page SEO Fixes (15 template + content changes)

| Fix | Files | Impact |
|-----|-------|--------|
| 9 truncated meta descriptions rewritten | 9 content `.md` files | SERP snippets now complete sentences |
| Joseph Holland broken quote in description | `joseph-holland.md` | Was `'WITHOUT IMPROVEMENT.` — now clean |
| JSON-LD `page.permalink \| safe` filter | `page.html` (3 blocks) | URLs render as `https://` not `&#x2F;` |
| Taxonomy OG/Twitter blocks | 4 `single.html` templates | 47 taxonomy pages now have unique OG tags |
| "Entitie" typo → "Entity" | `entities/single.html` | Title tag was malformed |
| `og:image:width/height/alt` | `base.html` | Social card rendering improvement |
| `twitter:image` meta tag | `base.html` | Was missing entirely |
| Homepage title/desc from `_index.md` | `index.html` | Punchy copy ("9 convictions. 9 judges.") now in meta |
| Keyword stuffing trimmed (10 pages) | 10 content `.md` files | 2000→280 chars avg, 7-11 terms each |

### Phase 2 — Backlinks (9 cross-repo edits)

| Link | Repo | Type |
|------|------|------|
| shields.io badges (Live Site, Forgejo, License) | detroit README | Badge backlink |
| Machine-Readable Endpoints → full URLs | detroit README | Table link |
| `homepage` + `repository` in Cargo.toml | detroit-build | crates.io metadata |
| sporePrint hero `detroit.primals.eco` → `<a>` | sporePrint templates | Cross-domain backlink |
| sporePrint README: detroit sibling mention | sporePrint README | Cross-domain backlink |
| `entity_registry.detroit.url` field | sporePrint config.toml | Structured data |
| subGen README: 2 markdown links | whitePaper | Ecosystem backlink |
| wateringHole specs + handoffs: markdown links | wateringHole | Ecosystem backlink |
| `WRONGED_PARTIES.md` closing link | detroit wronged | Document backlink |

### Phase 2 — Discovery Files (2 new)

| File | Purpose |
|------|---------|
| `.well-known/security.txt` | Crawler discovery, security policy |
| `<link rel="describedby" ... identity.json>` | Schema.org structured data link |

### Phase 3 — Indexing API Unlock (3 changes)

| Change | How |
|--------|-----|
| Indexing API enabled on GCP project `ecoprimals-seo` | Python `serviceusage.googleapis.com` API call |
| SA promoted to GSC Owner | User action in GSC UI |
| `gsc.rs url_notify` — `tracing::warn` for failures | Code change + deploy |

## Ending State

- All meta descriptions: complete, 140-160 chars, no truncation
- All taxonomy pages: unique OG + Twitter tags
- JSON-LD: clean URLs throughout
- Keywords: 7-11 high-value terms per page (no stuffing)
- Social cards: `og:image` + dimensions + `twitter:image` complete
- Homepage: punchy description in meta tags
- `.well-known/security.txt`: live at `/.well-known/security.txt`
- `identity.json`: linked from HTML `<head>`
- Backlinks: 9 cross-repo links cultivated
- Indexing API: **ENABLED** + SA is **Owner** + logging fixed
- Quota: exhausted for today (429), resets tomorrow → then `membrane seo.url_notify detroit` will push all 120 URLs
- IndexNow: 120 URLs submitted (HTTP 200) on push
- Sitemaps: resubmitted via GSC API

## Commits

| Repo | Hash | Message |
|------|------|---------|
| detroit | `8bb1366` | seo: Phase 1-2 on-page fixes + backlinks + discovery files |
| cellMembrane | `7220855` | seo: add tracing::warn for Indexing API failures in url_notify |
| sporePrint | `b067a1d3` | seo: detroit backlinks — hero link, README, entity_registry URL |
| whitePaper | `89b8e0c` | seo: convert detroit.primals.eco plain text to markdown links in subGen |
| wateringHole | `95cee5930` | seo: convert detroit.primals.eco plain text to markdown links |

## Tomorrow's Action

Run `membrane seo.url_notify detroit` after quota resets (~midnight Pacific).
Expected: `120/120 URLs notified` via Google Indexing API.
Then monitor GSC for crawl/index status changes over 24-72 hours.

## Search Index Coverage

| Engine | Mechanism | Status |
|--------|-----------|--------|
| Google | GSC Indexing API + sitemap | ✅ API enabled, quota resets tomorrow |
| Bing | IndexNow | ✅ 120 URLs submitted (HTTP 200) |
| DuckDuckGo | Bing index (shared) | ✅ Covered by IndexNow |
| Yandex | IndexNow | ✅ Covered by IndexNow |
| AI agents | `llms.txt` + `identity.json` + Schema.org | ✅ Discovery surface live |
