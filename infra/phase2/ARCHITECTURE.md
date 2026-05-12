# Phase 2 Architecture: The Unified Model

**Version:** 2.1  
**Date:** December 2025  
**Last Updated:** December 23, 2025  
**Status:** BiomeOS Production-Ready ✅ | DAG Layer In Specification

---

## Executive Summary

Phase 2 consists of:
1. **BiomeOS** — Orchestration substrate (✅ Production-Ready)
2. **RhizoCrypt** — Core DAG engine (📋 Specified)
3. **LoamSpine** — Permanence layer (📋 Specified)
4. **SweetGrass** — Attribution layer (📋 Specified)

### Key Architecture Insight

The memory & attribution system is **one DAG engine** (RhizoCrypt) with **two semantic layers** (LoamSpine for permanence, SweetGrass for attribution). This is simpler to build, simpler to reason about, and more powerful than three separate systems.

### Current Implementation Status

**BiomeOS** has achieved production-ready status with:
- ✅ Real HTTP implementations (no mocks)
- ✅ Capability-based discovery (zero hardcoded endpoints)
- ✅ 141+ tests passing (100% pass rate)
- ✅ ~50% test coverage
- ✅ Grade A code quality
- ✅ Modern idiomatic Rust

**See:** `biomeOS/MISSION_ACCOMPLISHED.md` for complete details.

---

## 1. The Core Insight: RhizoCrypt as Git-esque Engine

RhizoCrypt isn't just "session capture." It's a **general-purpose content-addressed DAG engine** comparable to git's object model—but designed for:

- **Ephemeral by default** (git is permanent by default)
- **Real-time streaming** (git is batch commits)
- **Multi-agent native** (git is single-author)
- **Selective forgetting** (git keeps everything)

### Mapping to Git

| Git | RhizoCrypt | Difference |
|-----|------------|------------|
| `.git/objects` | Vertex store | Content-addressed |
| Commit | Vertex | Signed, typed, attributed |
| Tree | Payload | Separate blob store |
| Branch | Frontier | Multiple tips natural |
| Merge | Multi-parent vertex | Not special case |
| Reflog | Session history | Ephemeral |
| Push | Dehydrate → LoamSpine | Selective |
| Repository | Session | Scoped, temporary |

---

## 2. Architectural Layers

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Application Layer                            │
│   Gaming │ Scientific │ Collaboration │ Certificates │ Economics    │
└─────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      Query & Export Layer                            │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  │
│  │   SweetGrass     │  │   PROV-O Export  │  │   GraphQL API    │  │
│  │   (attribution)  │  │   (interop)      │  │   (queries)      │  │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      Semantics Layer                                 │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  │
│  │   LoamSpine      │  │   Certificates   │  │   Sessions       │  │
│  │   (commits)      │  │   (ownership)    │  │   (scopes)       │  │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      RhizoCrypt Core                                 │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐    │
│  │  Vertices  │  │    DAG     │  │   Merkle   │  │  Payloads  │    │
│  │  (events)  │  │   (links)  │  │   (proofs) │  │  (blobs)   │    │
│  └────────────┘  └────────────┘  └────────────┘  └────────────┘    │
└─────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      Storage Layer                                   │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  RocksDB / LMDB / Custom                                        │ │
│  │  (vertices, payloads, indexes)                                  │ │
│  └────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 3. RhizoCrypt Core

### 3.1 Vertex Structure

The fundamental unit:

```rust
/// A vertex in the RhizoCrypt DAG
pub struct Vertex {
    /// Content-addressed ID (Blake3 hash of canonical form)
    pub id: VertexId,
    
    /// Parent vertices (empty for roots)
    pub parents: Vec<VertexId>,
    
    /// Timestamp with nanosecond precision
    pub timestamp: Timestamp,
    
    /// Agent who created this vertex (BearDog DID)
    pub agent: Did,
    
    /// Event type (determines semantics)
    pub event_type: EventType,
    
    /// Reference to payload (content-addressed)
    pub payload: Option<PayloadRef>,
    
    /// Embedded attribution (SweetGrass metadata)
    pub attribution: Attribution,
    
    /// Cryptographic signature
    pub signature: Signature,
}

/// Attribution metadata embedded in every vertex
pub struct Attribution {
    /// Role of the agent
    pub role: AgentRole,
    
    /// Compute units consumed (for economics)
    pub compute_units: Option<f64>,
    
    /// Entities this was derived from
    pub derived_from: Vec<VertexId>,
    
    /// Custom domain-specific attributes
    pub custom: HashMap<String, Value>,
}
```

### 3.2 Event Types

Event types determine vertex semantics:

