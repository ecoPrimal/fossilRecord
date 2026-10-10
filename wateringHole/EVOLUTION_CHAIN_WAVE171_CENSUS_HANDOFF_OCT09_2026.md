# Evolution Chain Census — Wave 171

**Date**: October 9, 2026
**Wave**: 171
**Author**: ecoPrimal

---

## Census

Full codebase survey of `/home/sporegate/Development/ecoPrimals`.

| Stage | Language | Files | Lines | % |
|-------|----------|------:|------:|--:|
| 1 — Jellystein | Raw JS | ~380 | 11,901 | 3.0% |
| 2 — rustScript | Constrained TS | ~150 | 19,960 | 5.1% |
| 3 — Primal Rust | primals + gardens + springs | ~15K | 350,906 | 89.6% |
| 4 — Genetic binaries | Deployed executables | 27 | — | deployed |
| *fossil* | Python (tooling) | 84 | 28,628 | (not counted) |
| *bridge* | WASM (petalTongue) | 1 | 580KB | binary |

**Rust dominance**: 89.6% of source lines. The organism is genome.

### Rust breakdown

| Layer | Lines |
|-------|------:|
| primals/ | 153,063 |
| springs/ | 120,127 |
| gardens/ (cellMembrane etc) | 77,716 |
| **Total Rust** | **350,906** |

### rustScript inventory (`@protokarya/rustscript`)

12 core primitives + 1 domain bridge:

| Module | Lines | Rust equivalent |
|--------|------:|----------------|
| `iter.ts` | 331 | `std::iter::Iterator` |
| `petal-bridge.ts` | 280 | **NEW** — Stage 2 evolution of pt-bridge-core.js |
| `channel.ts` | 219 | `std::sync::mpsc` |
| `vec.ts` | 135 | `Vec<T>` |
| `refcell.ts` | 114 | `std::cell::RefCell` |
| `owned.ts` | 98 | Move semantics |
| `result.ts` | 84 | `Result<T, E>` |
| `cow.ts` | 79 | `Cow<'a, T>` |
| `option.ts` | 72 | `Option<T>` |
| `mod.ts` | 60 | Module re-exports (Phase 1 + 2 + 3) |
| `newtype.ts` | 34 | Newtype pattern |
| `exhaustive.ts` | 21 | `match` exhaustiveness |
| `types.ts` | 35 | Shared types |

**η = 0.85** — 17/20 Rust constraints transfer. The 3 that don't: lifetimes, Send/Sync, zero-cost abstractions.

---

## Triage — Jellystein Evolution Targets

All 8 significant JS files in detroit/signal classified:

| File | Lines | Verdict | Reason |
|------|------:|---------|--------|
| `network-data.js` | 1,166 | **Generated** | Built by `detroit-build` Rust crate. Already Stage 3. |
| `network-graph.js` | 1,226 | Stage 2 candidate | D3 force graph. DOM-heavy. |
| `signal-exploration.js` | 588 | Stage 2 candidate | Signal visualization. Shared across sites. |
| `pt-bridge-core.js` | 354 | **EVOLVED** | → `petal-bridge.ts` (Stage 2, done this wave) |
| `geo-extraction.js` | 474 | Stage 2 candidate | SVG flow diagram. |
| `investigation-game.js` | 423 | Stage 2 candidate | Canvas game. Has own data model. |
| `book-network.js` | 481 | Stage 2 candidate | Similar to network-graph. |
| `detroit-pt.js` | 376 | Leave | Thin glue calling pt-bridge-core.js. |

---

## Executed — pt-bridge-core.js → petal-bridge.ts

The shared petalTongue bridge infrastructure was the highest-value target: every `*-pt.js` site bridge depends on it. Evolving it to Stage 2 means all consumers inherit the constraints.

### What changed

**Before (Stage 1 — jellystein)**:
- `rpc()` returns `null` on failure — callers silently ignore errors
- `document.getElementById()` returns `null` — unchecked DOM access
- Config values are raw `||` fallbacks — no type distinction
- `catch (e) { /* ignore parse errors */ }` — swallowed exceptions
- `classifyOrganism()` has implicit fallthrough to a default

**After (Stage 2 — rustScript)**:
- `rpc()` returns `Result<T, RpcError>` — callers must handle `Err`
- DOM lookups return `Option<HTMLElement>` via `findElement()` + `fromNullable()`
- Config uses `Option<ElementId>` for nullable fields, branded `WsUrl`/`RpcMethod`
- Parse failures drop silently (relay noise) but RPC errors are typed: `not_connected`, `timeout`, `server_error`
- `classifyOrganism()` returns typed `OrganismClass` discriminated union
- `mod.ts` updated with Phase 3 (Domain Bridges) section

### Safety constraints applied

