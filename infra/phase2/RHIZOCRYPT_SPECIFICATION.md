# RhizoCrypt — Ephemeral Data Graph Specification

**Version:** 0.1.0 (Draft)  
**Status:** Architectural Specification  
**Author:** ecoPrimals Project  
**Date:** December 2025  
**License:** AGPL-3.0  

---

## Abstract

RhizoCrypt is the ephemeral working memory layer of the ecoPrimals ecosystem. It is a Directed Acyclic Graph (DAG) designed to capture high-frequency, complex, non-linear events during active sessions—design collaborations, scientific experiments, game matches, or any creative process. Unlike traditional storage systems that attempt to preserve everything, RhizoCrypt embraces a **Philosophy of Forgetting**: most data should be temporary. Only what matters is committed to the permanent record (LoamSpine).

RhizoCrypt provides the cryptographic integrity and provenance tracking necessary for trust, while being cheap enough to capture everything and ephemeral enough to scale indefinitely.

---

## 1. Core Principles

### 1.1 Designed to Be Forgotten

RhizoCrypt is **not** permanent storage. It is working memory. A RhizoCrypt session has a defined lifecycle:

1. **Creation** — A new DAG is spawned for a session
2. **Growth** — Events are appended as vertices, linked by edges
3. **Resolution** — The session concludes (success, failure, or timeout)
4. **Dehydration** — Important results are committed to LoamSpine
5. **Expiration** — The DAG is garbage collected

This lifecycle is fundamental. Systems that remember everything eventually collapse under their own weight. RhizoCrypt solves for infinite scalability by embracing selective forgetting.

### 1.2 Integrity Without Permanence

Every vertex in a RhizoCrypt DAG is:
- **Content-addressed** — Identified by the hash of its contents
- **Cryptographically linked** — References parent vertices by hash
- **Optionally signed** — BearDog identities can attest to events

This provides tamper-evidence and provenance *during* the session, even though the data will eventually be discarded.

### 1.3 The Raid Analogy

The Escape from Tarkov analogy illustrates the model:

- **RhizoCrypt** tracks every chaotic event *within* a raid:
  - Player movements and positions
  - Items looted, dropped, traded
  - Shots fired, damage dealt
  - Deaths, extractions, disconnections
  
- **LoamSpine** receives the *validated extraction*:
  - Final inventory delta
  - XP gained
  - Reputation changes
  - Proof of legitimate acquisition

Items without valid DAG history are rejected. This is anti-cheat built into the architecture—provenance is not optional, it's structural.

---

## 2. Data Model

### 2.1 Vertex Structure

```rust
/// A single event in the RhizoCrypt DAG
#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct RhizoVertex {
    /// Content-addressed identifier (Blake3 hash of canonical form)
    pub id: VertexId,
    
    /// References to parent vertices (empty for genesis)
    pub parents: Vec<VertexId>,
    
    /// Timestamp of vertex creation (monotonic within session)
    pub timestamp: Timestamp,
    
    /// The agent that created this vertex (BearDog DID)
    pub agent: Option<Did>,
    
    /// Event type (domain-specific)
    pub event_type: EventType,
    
    /// Event payload (domain-specific, content-addressed)
    pub payload: PayloadRef,
    
    /// Optional cryptographic signature from agent
    pub signature: Option<Signature>,
    
    /// Merkle proof of inclusion (populated after commit)
    pub merkle_proof: Option<MerkleProof>,
}

/// Content-addressed vertex identifier
pub type VertexId = [u8; 32]; // Blake3 hash

/// Reference to payload (stored separately for efficiency)
pub type PayloadRef = [u8; 32]; // Blake3 hash of payload
```

### 2.2 Session Structure