```rust
pub enum EventType {
    // === Session Lifecycle ===
    SessionStart { session_type: SessionType },
    SessionEnd { outcome: Outcome },
    
    // === Generic Data Events ===
    DataCreate { schema: Option<SchemaRef> },
    DataModify { delta: DeltaRef },
    DataDelete,
    
    // === LoamSpine Semantics (permanence) ===
    LoamCommit { merkle_root: MerkleRoot, summary: CommitSummary },
    CertificateMint { cert_type: CertificateType },
    CertificateTransfer { to: Did },
    CertificateLoan { borrower: Did, terms: LoanTerms },
    CertificateReturn,
    
    // === Domain-Specific ===
    Gaming(GamingEvent),
    Scientific(ScientificEvent),
    Collaboration(CollaborationEvent),
    
    // === Extensible ===
    Custom { type_uri: String },
}
```

### 3.3 Sessions

Sessions scope vertices and manage lifecycle:

```rust
pub struct Session {
    /// Unique session ID
    pub id: SessionId,
    
    /// Session type
    pub session_type: SessionType,
    
    /// All vertices in this session
    pub vertices: HashMap<VertexId, Vertex>,
    
    /// Frontier (tips of the DAG)
    pub frontier: HashSet<VertexId>,
    
    /// Genesis vertices (roots)
    pub genesis: HashSet<VertexId>,
    
    /// Session state
    pub state: SessionState,
    
    /// Configuration
    pub config: SessionConfig,
}

pub enum SessionState {
    Active,
    Resolving,
    Committed { loam_ref: VertexId },
    Discarded { reason: String },
    Expired,
}
```

---

## 4. LoamSpine: Permanence Semantics

LoamSpine isn't a separate database—it's **vertex types and rules** that implement permanence:

### 4.1 Commits as Vertices

```rust
/// A LoamSpine commit is a special vertex
impl LoamCommit {
    pub fn to_vertex(&self, session: &Session, signer: &impl Signer) -> Vertex {
        Vertex {
            id: self.compute_id(),
            parents: session.frontier.iter().cloned().collect(),
            timestamp: Timestamp::now(),
            agent: signer.did().clone(),
            event_type: EventType::LoamCommit {
                merkle_root: session.merkle_root(),
                summary: self.summary.clone(),
            },
            payload: Some(self.summary_payload()),
            attribution: Attribution::commit(),
            signature: signer.sign(&self.canonical_bytes()),
        }
    }
}
```

### 4.2 Certificates as Vertices

```rust
/// Certificate operations are vertex chains
pub struct Certificate {
    /// Mint vertex (genesis)
    pub mint: VertexId,
    
    /// Current state vertex
    pub current: VertexId,
    
    /// Certificate type
    pub cert_type: CertificateType,
}

impl Certificate {
    /// Get ownership history by walking the DAG
    pub fn history(&self, dag: &Dag) -> Vec<OwnershipRecord> {
        dag.walk_from(self.mint)
            .filter(|v| v.is_certificate_event())
            .map(OwnershipRecord::from_vertex)
            .collect()
    }
    
    /// Transfer creates a new vertex
    pub fn transfer(&self, to: Did, signer: &impl Signer) -> Vertex {
        Vertex {
            parents: vec![self.current],
            event_type: EventType::CertificateTransfer { to },
            // ...
        }
    }
}
```

### 4.3 Permanence Rules

LoamSpine permanence is enforced by:

1. **Commit vertices** — Mark session boundaries
2. **Certificate chains** — Ownership can't be rewritten
3. **Merkle proofs** — Verify without full DAG
4. **Replication** — Committed vertices are synced

---

## 5. SweetGrass: Query & Attribution Layer

SweetGrass isn't a separate store—it's **queries and materialized views** on the DAG:

### 5.1 Attribution is Embedded

Every vertex carries its attribution:

```rust
// When creating a vertex
let vertex = Vertex {
    attribution: Attribution {
        role: AgentRole::Creator,
        compute_units: Some(1.5),
        derived_from: vec![input_vertex_id],
        custom: HashMap::new(),
    },
    // ...
};
```

### 5.2 Queries Traverse the DAG

```rust
impl SweetGrassQueries {
    /// Get full provenance graph
    pub fn provenance_graph(&self, entity: VertexId, depth: usize) -> ProvenanceGraph {
        let mut graph = ProvenanceGraph::new(entity);
        let mut queue = VecDeque::from([entity]);
        let mut visited = HashSet::new();
        
        while let Some(current) = queue.pop_front() {
            if visited.contains(&current) || graph.depth() > depth {
                continue;
            }
            visited.insert(current);
            
            if let Some(vertex) = self.dag.get(&current) {
                graph.add_vertex(vertex.clone());
                
                // Follow derivation links
                for derived in &vertex.attribution.derived_from {
                    queue.push_back(*derived);
                }
                
                // Follow parent links
                for parent in &vertex.parents {
                    queue.push_back(*parent);
                }
            }
        }
        
        graph
    }
    
    /// Calculate attribution shares
    pub fn attribution_chain(&self, entity: VertexId) -> AttributionChain {
        let graph = self.provenance_graph(entity, 10);
        
        let mut contributions: HashMap<Did, f64> = HashMap::new();
        
        for vertex in graph.vertices() {
            let weight = self.role_weight(&vertex.attribution.role);
            *contributions.entry(vertex.agent.clone()).or_default() += weight;
        }
        
        // Normalize to sum to 1.0
        let total: f64 = contributions.values().sum();
        
        AttributionChain {
            entity,
            contributors: contributions
                .into_iter()
                .map(|(agent, share)| ContributorShare {
                    agent,
                    share: share / total,
                })
                .collect(),
        }
    }
}
```

