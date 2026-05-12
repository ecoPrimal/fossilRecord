# ecoPrimals Phase 2: Memory & Attribution Layer

**Status:** BiomeOS & petalTongue Production-Ready ✅ | RhizoCrypt Core Complete ✅  
**Date:** December 2025  
**Last Updated:** December 23, 2025 (Extended Session)

---

## Overview

Phase 2 introduces the **Memory & Attribution Layer**—not three separate primals, but **one DAG engine with three semantic faces**.

### Current Status

| Component | Status | Grade | Notes |
|-----------|--------|-------|-------|
| **BiomeOS** | ✅ Production-Ready | A | Orchestration layer complete with 141+ tests |
| **petalTongue** | ✅ Production-Ready | A+ | Universal UI system with 26 tests + 8 fermentation scenarios |
| **RhizoCrypt** | 🔄 Core Complete | B+ | Core DAG engine operational with 21 tests (60% done) |
| **LoamSpine** | 📋 Specified | - | Permanence layer architecture defined |
| **SweetGrass** | 📋 Specified | - | Attribution layer architecture defined |

**🎉 December 23, 2025 Extended Session Achievements:**
- ✅ **BiomeOS** production-ready (141+ tests, Grade A)
- ✅ **petalTongue** production-ready (26 tests, 8 fermentation scenarios, Grade A+)
- ✅ **RhizoCrypt Core** operational (21 tests, content-addressed DAG working, Grade B+)

**Session Total:** ~11,500 lines in ~9 hours | **Tests:** 188 passing

See `biomeOS/MISSION_ACCOMPLISHED.md`, `petalTongue/STATUS.md`, and `rhizoCrypt/STATUS.md` for full details.

| Face | Role | Git Analog |
|------|------|------------|
| 🔐 **RhizoCrypt** | Core DAG Engine | `.git/objects` + staging |
| 🦴 **LoamSpine** | Permanence Layer | `origin/main` + reflog |
| 🌾 **SweetGrass** | Attribution Layer | `git blame` + commit messages |

**The key insight:** RhizoCrypt is a git-esque engine. LoamSpine and SweetGrass are semantic layers on top of it.

---

## The Unified Architecture

### One Engine, Three Faces

```
┌─────────────────────────────────────────────────────────────────┐
│                    Phase 2: Unified Architecture                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌──────────────────────────────────────────────────────────┐  │
│   │                     RhizoCrypt                            │  │
│   │                  (Core DAG Engine)                        │  │
│   │                                                           │  │
│   │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────────┐  │  │
│   │  │ Vertex  │  │  DAG    │  │ Merkle  │  │  Sessions   │  │  │
│   │  │ Store   │  │ Index   │  │ Trees   │  │  (scopes)   │  │  │
│   │  └─────────┘  └─────────┘  └─────────┘  └─────────────┘  │  │
│   └──────────────────────────┬───────────────────────────────┘  │
│                              │                                   │
│              ┌───────────────┼───────────────┐                  │
│              │               │               │                  │
│              ▼               ▼               ▼                  │
│   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│   │  LoamSpine   │  │  SweetGrass  │  │   Exports    │         │
│   │ (permanence) │  │  (queries)   │  │  (PROV-O)    │         │
│   └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                  │
│   Internal Format: RhizoFormat (human+AI readable)              │
│   Export Format: JSON-LD/PROV-O (interoperability)              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Why This Matters

**Before (three separate systems):**
- RhizoCrypt stores DAGs
- LoamSpine stores chains
- SweetGrass stores Braids
- Complex integration between them

**After (one engine, three faces):**
- RhizoCrypt **is** the engine
- LoamSpine = permanence semantics on RhizoCrypt
- SweetGrass = query/attribution layer on RhizoCrypt
- Integration is internal, not external

---

## RhizoCrypt: The Git-esque Core

RhizoCrypt isn't just "session capture." It's a **general-purpose content-addressed DAG engine**:

| Git Concept | RhizoCrypt | Notes |
|-------------|------------|-------|
| Commit | Vertex | Content-addressed, signed |
| Tree | Payload | Content-addressed blobs |
| Branch | Frontier | DAG tips, multiple allowed |
| Merge | Multi-parent vertex | Native, not special case |
| Clone | Session fork | Built-in |
| Push | Dehydrate → LoamSpine | Selective permanence |
| Repo | Session | Scoped DAG |

**But better than git because:**
- **Ephemeral by default** (git keeps everything)
- **Real-time streaming** (git is batch commits)
- **Multi-agent native** (git is single-author)
- **Selective forgetting** (prune without losing integrity)

---

## RhizoFormat: Human + AI Readable

The original specs used JSON-LD/PROV-O. That was a **concept snapshot**, not a commitment.

For our development model (human architect + AI agents), we need:

| Requirement | JSON-LD | RhizoFormat |
|-------------|---------|-------------|
| Human readable | ✅ Verbose | ✅ Concise |
| AI parseable | ✅ Standard | ✅ Simple |
| Efficient storage | ❌ Bloated | ✅ Binary-packable |
| Streamable | ❌ Objects | ✅ Line-oriented |

**RhizoFormat example:**

```
# Vertex format - human/AI readable, binary-packable
v1:vertex
  id: blake3:a1b2c3d4e5f6g7h8...
  parents: [blake3:i9j0k1l2..., blake3:m3n4o5p6...]
  ts: 1703239200.123456789
  agent: did:key:z6Mk...
  type: data_create
  payload: blake3:q7r8s9t0...
  
  # Attribution metadata (SweetGrass)
  attr:
    role: creator
    compute: 1.5
    derived: [blake3:u1v2w3x4...]
  
  sig: ed25519:y5z6a7b8...