```rust
/// A RhizoCrypt session (the complete DAG)
#[derive(Clone, Debug)]
pub struct RhizoSession {
    /// Unique session identifier
    pub session_id: SessionId,
    
    /// Session type (game_match, experiment, collaboration, etc.)
    pub session_type: SessionType,
    
    /// Genesis timestamp
    pub created_at: Timestamp,
    
    /// Session configuration
    pub config: SessionConfig,
    
    /// All vertices in the DAG (indexed by VertexId)
    pub vertices: HashMap<VertexId, RhizoVertex>,
    
    /// Frontier vertices (tips of the DAG with no children)
    pub frontier: HashSet<VertexId>,
    
    /// Genesis vertices (roots with no parents)
    pub genesis: HashSet<VertexId>,
    
    /// Session state
    pub state: SessionState,
    
    /// Merkle root (computed lazily, cached)
    merkle_root: Option<MerkleRoot>,
}

#[derive(Clone, Debug)]
pub struct SessionConfig {
    /// Maximum session duration before forced resolution
    pub max_duration: Duration,
    
    /// Maximum vertices before forced commit
    pub max_vertices: usize,
    
    /// Payload storage backend
    pub payload_store: PayloadStoreConfig,
    
    /// Automatic dehydration settings
    pub dehydration: DehydrationConfig,
    
    /// Required signatures for certain event types
    pub signature_requirements: SignatureRequirements,
}

#[derive(Clone, Debug, PartialEq)]
pub enum SessionState {
    /// Actively accepting events
    Active,
    
    /// Preparing for resolution
    Resolving,
    
    /// Committed to LoamSpine, awaiting garbage collection
    Committed { loam_ref: LoamCommitRef },
    
    /// Discarded without commit (failed, timed out, etc.)
    Discarded { reason: DiscardReason },
    
    /// Garbage collected
    Expired,
}
```

### 2.3 Event Types

Event types are domain-specific and extensible:

```rust
/// Core event types (extensible per domain)
#[derive(Clone, Debug, Serialize, Deserialize)]
#[non_exhaustive]
pub enum EventType {
    // === Session Lifecycle ===
    SessionStart { metadata: SessionMetadata },
    SessionEnd { outcome: SessionOutcome },
    
    // === Agent Actions ===
    AgentJoin { agent: Did, role: AgentRole },
    AgentLeave { agent: Did, reason: LeaveReason },
    AgentAction { agent: Did, action: Action },
    
    // === Data Operations ===
    DataCreate { data_ref: PayloadRef, schema: SchemaRef },
    DataModify { data_ref: PayloadRef, delta: DeltaRef },
    DataDelete { data_ref: PayloadRef },
    DataTransfer { data_ref: PayloadRef, from: Did, to: Did },
    
    // === Gaming Domain ===
    GameEvent { event: GameEventPayload },
    ItemLoot { item: ItemRef, location: Location },
    ItemDrop { item: ItemRef, location: Location },
    ItemTransfer { item: ItemRef, from: Did, to: Did },
    Combat { attacker: Did, target: Did, outcome: CombatOutcome },
    Extraction { agent: Did, inventory: Vec<ItemRef> },
    
    // === Scientific Domain ===
    ExperimentStart { protocol: ProtocolRef },
    Observation { data: PayloadRef, instrument: InstrumentRef },
    Analysis { input: Vec<PayloadRef>, output: PayloadRef },
    Result { data: PayloadRef, confidence: f64 },
    
    // === Collaboration Domain ===
    DocumentEdit { doc: DocRef, delta: DeltaRef, cursor: Position },
    CommentAdd { doc: DocRef, comment: CommentRef },
    ApprovalGrant { doc: DocRef, approver: Did },
    
    // === Custom Domain ===
    Custom { domain: String, type_name: String, payload: PayloadRef },
}
```

---

## 3. Architecture

