# fossilRecord — ecoPrimals Stratigraphic Archive

**Repository**: `ecoPrimals/fossilRecord`
**License**: AGPL-3.0-or-later
**Purpose**: Canonical archive of superseded evolution documents across the entire ecoPrimals ecosystem

---

## What This Is

The fossilRecord is the geological record of ecoPrimals development. Every
primal, spring, and infrastructure component produces handoff documents as it
evolves. When a newer version absorbs the patterns from an older version, the
older handoff is fossilized here.

This repository consolidates what was previously scattered across 10+ local
`fossilRecord/` directories into a single, searchable, provenance-tracked
archive.

## Structure

```
fossilRecord/
├── wateringHole/      # Ecosystem-wide coordination handoffs (largest collection)
├── infra/             # Infrastructure-level fossils (benchScale, plasmidBin, etc.)
├── springs/
│   ├── primalSpring/  # L2 gate — contract testing, gap tracking, scenarios
│   ├── ludoSpring/    # Game math, tick model, composition patterns
│   ├── healthSpring/  # PK/PD, symbiont models, clinical validation
│   ├── neuralSpring/  # ML, mutation accumulation, ESN models
│   ├── hotSpring/     # Physics validation, GPU sovereignty, shaders
│   ├── wetSpring/     # Spectral analysis, biodiversity, genomics
│   ├── groundSpring/  # Clonal interference, soil dynamics, LTEE
│   └── airSpring/     # Atmospheric, evapotranspiration, crop models
└── README.md
```

Each subdirectory preserves the original filenames from its source. The
filename encodes provenance:
- **Primal/spring name** (e.g., `BEARDOG`, `WETSPRING`)
- **Version at time of handoff** (e.g., `V090`, `V137`, `S201b`)
- **Evolution theme** (e.g., `DEEP_DEBT`, `ECOSYSTEM_ABSORPTION`)
- **Date** (e.g., `MAR24_2026`, `MAY11_2026`)

## Position in the Ecosystem

```
L1  Primals (sentinels)        ─── stadial-first, MethodGate 13/13
L2  primalSpring (stadial gate) ─── contract testing, gap ownership
L3  Springs (river delta)       ─── niche validation, LTEE reproductions
L4  Products (downstream)       ─── projectNUCLEUS, lithoSpore, foundation
L5  fossilRecord (geological)   ─── preserved evidence of all evolution
```

The fossilRecord sits beneath the active ecosystem as its **memory layer**.
It does not drive evolution — it records it. When a question arises about
*why* a pattern exists, *when* a decision was made, or *how* a component
reached its current state, the answer is here.

## Relationship to Active Systems

| System | Active Docs | Fossils |
|--------|------------|---------|
| wateringHole | Standards, guides, specs | Superseded handoffs, closed audits |
| primalSpring | PRIMAL_GAPS.md, scenarios, tests | Old gap snapshots, deprecated plans |
| Springs | Current experiments, LTEE control | Superseded versions, old absorption handoffs |
| Primals | CHANGELOG, DEBT, NEXT_STEPS | (Primals keep their own history in-repo) |

## Searching

```bash
# Find all evolution history for a specific primal
ls wateringHole/ | grep -i beardog

# Find all deep-debt resolutions
rg -l "deep.debt" --glob "*.md"

# Find everything from a specific date
ls wateringHole/ | grep MAY11_2026

# Find all LTEE-related fossils across all springs
rg -l "LTEE" springs/
```

## Policy

- **Do not delete** — these are permanent records
- **Do not edit** — they are historical snapshots
- **Do reference** — when understanding why a pattern exists, trace it here
- **Provenance first** — subdirectory indicates origin system

## Statistics

| Source | Documents | Period |
|--------|----------:|--------|
| wateringHole | ~3,231 | Feb 2026 – present |
| primalSpring | ~274 | Mar 2026 – present |
| ludoSpring | ~245 | Mar 2026 – present |
| infra | ~27 | Mar 2026 – present |
| healthSpring | ~21 | Apr 2026 – present |
| neuralSpring | ~14 | Apr 2026 – present |
| hotSpring | ~9 | Apr 2026 – present |
| groundSpring | ~4 | Mar 2026 – present |
| airSpring | ~4 | Mar 2026 – present |
| wetSpring | ~2 | Mar 2026 – present |
| **Total** | **~3,831** | **Feb 4, 2026 – present** |

---

*The fossil record is not debris. It is evidence.*
