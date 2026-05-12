# Phase 2 Integration Overview

**Version:** 0.2.0  
**Date:** December 2025  
**Last Updated:** December 23, 2025  
**Status:** BiomeOS Production-Ready ✅ | DAG Integration Specified  

---

## How Phase 2 Components Work Together

This document describes the integration patterns between Phase 2 components (BiomeOS, RhizoCrypt, LoamSpine, SweetGrass) and their connections to the existing Gen 1 infrastructure.

### Component Status

| Component | Status | Role |
|-----------|--------|------|
| **BiomeOS** | ✅ Production-Ready | Orchestration layer for primal coordination |
| **RhizoCrypt** | 📋 Specified | Core DAG engine for event capture |
| **LoamSpine** | 📋 Specified | Permanence layer for commits |
| **SweetGrass** | 📋 Specified | Attribution layer for provenance |

**Note:** This document focuses on the memory & attribution layer (RhizoCrypt/LoamSpine/SweetGrass). For BiomeOS integration patterns, see `biomeOS/docs/ECOSYSTEM_INTEGRATION_GUIDE.md`.

---

## 1. The Data Lifecycle

### Complete Flow: From Event to Attribution

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         DATA LIFECYCLE                                   │
└─────────────────────────────────────────────────────────────────────────┘

  ┌──────────────────────────────────────────────────────────────────┐
  │  1. ACTIVITY OCCURS                                               │
  │     ToadStool executes a compute task                            │
  │     User performs actions in a game                              │
  │     Scientists run an experiment                                  │
  └────────────────────────────┬─────────────────────────────────────┘
                               │
                               ▼
  ┌──────────────────────────────────────────────────────────────────┐
  │  2. EVENTS CAPTURED (RhizoCrypt)                                  │
  │     Events appended to DAG as vertices                           │
  │     Parent relationships track causality                          │
  │     Optional BearDog signatures for critical events               │
  └────────────────────────────┬─────────────────────────────────────┘
                               │
                               ▼
  ┌──────────────────────────────────────────────────────────────────┐
  │  3. SESSION RESOLVES (RhizoCrypt)                                 │
  │     Activity completes (success/failure/timeout)                  │
  │     Merkle root computed over all vertices                        │
  │     Dehydration summary generated                                 │
  └────────────────────────────┬─────────────────────────────────────┘
                               │
                               ▼
  ┌──────────────────────────────────────────────────────────────────┐
  │  4. PERMANENT COMMIT (LoamSpine)                                  │
  │     Dehydration summary committed to spine                        │
  │     Entry signed by committer                                     │
  │     Merkle root provides provable link to DAG                     │
  └────────────────────────────┬─────────────────────────────────────┘
                               │
                               ▼
  ┌──────────────────────────────────────────────────────────────────┐
  │  5. BRAID CREATED (SweetGrass)                                    │
  │     Provenance record generated for outputs                       │
  │     Links inputs, outputs, agents, activities                     │
  │     Signed and committed to LoamSpine                             │
  └────────────────────────────┬─────────────────────────────────────┘
                               │
                               ▼
  ┌──────────────────────────────────────────────────────────────────┐
  │  6. DAG GARBAGE COLLECTED (RhizoCrypt)                            │
  │     Ephemeral data discarded                                      │
  │     Only Merkle root survives (in LoamSpine)                      │
  │     Future verification via proofs                                │
  └────────────────────────────┬─────────────────────────────────────┘
                               │
                               ▼
  ┌──────────────────────────────────────────────────────────────────┐
  │  7. ATTRIBUTION QUERIED (SweetGrass → sunCloud)                   │
  │     When value is generated from data                             │
  │     Attribution chain calculated                                  │
  │     Rewards distributed to all contributors                       │
  └──────────────────────────────────────────────────────────────────┘
```

---

## 2. Integration APIs

### 2.1 RhizoCrypt → LoamSpine

```rust
/// RhizoCrypt commits dehydrated sessions to LoamSpine
pub struct RhizoToLoamCommit {
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
    
    /// Extracted results (what survived)
    pub results: Vec<ResultEntry>,
    
    /// Agent participation
    pub agents: Vec<AgentSummary>,
    
    /// Signatures from participating agents
    pub attestations: Vec<Attestation>,
}

/// LoamSpine entry type for RhizoCrypt commits
impl Into<EntryType> for RhizoToLoamCommit {
    fn into(self) -> EntryType {
        EntryType::SessionCommit {
            session_id: self.session_id,
            session_type: self.session_type,
            merkle_root: self.merkle_root,
            summary: DehydrationSummary {
                created_at: self.created_at,
                resolved_at: self.resolved_at,
                outcome: self.outcome,
                vertex_count: self.vertex_count,
                payload_bytes: self.payload_bytes,
                results: self.results,
                agents: self.agents,
            },
        }
    }
}
```

### 2.2 LoamSpine → SweetGrass

```rust
/// SweetGrass listens to LoamSpine commits
pub struct LoamToSweetGrassEvent {
    /// The committed entry
    pub entry: LoamEntry,
    