### 3.1 Component Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                      RhizoCrypt Service                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐ │
│  │   Session   │  │   Event     │  │      Dehydration        │ │
│  │   Manager   │  │   Ingester  │  │        Engine           │ │
│  └──────┬──────┘  └──────┬──────┘  └───────────┬─────────────┘ │
│         │                │                      │               │
│         ▼                ▼                      ▼               │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                    DAG Store                               │ │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐      │ │
│  │  │Session 1│  │Session 2│  │Session 3│  │   ...   │      │ │
│  │  └─────────┘  └─────────┘  └─────────┘  └─────────┘      │ │
│  └───────────────────────────────────────────────────────────┘ │
│                            │                                    │
│                            ▼                                    │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                   Payload Store                            │ │
│  │           (Content-Addressed Blob Storage)                 │ │
│  └───────────────────────────────────────────────────────────┘ │
│                            │                                    │
└────────────────────────────┼────────────────────────────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
   ┌─────────┐         ┌──────────┐        ┌───────────┐
   │ BearDog │         │LoamSpine │        │ ToadStool │
   │   🐻    │         │   🦴     │        │    🍄     │
   │ Signing │         │ Commits  │        │  Events   │
   └─────────┘         └──────────┘        └───────────┘
```

### 3.2 Session Manager

The Session Manager handles the lifecycle of RhizoCrypt sessions:

```rust
/// Session Manager API
pub trait SessionManager {
    /// Create a new session
    async fn create_session(
        &self,
        session_type: SessionType,
        config: SessionConfig,
        initiator: Did,
    ) -> Result<SessionHandle, RhizoError>;
    
    /// Get an active session by ID
    async fn get_session(&self, id: SessionId) -> Result<SessionHandle, RhizoError>;
    
    /// List active sessions (with optional filters)
    async fn list_sessions(&self, filter: SessionFilter) -> Result<Vec<SessionSummary>, RhizoError>;
    
    /// Force resolution of a session
    async fn resolve_session(
        &self,
        id: SessionId,
        outcome: SessionOutcome,
    ) -> Result<ResolutionReceipt, RhizoError>;
    
    /// Garbage collect expired sessions
    async fn gc(&self) -> Result<GcStats, RhizoError>;
}
```

### 3.3 Event Ingester

The Event Ingester provides the high-performance append path:

```rust
/// Event Ingester API
pub trait EventIngester {
    /// Append an event to a session
    async fn append(
        &self,
        session: SessionId,
        event: EventType,
        payload: Option<Bytes>,
        parents: Option<Vec<VertexId>>, // Auto-detected if None
        signature: Option<Signature>,
    ) -> Result<VertexId, RhizoError>;
    
    /// Batch append (for high-throughput scenarios)
    async fn append_batch(
        &self,
        session: SessionId,
        events: Vec<EventBatch>,
    ) -> Result<Vec<VertexId>, RhizoError>;
    
    /// Subscribe to session events (for real-time sync)
    fn subscribe(&self, session: SessionId) -> impl Stream<Item = RhizoVertex>;
}
```

### 3.4 Dehydration Engine

The Dehydration Engine handles the transition from RhizoCrypt to LoamSpine:

```rust
/// Dehydration Engine API
pub trait DehydrationEngine {
    /// Compute the Merkle root of a session
    async fn compute_merkle_root(&self, session: SessionId) -> Result<MerkleRoot, RhizoError>;
    
    /// Generate a dehydration summary for LoamSpine commit
    async fn dehydrate(
        &self,
        session: SessionId,
        config: DehydrationConfig,
    ) -> Result<DehydrationSummary, RhizoError>;
    
    /// Commit dehydrated summary to LoamSpine
    async fn commit_to_loam(
        &self,
        summary: DehydrationSummary,
        loam: &impl LoamSpineClient,
    ) -> Result<LoamCommitRef, RhizoError>;
    
    /// Generate Merkle proof for a specific vertex
    async fn generate_proof(
        &self,
        session: SessionId,
        vertex: VertexId,
    ) -> Result<MerkleProof, RhizoError>;
}

#[derive(Clone, Debug)]
pub struct DehydrationSummary {
    /// Session metadata
    pub session_id: SessionId,
    pub session_type: SessionType,
    pub created_at: Timestamp,
    pub resolved_at: Timestamp,
    pub outcome: SessionOutcome,
    
    /// Cryptographic summary
    pub merkle_root: MerkleRoot,
    pub vertex_count: usize,
    pub payload_bytes: usize,
    