### 5.3 Export to PROV-O

When interoperability is needed:

```rust
impl ProvenanceGraph {
    /// Export to W3C PROV-O JSON-LD
    pub fn to_prov_o(&self) -> serde_json::Value {
        json!({
            "@context": "https://www.w3.org/ns/prov",
            "@graph": self.vertices().map(|v| {
                json!({
                    "@id": format!("urn:rhizo:{}", v.id),
                    "@type": "prov:Entity",
                    "prov:wasGeneratedBy": {
                        "@type": "prov:Activity",
                        "prov:wasAssociatedWith": v.agent.to_string(),
                    },
                    "prov:wasDerivedFrom": v.attribution.derived_from
                        .iter()
                        .map(|id| format!("urn:rhizo:{}", id))
                        .collect::<Vec<_>>(),
                })
            }).collect::<Vec<_>>()
        })
    }
}
```

---

## 6. RhizoFormat

### 6.1 Design Goals

| Goal | Rationale |
|------|-----------|
| Human readable | Developer/architect can read it |
| AI parseable | Agents can work with it |
| Streamable | Line-oriented for pipes |
| Diff-able | Git-friendly |
| Binary-packable | Efficient storage |

### 6.2 Format Specification

```
# RhizoFormat v1

# Vertex
v1:vertex
  id: blake3:a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6
  parents: [blake3:..., blake3:...]
  ts: 1703239200.123456789
  agent: did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK
  type: data_create
  payload: blake3:...
  
  # Embedded attribution
  attr:
    role: creator
    compute: 1.5
    derived: [blake3:...]
  
  sig: ed25519:...

# Session header
v1:session
  id: session:abc123
  type: gaming:raid
  created: 1703239200.0
  state: active

# Commit
v1:commit
  session: session:abc123
  merkle: blake3:...
  vertices: 1234
  agents: 5
```

### 6.3 Binary Packing

For storage and wire:

```rust
impl Vertex {
    /// Pack to CBOR for storage
    pub fn to_cbor(&self) -> Vec<u8> {
        serde_cbor::to_vec(self).unwrap()
    }
    
    /// Unpack from CBOR
    pub fn from_cbor(bytes: &[u8]) -> Result<Self, Error> {
        serde_cbor::from_slice(bytes)
    }
    
    /// Pretty print for humans/AI
    pub fn to_rhizoformat(&self) -> String {
        format!(
            "v1:vertex\n  id: blake3:{}\n  ...",
            hex::encode(&self.id)
        )
    }
}
```

---

## 7. Implementation Strategy

### 7.1 Build Order

```
Week 1-4: RhizoCrypt Core
├── Vertex structure
├── DAG storage (in-memory first)
├── Session management
└── Merkle tree computation

Week 5-8: LoamSpine Semantics
├── Commit vertex type
├── Certificate vertex types
├── Permanence rules
└── Basic replication

Week 9-12: SweetGrass Queries
├── Attribution embedded
├── Provenance graph traversal
├── Attribution calculation
└── PROV-O export

Week 13-14: Integration & Polish
├── Full data flow testing
├── Performance tuning
└── Documentation
```

### 7.2 Crate Structure

```
rhizoCrypt/
├── crates/
│   ├── rhizocrypt-core/      # Vertex, DAG, Merkle
│   ├── rhizocrypt-storage/   # RocksDB backend
│   ├── rhizocrypt-session/   # Session management
│   └── rhizocrypt-format/    # RhizoFormat parser/writer

loamSpine/
├── crates/
│   ├── loamspine-core/       # Commit, Certificate types
│   ├── loamspine-rules/      # Permanence enforcement
│   └── loamspine-sync/       # Replication

sweetGrass/
├── crates/
│   ├── sweetgrass-core/      # Query engine
│   ├── sweetgrass-graphql/   # GraphQL API
│   └── sweetgrass-export/    # PROV-O, JSON-LD
```

---

## 8. Key Differences from Original Specs

| Original | Evolved |
|----------|---------|
| Three separate stores | One DAG with semantic layers |
| JSON-LD internal | RhizoFormat internal, JSON-LD export |
| Braids as separate objects | Attribution embedded in vertices |
| Complex integration | Unified codebase |
| 44 weeks sequential | 12 weeks parallel |

---

## 9. References

- [Original RhizoCrypt Spec](./RHIZOCRYPT_SPECIFICATION.md) — Detailed DAG concepts
- [Original LoamSpine Spec](./LOAMSPINE_SPECIFICATION.md) — Certificate model details
- [Original SweetGrass Spec](./SWEETGRASS_SPECIFICATION.md) — Query patterns
- [Integration Overview](./INTEGRATION_OVERVIEW.md) — Data flow diagrams

---

*Architecture: The shape that lets complexity become simplicity.*