    /// Spine it was committed to
    pub spine_id: SpineId,
    
    /// Entry hash (for linking)
    pub entry_hash: EntryHash,
}

/// SweetGrass creates Braids from LoamSpine commits
impl SweetGrassService {
    pub async fn on_loam_commit(&self, event: LoamToSweetGrassEvent) -> Result<Braid, Error> {
        match &event.entry.entry_type {
            EntryType::SessionCommit { summary, .. } => {
                // Create Braids for each result in the session
                for result in &summary.results {
                    let braid = self.create_braid(
                        result.data_hash,
                        result.mime_type.clone(),
                        result.size,
                        Some(Activity::from_session_summary(summary)),
                        result.derived_from.clone(),
                        event.entry.committer.clone(),
                        result.metadata.clone(),
                    ).await?;
                    
                    // Commit Braid back to LoamSpine
                    self.commit_braid(&braid).await?;
                }
            },
            EntryType::CertificateMint { .. } => {
                // Create provenance Braid for certificate
            },
            _ => {}
        }
        Ok(())
    }
}
```

### 2.3 SweetGrass → sunCloud

```rust
/// sunCloud queries SweetGrass for attribution
pub trait SunCloudAttributionSource {
    /// Get attribution chain for economic reward
    async fn get_attribution_chain(
        &self,
        entity: EntityReference,
    ) -> Result<AttributionChain, Error>;
    
    /// Calculate contributor shares
    async fn calculate_shares(
        &self,
        entity: EntityReference,
        total_value: Decimal,
    ) -> Result<Vec<RewardShare>, Error>;
}

/// Attribution chain structure
pub struct AttributionChain {
    /// Root entity
    pub entity: EntityReference,
    
    /// All contributors with shares
    pub contributors: Vec<ContributorShare>,
    
    /// Total compute consumed in chain
    pub total_compute: f64,
    
    /// Total storage consumed in chain
    pub total_storage: u64,
    
    /// Depth of provenance traversal
    pub depth: u32,
}

/// Reward share for distribution
pub struct RewardShare {
    pub agent: Did,
    pub share: f64,        // 0.0 to 1.0
    pub amount: Decimal,   // Computed from total_value * share
    pub role: AgentRole,
    pub direct: bool,      // Direct or inherited contribution
}
```

---

## 3. Gen 1 Integration Points

### 3.1 BearDog Integration

BearDog provides the cryptographic foundation for all three primals:

```
┌─────────────────────────────────────────────────────────────────┐
│                         BearDog                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐ │
│  │    DIDs     │  │  Signatures │  │    Lineage Proofs       │ │
│  │  Identity   │  │  Non-repud. │  │    Trust chains         │ │
│  └──────┬──────┘  └──────┬──────┘  └───────────┬─────────────┘ │
│         │                │                      │               │
└─────────┼────────────────┼──────────────────────┼───────────────┘
          │                │                      │
          ▼                ▼                      ▼
    ┌──────────┐    ┌──────────┐           ┌──────────┐
    │RhizoCrypt│    │LoamSpine │           │SweetGrass│
    │  Agent   │    │  Entry   │           │  Braid   │
    │   IDs    │    │  Sigs    │           │  Sigs    │
    └──────────┘    └──────────┘           └──────────┘
```

**Used for:**
- Agent identification in RhizoCrypt events
- Entry signing in LoamSpine
- Braid signing in SweetGrass
- Lineage verification for trust assessment

### 3.2 ToadStool Integration

ToadStool is the primary event source for RhizoCrypt:

```
┌─────────────────────────────────────────────────────────────────┐
│                        ToadStool                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐ │
│  │    Task     │  │   Resource  │  │      Result             │ │
│  │   Events    │  │   Metrics   │  │      Data               │ │
│  └──────┬──────┘  └──────┬──────┘  └───────────┬─────────────┘ │
│         │                │                      │               │
└─────────┼────────────────┼──────────────────────┼───────────────┘
          │                │                      │
          ▼                ▼                      ▼
    ┌──────────────────────────────────────────────────┐
    │                   RhizoCrypt                      │
    │                                                   │
    │  task.started → CreateSession                    │
    │  task.progress → AppendEvent                     │
    │  task.completed → ResolveSession + Dehydrate     │
    │                                                   │
    │  compute_units tracked for SweetGrass            │
    │  storage_bytes tracked for SweetGrass            │
    └──────────────────────────────────────────────────┘