    /// Extracted results (domain-specific)
    pub results: Vec<ResultEntry>,
    
    /// Agent participation summary
    pub agents: Vec<AgentSummary>,
    
    /// Signatures attesting to the summary
    pub attestations: Vec<Attestation>,
}
```

---

## 4. Storage Model

### 4.1 DAG Storage

RhizoCrypt sessions are stored in a fast, ephemeral store optimized for:
- High write throughput (thousands of events/second)
- Efficient parent lookups (DAG traversal)
- TTL-based expiration

**Recommended backends:**
- **In-memory** — For short sessions with high throughput
- **RocksDB** — For longer sessions requiring persistence
- **LMDB** — For memory-mapped performance with durability

```rust
/// DAG Store trait
pub trait DagStore: Send + Sync {
    /// Store a vertex
    async fn put_vertex(&self, session: SessionId, vertex: RhizoVertex) -> Result<(), StoreError>;
    
    /// Get a vertex by ID
    async fn get_vertex(&self, session: SessionId, id: VertexId) -> Result<Option<RhizoVertex>, StoreError>;
    
    /// Get vertices by parent (for DAG traversal)
    async fn get_children(&self, session: SessionId, parent: VertexId) -> Result<Vec<VertexId>, StoreError>;
    
    /// Get frontier vertices
    async fn get_frontier(&self, session: SessionId) -> Result<Vec<VertexId>, StoreError>;
    
    /// Iterate all vertices in a session
    fn iter_session(&self, session: SessionId) -> impl Stream<Item = RhizoVertex>;
    
    /// Delete a session (for GC)
    async fn delete_session(&self, session: SessionId) -> Result<(), StoreError>;
}
```

### 4.2 Payload Storage

Large payloads are stored separately and referenced by hash:

```rust
/// Payload Store trait (content-addressed)
pub trait PayloadStore: Send + Sync {
    /// Store a payload, returns content hash
    async fn put(&self, data: Bytes) -> Result<PayloadRef, StoreError>;
    
    /// Get a payload by hash
    async fn get(&self, hash: PayloadRef) -> Result<Option<Bytes>, StoreError>;
    
    /// Check existence without fetching
    async fn exists(&self, hash: PayloadRef) -> Result<bool, StoreError>;
    
    /// Delete payloads not referenced by any active session
    async fn gc(&self, active_refs: &HashSet<PayloadRef>) -> Result<GcStats, StoreError>;
}
```

---

## 5. Merkle Tree Structure

### 5.1 Tree Construction

RhizoCrypt uses a **positional Merkle tree** for efficient proofs:

```
                    Root
                   /    \
                  H01    H23
                 /  \   /   \
                H0  H1 H2   H3
                |   |   |    |
               V0  V1  V2   V3  (vertices in topological order)
```

The tree is constructed over vertices in **topological order** (parents before children).

### 5.2 Merkle Proof Structure

```rust
#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct MerkleProof {
    /// The vertex being proven
    pub vertex_id: VertexId,
    
    /// Position in the topological ordering
    pub position: usize,
    
    /// Sibling hashes from leaf to root
    pub siblings: Vec<(Direction, [u8; 32])>,
    
    /// The Merkle root this proof validates against
    pub root: MerkleRoot,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub enum Direction {
    Left,
    Right,
}

impl MerkleProof {
    /// Verify this proof
    pub fn verify(&self, vertex: &RhizoVertex) -> bool {
        let mut current = vertex.compute_hash();
        
        for (direction, sibling) in &self.siblings {
            current = match direction {
                Direction::Left => hash_pair(sibling, &current),
                Direction::Right => hash_pair(&current, sibling),
            };
        }
        
        current == self.root.0
    }
}
```

---

## 6. Integration Points

### 6.1 BearDog Integration

RhizoCrypt relies on BearDog for identity and signing:

```rust
/// BearDog client interface for RhizoCrypt
pub trait BearDogClient {
    /// Resolve a DID to a public key
    async fn resolve_did(&self, did: &Did) -> Result<PublicKey, BearDogError>;
    