```

**Properties:**
- Line-oriented (streamable, diff-able)
- Key-value (parseable by any language/AI)
- Content-addressed references (integrity)
- Embedded attribution (SweetGrass inline)
- Binary-packable (CBOR for storage/wire)

**Export to PROV-O** when interoperability needed—not internal representation.

---

## Revised Architecture Layers

### Layer 1: RhizoCrypt Core (Foundation)

```rust
// The fundamental unit
struct Vertex {
    id: Blake3Hash,           // Content address
    parents: Vec<Blake3Hash>, // DAG links
    timestamp: Timestamp,
    agent: Did,
    event_type: EventType,
    payload: Blake3Hash,
    attribution: Attribution, // SweetGrass metadata inline
    signature: Signature,
}

// Sessions scope vertices
struct Session {
    id: SessionId,
    vertices: HashMap<Blake3Hash, Vertex>,
    frontier: HashSet<Blake3Hash>,
    config: SessionConfig,
}
```

### Layer 2: LoamSpine (Permanence Semantics)

LoamSpine isn't a separate store—it's **permanence rules** on RhizoCrypt:

```rust
// A "commit" is just a Merkle root + metadata
struct LoamCommit {
    session_id: SessionId,
    merkle_root: Blake3Hash,
    committed_at: Timestamp,
    committer: Did,
    summary: CommitSummary,
}

// Stored as a special vertex type in RhizoCrypt
impl LoamCommit {
    fn to_vertex(&self) -> Vertex {
        Vertex {
            event_type: EventType::LoamCommit,
            // ...
        }
    }
}
```

### Layer 3: SweetGrass (Query/Attribution)

SweetGrass isn't a separate store—it's a **materialized view** on RhizoCrypt:

```rust
// Attribution is embedded in vertices
struct Attribution {
    role: AgentRole,
    compute_units: Option<f64>,
    derived_from: Vec<Blake3Hash>,
    custom: HashMap<String, Value>,
}

// Queries traverse the DAG
impl SweetGrassQuery {
    fn provenance_graph(&self, entity: Blake3Hash) -> ProvenanceGraph {
        // Walk RhizoCrypt DAG, collect attribution
    }
    
    fn attribution_chain(&self, entity: Blake3Hash) -> AttributionChain {
        // Compute contributor shares from DAG
    }
}

// Export to PROV-O when needed
impl ProvenanceGraph {
    fn to_prov_o(&self) -> JsonLd { /* ... */ }
}
```

---

## Revised Timeline

Given the development model (human architect + parallel AI agents) that built Gen 1 in 6 months:

### Parallel Development (3-4 months total)

| Week | RhizoCrypt | LoamSpine | SweetGrass |
|------|------------|-----------|------------|
| 1-2 | Core vertex/DAG | - | - |
| 3-4 | Merkle trees | Commit semantics | Attribution struct |
| 5-6 | Sessions | Certificate model | Query basics |
| 7-8 | Persistence | Proofs | Provenance graph |
| 9-10 | Performance | Replication | Attribution calc |
| 11-12 | Integration | Integration | Integration |

**Total: ~12 weeks** with parallel development and unified architecture.

Compare to original estimate: 44 weeks sequential.

---

## Specifications

The original specs remain valid as **detailed references**:

| Document | Lines | Status |
|----------|-------|--------|
| [RHIZOCRYPT_SPECIFICATION.md](./RHIZOCRYPT_SPECIFICATION.md) | ~800 | Reference (core concepts valid) |
| [LOAMSPINE_SPECIFICATION.md](./LOAMSPINE_SPECIFICATION.md) | ~900 | Reference (permanence semantics) |
| [SWEETGRASS_SPECIFICATION.md](./SWEETGRASS_SPECIFICATION.md) | ~900 | Reference (query patterns) |
| [INTEGRATION_OVERVIEW.md](./INTEGRATION_OVERVIEW.md) | ~400 | Reference (data flows) |
| **[ARCHITECTURE.md](./ARCHITECTURE.md)** | ~300 | **Current** (unified model) |

**Read order:**
1. This README (overview)
2. ARCHITECTURE.md (unified model)
3. Individual specs (detailed reference)

---

## Key Concepts (Unchanged)

### The Philosophy of Forgetting

> Most data should be temporary. Only what matters should be permanent.

RhizoCrypt is **designed to be forgotten**. LoamSpine commits are **selective permanence**.

### The Raid Analogy

- RhizoCrypt tracks every chaotic event within a raid
- LoamSpine receives the validated extraction
- Items without valid DAG history are **rejected**

Anti-cheat is structural, not bolted on.

### Loam Certificates

Memory-bound objects with provenance:
- Digital game keys (lend without exposing credentials)
- Collectibles ("this deck won the championship")
- Credentials (recursive notarization)

### Radiating Attribution

SweetGrass queries enable sunCloud to distribute value:
- Walk the attribution chain
- Calculate contributor shares
- Distribute proportionally

---

## Getting Started

### BiomeOS (Production-Ready) ✅

BiomeOS is the orchestration layer that makes ecoPrimals accessible:

```bash
cd biomeOS/