```

**Event types:**
- `task.started` → Creates RhizoCrypt session
- `task.progress` → Appends progress events
- `task.completed` → Triggers session resolution
- `task.failed` → Triggers session discard

### 3.3 NestGate Integration

NestGate stores the actual data blobs; Phase 2 stores references:

```
┌─────────────────────────────────────────────────────────────────┐
│                        NestGate                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│              Content-Addressed Blob Storage                     │
│                                                                 │
│         ┌─────────────────────────────────────────┐             │
│         │  sha256:abc123... → [actual bytes]      │             │
│         │  sha256:def456... → [actual bytes]      │             │
│         │  sha256:ghi789... → [actual bytes]      │             │
│         └─────────────────────────────────────────┘             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
           ┌──────────────────┼──────────────────┐
           │                  │                  │
           ▼                  ▼                  ▼
     ┌──────────┐       ┌──────────┐      ┌──────────┐
     │RhizoCrypt│       │LoamSpine │      │SweetGrass│
     │ payload  │       │  anchors │      │ dataHash │
     │   refs   │       │ dataHash │      │ linking  │
     └──────────┘       └──────────┘      └──────────┘
```

**Separation of concerns:**
- NestGate stores bytes
- Phase 2 stores hashes and metadata
- Content-addressable linking ensures integrity

### 3.4 Songbird Integration

Songbird provides service discovery and orchestration:

```
┌─────────────────────────────────────────────────────────────────┐
│                        Songbird                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐ │
│  │     UPA     │  │  BirdSong   │  │     Federation          │ │
│  │  Discovery  │  │  Broadcast  │  │     Routing             │ │
│  └──────┬──────┘  └──────┬──────┘  └───────────┬─────────────┘ │
│         │                │                      │               │
└─────────┼────────────────┼──────────────────────┼───────────────┘
          │                │                      │
          ▼                ▼                      ▼
    ┌──────────────────────────────────────────────────┐
    │                 Phase 2 Services                  │
    │                                                   │
    │  RhizoCrypt registers: /rhizocrypt/v1            │
    │  LoamSpine registers:  /loamspine/v1             │
    │  SweetGrass registers: /sweetgrass/v1            │
    │                                                   │
    │  Federation sync uses BirdSong for discovery     │
    └──────────────────────────────────────────────────┘
```

---

## 4. Cross-Primal Verification

### 4.1 Verifying RhizoCrypt Proofs via LoamSpine

```rust
/// Verify an item's provenance across systems
pub async fn verify_item_provenance(
    item_hash: ContentHash,
    claimed_session: SessionId,
    loam: &impl LoamSpineClient,
    rhizo: &impl RhizoCryptClient,
) -> Result<VerificationResult, Error> {
    // 1. Find LoamSpine commit for the session
    let commit = loam.find_session_commit(&claimed_session).await?;
    
    // 2. Get Merkle root from commit
    let merkle_root = commit.summary.merkle_root;
    
    // 3. Request Merkle proof from RhizoCrypt (if DAG still exists)
    //    or verify proof provided by claimant
    let proof = rhizo.get_merkle_proof(&claimed_session, &item_hash).await?;
    
    // 4. Verify proof against committed root
    let valid = proof.verify_against(&merkle_root);
    
    Ok(VerificationResult {
        item: item_hash,
        session: claimed_session,
        commit: commit.entry_hash,
        valid,
        timestamp: commit.timestamp,
    })
}
```

### 4.2 Tracing Attribution via SweetGrass

```rust
/// Trace full attribution for an entity
pub async fn trace_attribution(
    entity: EntityReference,
    sweet: &impl SweetGrassClient,
    loam: &impl LoamSpineClient,
    beardog: &impl BearDogClient,
) -> Result<AttributionTrace, Error> {
    // 1. Get provenance graph from SweetGrass
    let graph = sweet.get_provenance_graph(&entity, Some(10)).await?;
    
    // 2. Verify all Braids are committed to LoamSpine
    for braid in graph.entities.values() {
        let committed = loam.verify_braid_commitment(&braid.id).await?;
        if !committed {
            return Err(Error::BraidNotCommitted(braid.id.clone()));
        }
    }
    
    // 3. Verify all agent signatures via BearDog
    for braid in graph.entities.values() {
        let valid = beardog.verify_braid(&braid).await?;
        if !valid {
            return Err(Error::InvalidSignature(braid.id.clone()));
        }
    }
    
    // 4. Calculate verified attribution chain
    let chain = sweet.calculate_contributions(&entity).await?;
    
    Ok(AttributionTrace {
        entity,
        graph,
        chain,
        fully_verified: true,
    })
}
```

---

## 5. Example Scenarios

### 5.1 Scientific Computation

```
1. Scientist submits protein folding job to ToadStool
   │
   ├─► ToadStool emits task.started
   │   └─► RhizoCrypt creates session "fold-session-123"
   │
   ├─► ToadStool processes (1.5 hours, 1.5 compute units)
   │   └─► RhizoCrypt captures progress events
   │
   ├─► ToadStool emits task.completed with output hash
   │   └─► RhizoCrypt resolves session, generates Merkle root
   │
   ├─► RhizoCrypt dehydrates to LoamSpine
   │   └─► Entry: SessionCommit { merkle_root, compute_units: 1.5 }
   │
   ├─► SweetGrass creates Braid for output
   │   └─► Links: input sequence → AlphaFold activity → output structure
   │   └─► Contributors: scientist, compute provider, data source
   │
   └─► RhizoCrypt DAG garbage collected (Merkle root preserved)