    /// Request a signature for an event
    async fn sign_event(
        &self,
        event: &RhizoVertex,
        key_id: &KeyId,
    ) -> Result<Signature, BearDogError>;
    
    /// Verify a signature
    async fn verify_signature(
        &self,
        data: &[u8],
        signature: &Signature,
        did: &Did,
    ) -> Result<bool, BearDogError>;
}
```

### 6.2 LoamSpine Integration

RhizoCrypt commits to LoamSpine via the Dehydration Engine:

```rust
/// LoamSpine client interface for RhizoCrypt
pub trait LoamSpineClient {
    /// Commit a dehydration summary
    async fn commit(
        &self,
        summary: &DehydrationSummary,
        attestations: Vec<Attestation>,
    ) -> Result<LoamCommitRef, LoamError>;
    
    /// Verify a commit exists
    async fn verify_commit(&self, commit_ref: &LoamCommitRef) -> Result<bool, LoamError>;
}
```

### 6.3 ToadStool Integration

RhizoCrypt receives events from ToadStool compute tasks:

```rust
/// ToadStool event source for RhizoCrypt
pub trait ToadStoolEventSource {
    /// Subscribe to compute events
    fn subscribe(&self, task_id: TaskId) -> impl Stream<Item = ComputeEvent>;
}

#[derive(Clone, Debug)]
pub enum ComputeEvent {
    TaskStarted { task_id: TaskId, worker: Did },
    TaskProgress { task_id: TaskId, progress: f32 },
    TaskCompleted { task_id: TaskId, result: PayloadRef },
    TaskFailed { task_id: TaskId, error: String },
}
```

---

## 7. API Specification

### 7.1 gRPC Service Definition

```protobuf
syntax = "proto3";

package rhizocrypt.v1;

service RhizoCrypt {
    // Session management
    rpc CreateSession(CreateSessionRequest) returns (CreateSessionResponse);
    rpc GetSession(GetSessionRequest) returns (GetSessionResponse);
    rpc ListSessions(ListSessionsRequest) returns (ListSessionsResponse);
    rpc ResolveSession(ResolveSessionRequest) returns (ResolveSessionResponse);
    
    // Event operations
    rpc AppendEvent(AppendEventRequest) returns (AppendEventResponse);
    rpc AppendEventBatch(AppendEventBatchRequest) returns (AppendEventBatchResponse);
    rpc SubscribeEvents(SubscribeEventsRequest) returns (stream RhizoVertex);
    
    // Query operations
    rpc GetVertex(GetVertexRequest) returns (GetVertexResponse);
    rpc GetVertices(GetVerticesRequest) returns (GetVerticesResponse);
    rpc TraverseDAG(TraverseDAGRequest) returns (stream RhizoVertex);
    
    // Dehydration
    rpc ComputeMerkleRoot(ComputeMerkleRootRequest) returns (ComputeMerkleRootResponse);
    rpc GenerateProof(GenerateProofRequest) returns (GenerateProofResponse);
    rpc Dehydrate(DehydrateRequest) returns (DehydrateResponse);
}
```

### 7.2 REST API (via Songbird UPA)

```yaml
openapi: 3.0.0
info:
  title: RhizoCrypt API
  version: 1.0.0

paths:
  /sessions:
    post:
      summary: Create a new session
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateSessionRequest'
    get:
      summary: List sessions
      parameters:
        - name: state
          in: query
          schema:
            type: string
            enum: [active, committed, discarded]

  /sessions/{session_id}:
    get:
      summary: Get session details
    delete:
      summary: Resolve/discard session

  /sessions/{session_id}/events:
    post:
      summary: Append event
    get:
      summary: List events (with pagination)

  /sessions/{session_id}/merkle:
    get:
      summary: Get Merkle root
    
  /sessions/{session_id}/proof/{vertex_id}:
    get:
      summary: Generate Merkle proof for vertex