# Build the workspace
cargo build --workspace

# Run tests (141+ tests, 100% pass rate)
cargo test --lib --tests

# Try a demo
cargo run --example simple_working_demo

# List available chimeras
cargo run -p biomeos-cli --bin biomeos -- chimera list
```

**See:** `biomeOS/README.md` and `biomeOS/MISSION_ACCOMPLISHED.md` for complete details.

### petalTongue (Production-Ready) ✅

petalTongue is the universal representation system for ecosystem visualization:

```bash
cd petalTongue/

# Build the workspace
cargo build --workspace --release

# Run tests (26 tests, 100% pass rate)
cargo test --all

# Run the UI (standalone with mock data)
cargo run --release -p petal-tongue-ui

# Run with live BiomeOS integration
BIOMEOS_URL=http://localhost:3000 cargo run --release -p petal-tongue-ui
```

**Features:**
- 🎨 Visual modality (2D graph with pan/zoom/select)
- 🎵 Audio modality (sonification with instruments/pitch/stereo)
- 🔌 Live BiomeOS integration (real-time updates)
- ♿ Accessibility-first (blind users hear what sighted users see)
- 🔄 Auto-refresh (configurable 1-60s intervals)

**See:** `petalTongue/README.md` and `petalTongue/STATUS.md` for complete details.

### RhizoCrypt/LoamSpine/SweetGrass (Specification Phase)

When ready to build the memory & attribution layer:

#### 1. Scaffold the Primals

```bash
cd /home/eastgate/Development/ecoPrimals
./sourDough/scripts/scaffold.sh new-primal rhizoCrypt "Core DAG Engine"
./sourDough/scripts/scaffold.sh new-primal loamSpine "Permanence Layer"
./sourDough/scripts/scaffold.sh new-primal sweetGrass "Attribution Layer"
```

#### 2. Build RhizoCrypt Core First

RhizoCrypt is the foundation. Start with:
- Vertex structure
- DAG storage
- Merkle tree computation
- Session management

#### 3. Add LoamSpine Semantics

LoamSpine is commit rules on RhizoCrypt:
- Commit entry type
- Certificate entries
- Permanence policies

#### 4. Add SweetGrass Queries

SweetGrass is views on RhizoCrypt:
- Attribution embedded in vertices
- Provenance graph traversal
- PROV-O export

---

## Design Evolution

### From Concept to Architecture

| Original Concept | Evolved Understanding |
|------------------|----------------------|
| Three separate primals | One engine, three faces |
| JSON-LD/PROV-O internal | RhizoFormat internal, PROV-O export |
| Sequential development | Parallel development |
| 44 weeks estimate | 12 weeks realistic |
| Complex integration | Unified codebase |

### Why the Evolution?

Discussion revealed:
1. RhizoCrypt is conceptually a **git-esque engine**
2. LoamSpine is **commit semantics**, not separate storage
3. SweetGrass is **query layer**, not separate store
4. Human+AI development model enables parallel builds
5. Custom format better serves the development model

---

## What's Next

1. **Implement RhizoCrypt core** with embedded attribution
2. **Add LoamSpine commit types** as vertex semantics
3. **Build SweetGrass queries** as DAG traversals
4. **Define RhizoFormat** during development
5. **Export to PROV-O** for interoperability

---

*Phase 2: One engine, three faces, infinite memory.*