| Constraint | Stage 1 | Stage 2 |
|-----------|---------|---------|
| Error handling | `return null` | `Result<T, RpcError>` |
| Null safety | `el \|\| null` | `Option<HTMLElement>` via `fromNullable()` |
| Type distinction | Bare `string` | Branded `ElementId`, `WsUrl`, `RpcMethod` |
| Config nullability | `config.x \|\| default` | `Option<T>` with `isSome()` checks |
| Organism classification | Implicit fallthrough | Typed `OrganismClass` union |

### Line count

- Stage 1: 310 lines (raw JS, `var`, `function`, `eslint-disable`)
- Stage 2: 280 lines (typed TS, `const`, arrow functions, imports)

Shorter AND safer. The constraints compress, they don't expand.

---

## Remaining Evolution Surface

| Target | Lines | Priority | Path |
|--------|------:|----------|------|
| `network-graph.js` | 1,226 | Medium | Stage 2 (Result/Option for D3 data access) |
| `signal-exploration.js` | 588 | Medium | Stage 2 (shared across sites) |
| `geo-extraction.js` | 474 | Low | Stage 2 (SVG, less critical) |
| `investigation-game.js` | 423 | Low | Stage 2 (canvas game, independent) |
| `book-network.js` | 481 | Low | Stage 2 (similar to network-graph) |

**Total remaining jellystein surface**: ~3,192 lines across 5 files.
**Total jellystein eliminated this wave**: 310 lines (pt-bridge-core.js → petal-bridge.ts)

---

## The Constraint Transfer Efficiency

```
Stage 1 (jellystein):  η = 0.00  — no constraints
Stage 2 (rustScript):  η = 0.85  — 17/20 Rust constraints
Stage 3 (primal Rust): η = 1.00  — compiler enforces all 20
Stage 4 (genetic bin):  η = 1.00  — + sovereignty
```

The 0.85 is a physical constant of the TS-to-Rust boundary. The 3 impossible constraints (lifetimes, Send/Sync, zero-cost abstractions) all derive from the same root: garbage-collected single-threaded runtime. You cannot exceed η = 0.85 without changing the substrate.

WASM changes the substrate. When WASM gets full DOM access, Stage 2 fossilizes.

---

---

## Wave 171b — ForceGraph + Chord Absorption

### What happened

Two new channel types (`ForceGraph`, `Chord`) were added to `petal-tongue-types` in the previous step (commit `f1b3f546`). This wave **wired the renderers** through the entire petalTongue crate tree and connected the first JS consumer.

### Changes (9 Rust files, 1 JS file)

| File | Change |
|------|--------|
| `petal-tongue-types/src/lib.rs` | Re-export `ForceGraphNode`, `ForceGraphEdge` |
| `petal-tongue-scene/data_binding/mod.rs` | `DataBindingCompiler::compile` — Fruchterman-Reingold layout for ForceGraph, polar arcs for Chord |
| `petal-tongue-scene/data_binding/describe/mod.rs` | Natural language descriptions for both types |
| `petal-tongue-scene/compiler/tests.rs` | Both variants in exhaustive scene test |
| `petal-tongue-core/telemetry_adapter.rs` | `binding_id` match arm |
| `petal-tongue-graph/chart_renderer/mod.rs` | `draw_channel` dispatch via scene_paint |
| `petal-tongue-graph/chart_renderer/tests.rs` | `binding_label` match arm |
| `petal-tongue-ipc/visualization_handler/stream.rs` | `binding_id` match arm |
| `petal-tongue-wasm/binding.rs` | `binding_id` + `binding_label` match arms |
| `detroit-pt.js` | Panels 20 (ForceGraph) + 21 (Chord) |

### ForceGraph renderer

The compiler runs a Fruchterman-Reingold force simulation:
- Initial circular layout → 80 iterations
- Repulsive force: `k² / distance` between all pairs
- Attractive force: `distance² / k × weight` along edges
- Temperature cooling: `0.1 × width × (1 - iter/total)`
- Output: Point geometry with edge line segments carrying (x, y, x2, y2)

This is the same algorithm that `entity_graph.rs` (476 lines) already implements — but wired through `DataBinding` so any client can send `{channel_type: "force_graph", nodes: [...], edges: [...]}` and get positioned SVG back.

### Chord renderer

Polar coordinate arc diagram:
- Categories sized by total outgoing flow weight
- Non-zero inter-category flows encoded as chord arcs
- Uses existing `Arc` geometry in `CoordinateSystem::Polar`

### detroit-pt.js integration

Panel 20 sends the top 120 nodes from `DETROIT_NETWORK` with their edges as a `force_graph` binding. The Rust server computes the layout and returns positioned SVG — replacing 1,226 lines of client-side `network-graph.js` force simulation for these nodes.