```

---

## 8. Performance Targets

| Metric | Target | Notes |
|--------|--------|-------|
| Event append latency | < 1ms | p99, single event |
| Batch append throughput | > 10,000 events/sec | Per session |
| DAG traversal | < 10ms | Full session, 100k vertices |
| Merkle root computation | < 100ms | 100k vertices |
| Proof generation | < 1ms | Single vertex |
| Memory per session | < 100 MB | 100k vertices |
| Session GC | < 1s | Per expired session |

---

## 9. Security Considerations

### 9.1 Tamper Evidence

- All vertices are content-addressed (hash includes parents)
- Modification of any vertex changes all descendant hashes
- Merkle proofs allow verification without full DAG

### 9.2 Optional Signing

- Critical events can require BearDog signatures
- Signature requirements are configurable per session type
- Missing required signatures prevent session resolution

### 9.3 Access Control

- Sessions can be private (single agent) or collaborative (multiple agents)
- BearDog policies govern who can append to which sessions
- Read access can be more permissive than write access

### 9.4 Denial of Service

- Per-session vertex limits prevent unbounded growth
- Per-agent rate limiting at the ingester
- Automatic session timeout prevents zombie sessions

---

## 10. Implementation Roadmap

### Phase 1: Core Engine (4 weeks)
- [ ] Vertex and Session data structures
- [ ] In-memory DAG store
- [ ] Basic event ingestion
- [ ] Session lifecycle management

### Phase 2: Persistence (2 weeks)
- [ ] RocksDB DAG store backend
- [ ] Content-addressed payload store
- [ ] Session serialization/deserialization

### Phase 3: Merkle Trees (2 weeks)
- [ ] Merkle tree construction
- [ ] Proof generation
- [ ] Proof verification

### Phase 4: Dehydration (2 weeks)
- [ ] Dehydration summary generation
- [ ] LoamSpine commit integration
- [ ] Garbage collection

### Phase 5: Integration (2 weeks)
- [ ] BearDog signing integration
- [ ] ToadStool event source
- [ ] Songbird UPA registration

### Phase 6: Performance & Hardening (2 weeks)
- [ ] Benchmarking and optimization
- [ ] Fuzz testing
- [ ] Security audit

---

## 11. References

- [W3C PROV-DM](https://www.w3.org/TR/prov-dm/) — Provenance Data Model
- [IPLD DAG-CBOR](https://ipld.io/specs/codecs/dag-cbor/) — Content-addressed data structures
- [Merkle Trees](https://en.wikipedia.org/wiki/Merkle_tree) — Cryptographic verification
- [BearDog Specification](../beardog/specs/) — Identity and signing
- [LoamSpine Specification](./LOAMSPINE_SPECIFICATION.md) — Permanent storage

---

## Appendix A: Example Session Flow (Gaming)

```
1. Player joins match
   → CreateSession(type: "tarkov_raid", config: {...})
   → SessionId: "raid-abc123"

2. Player loots item
   → AppendEvent(session: "raid-abc123", event: ItemLoot {
       item: "ak-47-uuid",
       location: (x: 100, y: 50, z: 0)
     })
   → VertexId: "v1"

3. Player trades item to teammate
   → AppendEvent(session: "raid-abc123", event: ItemTransfer {
       item: "ak-47-uuid",
       from: "did:key:player1",
       to: "did:key:player2"
     }, parents: ["v1"])
   → VertexId: "v2"

4. Match ends, player extracts
   → AppendEvent(session: "raid-abc123", event: Extraction {
       agent: "did:key:player1",
       inventory: ["pistol-uuid", "medkit-uuid"]
     })
   → VertexId: "v100"

5. Session resolves
   → ResolveSession(session: "raid-abc123", outcome: Success)
   → Dehydrate → LoamSpine commit
   → Items in extraction gain permanent provenance

6. Later: Item verification
   → Query LoamSpine for "ak-47-uuid"
   → Verify Merkle proof traces to valid raid
   → Item is legitimate
```

---

*RhizoCrypt: The memory that knows when to forget.*