Years later:
   │
   └─► Discovery leads to drug target
       └─► sunCloud queries SweetGrass attribution
           └─► Rewards distributed to all contributors
```

### 5.2 Gaming (Escape from Tarkov style)

```
1. Player joins raid
   │
   ├─► RhizoCrypt creates session "raid-abc123"
   │   └─► EventType: SessionStart { type: "tarkov_raid" }
   │
   ├─► Player loots AK-47 from crate
   │   └─► RhizoCrypt: ItemLoot { item: "ak-47-uuid", location: ... }
   │
   ├─► Player trades AK-47 to teammate
   │   └─► RhizoCrypt: ItemTransfer { from: player1, to: player2 }
   │
   ├─► Raid ends, player2 extracts with AK-47
   │   └─► RhizoCrypt: Extraction { inventory: ["ak-47-uuid", ...] }
   │   └─► Session resolves: Success
   │
   ├─► RhizoCrypt dehydrates to LoamSpine
   │   └─► Only extracted items get permanent provenance
   │   └─► Died-with items have no extraction proof
   │
   └─► Player2 tries to sell AK-47 on marketplace
       └─► Marketplace verifies:
           1. LoamSpine commit exists for claiming raid
           2. Merkle proof shows ItemTransfer from player1
           3. Merkle proof shows Extraction with item
           └─► Item is legitimate, sale proceeds
```

### 5.3 Digital Game Key Lending

```
1. Publisher mints game key certificate
   │
   ├─► LoamSpine: CertificateMint {
   │       cert_id: "hl3-key-001",
   │       type: DigitalGameKey { game: "Half-Life 3" },
   │       owner: did:key:publisher
   │   }
   │
   ├─► SweetGrass: Braid for mint event
   │
2. Publisher sells to retailer
   │
   ├─► LoamSpine: CertificateTransfer {
   │       from: publisher, to: retailer
   │   }
   │
3. Retailer sells to customer
   │
   ├─► LoamSpine: CertificateTransfer {
   │       from: retailer, to: player1
   │   }
   │
4. Customer loans to friend
   │
   ├─► LoamSpine: CertificateLoan {
   │       lender: player1,
   │       borrower: friend,
   │       terms: { duration: 48h, auto_return: true }
   │   }
   │
   ├─► Friend can now activate game
   │   └─► Game client verifies CertificateLoan is active
   │
5. Loan expires
   │
   ├─► LoamSpine: CertificateReturn (automatic)
   │
   └─► Friend's access revoked, player1 owns again
```

---

## 6. Performance Considerations

### 6.1 Hot Path: Event Ingestion

```
ToadStool → RhizoCrypt
            │
            ├─► Target: < 1ms per event
            ├─► Batch: > 10,000 events/sec
            └─► Critical for gaming use cases
```

### 6.2 Warm Path: Session Resolution

```
RhizoCrypt → LoamSpine
            │
            ├─► Target: < 100ms for Merkle root
            ├─► Target: < 10ms for commit
            └─► Blocking for session completion
```

### 6.3 Cold Path: Attribution Query

```
SweetGrass → sunCloud
            │
            ├─► Target: < 200ms for full chain
            ├─► Can be async (rewards not real-time)
            └─► Caching recommended
```

---

## 7. Failure Modes & Recovery

### 7.1 RhizoCrypt Session Lost Before Commit

- Session expires or crashes
- DAG data lost
- **Recovery:** None—ephemeral by design
- **Impact:** Results not provable, items not extracted

### 7.2 LoamSpine Commit Fails

- Network partition during commit
- **Recovery:** Retry with idempotent commit
- **Impact:** Session remains in "Resolving" state

### 7.3 SweetGrass Braid Not Created

- Event listener misses LoamSpine commit
- **Recovery:** Replay from LoamSpine
- **Impact:** Attribution temporarily unavailable

---

*Integration makes the whole greater than the sum of parts.*