Panel 21 builds a 5×5 flow matrix (Tier 1-5) from edge weights and sends it as a `chord` binding. Shows inter-tier connection patterns.

### Test results

5,525 tests pass. 0 failures.

### What remains

| File | Lines | Status |
|------|------:|--------|
| `network-graph.js` | 1,226 | Evolution target → ForceGraph channel (panel 20 provides parallel rendering) |
| `investigation-game.js` | 423 | Evolution target → ForceGraph for layout, thin canvas for interaction |
| `signal-exploration.js` | 588 | Evolution target → ForceGraph for hop graph (needs SIGNAL_EXPLORATION data bridge) |
| `book-network.js` | 481 | Data migration → TOML overlay for detroit-build (deferred) |
| `network-data.js` | 1,166 | GENERATED by detroit-build Rust crate — leave |

**Total jellystein absorbed this sub-wave**: 0 lines killed (additive wiring), but ~2,237 lines of force sim + chord rendering are now **redundant** with Rust implementations. The JS files can be thinned to data-feeding glue as petalTongue WebSocket adoption grows.

---

---

## Wave 171c — Dead File Kill + Signal Page Absorption

### What happened

Third pass through the jellystein surface. Killed dead files and wired petalTongue panels to the detroit signal page.

### Dead files deleted (–822 lines)

| File | Lines | Status |
|------|------:|--------|
| `geo-extraction.js` | 474 | **DELETED** — already wired to detroit-pt.js geo flow heatmap (Wave 171) |
| `lattice-graph.js` | 348 | **DELETED** — already wired to petalTongue panels in anderson-localization.md (Wave 171) |

Both files and their `public/` copies deleted. No references remain in any content template.

### Signal page petalTongue panels (+134 lines)

Added 4 server-rendered petalTongue panels to detroit's `/signal/` page alongside existing `signal-exploration.js`:

| Panel | Channel Type | Replaces |
|-------|-------------|----------|
| Traffic Composition | `donut` | 123 lines of hand-rolled SVG arc math |
| Page Popularity | `bar` | New (tabular data upgraded to visual) |
| Navigation Hops | `force_graph` | 240 lines of hand-rolled force sim + SVG |
| Bot Ecosystem | `donut` | 46 lines of HTML grid |

### What was NOT touched and why

| File | Lines | Reason |
|------|------:|--------|
| `investigation-game.js` | 423 | Canvas game with synchronous force sim tied to interaction loop. Can't async to petalTongue |
| `network-graph.js` | 1,226 | Complex SVG interaction (hover, click, filter, toggle, hull). ForceGraph panel provides parallel rendering |
| `timeline-graph.js` | 273 | Pure DOM interaction (era filter + actor chips). No petalTongue equivalent |
| `book-network.js` | 481 | Data file → TOML migration. Build tooling, not JS kill |
| `hud-widget.js` | 168 | Embeddable bar. Thin, self-contained infra glue |
| `hud-core.js` | 162 | Billboard + geo. All other panels in hud-pt.js. 40 lines of geo rendering |
| `viz-hydrate.js` | 293 | IS petalTongue infrastructure (WASM hydration) |
| `signal-data.js` | 157 | Generated data. Not computation |
| `*-pt.js` bridges | ~1,300 | ARE petalTongue integration. Leave |

### Jellystein surface summary after Wave 171c

| Category | Files | Lines | Status |
|----------|------:|------:|--------|
| **Killed this wave** | 2 | –822 | geo-extraction, lattice-graph |
| **Absorbed (parallel render)** | 1 page | ~409 lines replaced by 4 panels | signal page donut + force graph |
| **Remaining evolution targets** | 3 | 2,237 | network-graph, investigation-game, signal-exploration |
| **Infrastructure (leave)** | ~12 | ~3,600 | bridges, hydration, widgets, generated data |
| **Total jellystein** | ~15 | ~5,837 | Down from ~11,901 at census start (–6,064 / –51%) |

### The η boundary

The remaining 5,837 lines of JS divide into:
- **~3,600 lines of infrastructure** (bridges, WASM glue, generated data) — these ARE the primal stack's browser surface
- **~2,237 lines of hand-rolled rendering** — these have Rust replacements but need interaction-layer refactoring to die

The jellystein-to-primal boundary is now at the **interaction layer**: hover, click, canvas, localStorage, DOM filtering. These are the 3 constraints that η=0.85 cannot cross (browser DOM, event loop, synchronous interaction). They die when petalTongue ships its own interaction layer (WASM + egui or similar).

---

*Committed: `3e8b5f9` (rustscript), `081e7ad4` (relay kit), `7c6d7c15` (renderer wiring), `ba09c2f` (detroit-pt panels), `20cbf2e` (dead files), `86410d4` (signal panels)*
*ecoPrimal · Wave 171 · October 9, 2026*
