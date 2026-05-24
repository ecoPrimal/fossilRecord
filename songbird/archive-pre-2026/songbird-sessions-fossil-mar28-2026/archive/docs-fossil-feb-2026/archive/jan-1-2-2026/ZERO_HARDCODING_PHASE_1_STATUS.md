# 🎯 Zero Hardcoding Migration - Phase 1 Status

**Date**: January 1, 2026  
**Status**: IN PROGRESS - Core Architecture Refactored (85% Complete)  
**Goal**: Eliminate ALL primal name/vendor/numeric hardcoding → Pure capability-based discovery

---

## 📊 Executive Summary

**What We're Doing**: Transforming Songbird from "knows about BearDog" → "discovers security capabilities"

**Progress**: 
- ✅ Core architecture modules created (3/3)
- 🔄 Compilation fixes in progress (70% done)
- ⏳ Testing & numeric hardcoding cleanup (pending)

**Impact**: Once complete, Songbird can work with ANY security provider, storage provider, etc. - discovered at runtime!

---

## ✅ Completed Work (90 minutes)

### 1. Created `security_capability_client.rs` (Provider-Agnostic Security Client)

**File**: `crates/songbird-orchestrator/src/security_capability_client.rs`

**Before** (Hardcoded):
```rust
let beardog = BearDogClient::new("http://localhost:9000");
let response = beardog.get_identity().await?;
```

**After** (Capability-Based):
```rust
let endpoint = UniversalAdapter::discover_capability("security").await?;
let security = SecurityCapabilityClient::from_endpoint(endpoint);
let response = security.get_identity().await?;
```

**Key Features**:
- No hardcoded primal names!
- Discovers security provider via capability query
- Works with ANY provider offering "security" capability
- Backward compatibility alias for gradual migration

**Changes Made**:
- Renamed from `beardog_client.rs` → `security_capability_client.rs`
- Updated all docs: "BearDog" → "security provider"
- Added `from_endpoint()` constructor (discoverable endpoint)
- Added deprecated `new()` alias for backward compat
- Updated tests to use generic endpoints

### 2. Created `self_knowledge.rs` (Zero Hardcoding Self-Awareness)

**File**: `crates/songbird-orchestrator/src/self_knowledge.rs` (NEW - 340 lines)

**Philosophy**: A primal only knows about ITSELF. Everything else is discovered!

**What We Know**:
- ✅ Our node ID
- ✅ Our hostname
- ✅ Our capabilities (discovery, orchestration, federation)
- ✅ Our network interfaces (detected)
- ✅ Our listening ports (from env or auto-select)

**What We DON'T Know** (Discovered at runtime):
- ❌ BearDog (or ANY other primal)
- ❌ Kubernetes (or ANY orchestrator)
- ❌ Consul (or ANY service registry)

**Key Types**:
```rust
pub struct SelfKnowledge {
    pub node_id: Uuid,
    pub hostname: String,
    pub primal_type: PrimalType, // Orchestrator, Security, Storage, etc.
    pub capabilities: Vec<String>, // What we CAN DO
    pub interfaces: Vec<NetworkInterface>, // Detected at runtime
    pub endpoints: Vec<SelfEndpoint>, // Ports from env or auto-select
    pub environment: EnvironmentConfig, // All from env vars!
}
```

**Self-Discovery Flow**:
1. Detect hostname → `hostname::get()`
2. Detect network interfaces → `netdev::get_interfaces()`
3. Read capabilities from env → `PRIMAL_TYPE`, `ADDITIONAL_CAPABILITIES`
4. Select ports → `HTTP_PORT` env or auto (port 0)
5. Load environment config → `RUST_LOG`, `DATA_DIR`, etc.

### 3. Created `universal_adapter.rs` (Capability-Based Discovery)

**File**: `crates/songbird-orchestrator/src/universal_adapter.rs` (NEW - 380 lines)

**Purpose**: Discover and communicate with ANY primal without hardcoding!

**Discovery Methods**:
1. **Environment**: `CAPABILITY_PROVIDERS='security=http://192.168.1.10:9000'`
2. **mDNS**: Local network service discovery
3. **DHT**: Distributed hash table (global)
4. **Registry**: Central registry (if available)

**Usage Example**:
```rust
let adapter = UniversalAdapter::new().await?;

// Discover ALL providers of "security" capability
let providers = adapter.discover_capability("security").await?;
// Returns: Vec<DiscoveredProvider> (could be BearDog, or something else!)

for provider in providers {
    println!("Found: {} at {}", provider.provider_id, provider.endpoint);
}

// Call provider's API (adapter handles protocol translation)
let response = adapter.call(&provider, "identity", json!({})).await?;
```

**Key Features**:
- NO hardcoded primal names
- NO hardcoded endpoints
- Caching (5-minute TTL)
- Protocol translation (HTTP/tarpc/gRPC)
- Multiple providers per capability

---

## 🔄 In Progress (Current Work)

### 4. Compilation Error Fixes

**Status**: 70% complete

**Files Updated**:
- ✅ `crates/songbird-orchestrator/src/lib.rs` - Module exports
- ✅ `crates/songbird-genesis/src/lib.rs` - Renamed security client
- ✅ `crates/songbird-genesis/src/security_capability_client.rs` - Provider-agnostic
- ✅ `crates/songbird-genesis/src/ceremony.rs` - Updated imports
- ✅ `crates/songbird-genesis/src/witness.rs` - Updated imports
- ✅ `crates/songbird-genesis/src/identity.rs` - Updated imports
- 🔄 `crates/songbird-orchestrator/src/trust/lineage_auth.rs` - Needs methods
- 🔄 `crates/songbird-orchestrator/src/trust/escalation.rs` - Import fixes

**Remaining Errors** (10 errors):
1. `SecurityCapabilityClient` missing methods:
   - `get_current_lineage()` - Query our genetic lineage
   - `verify_lineage(proof)` - Verify peer's lineage proof
   - `same_family(a, b)` - Check if two lineages match
   
2. Import issues in `escalation.rs` and `lineage_auth.rs`

3. `Instant: Default` trait bound issue (minor)

---

## 📋 Next Steps (40 minutes remaining)

### Step 1: Add Missing Methods to `SecurityCapabilityClient` (15 min)

Add to `crates/songbird-orchestrator/src/security_capability_client.rs`:

```rust
/// Get our current genetic lineage
pub async fn get_current_lineage(&self) -> Result<Option<CurrentLineageInfo>> {
    let url = format!("{}/api/v1/lineage/current", self.endpoint);
    // Query security provider for our lineage
    // ...
}

/// Verify a peer's lineage proof
pub async fn verify_lineage(&self, proof: &LineageProof) -> Result<VerificationResult> {
    let url = format!("{}/api/v1/lineage/verify", self.endpoint);
    // POST lineage proof to security provider
    // ...
}

/// Check if two lineages are from same genetic family
pub async fn same_family(&self, a: &LineageId, b: &LineageId) -> Result<bool> {
    let url = format!("{}/api/v1/lineage/same_family", self.endpoint);
    // POST both lineage IDs
    // ...
}
```

### Step 2: Fix Remaining Compilation Errors (10 min)

- Fix `Instant: Default` issue in `escalation.rs`
- Verify all imports resolve correctly
- Run `cargo build --all-features`

### Step 3: Run Test Suite (10 min)

```bash
cargo test --all-features
cargo clippy --all-features -- -D warnings
```

### Step 4: Update Documentation (5 min)

- Update `README.md` with zero hardcoding achievement
- Update `STATUS.md` with Phase 1 completion
- Create handoff blurb for biomeOS team

---

## 🎯 Phase 2: Port & Numeric Hardcoding (Next Session)

**Remaining Hardcoding**:
1. **Ports**: `localhost:9000`, `:8080`, etc.
2. **IP Addresses**: `192.168.1.x`, `127.0.0.1`
3. **Protocol Defaults**: `http://` assumptions
4. **Timeouts**: Hardcoded durations
5. **Buffer Sizes**: Magic numbers

**Strategy**:
- All from environment variables
- Intelligent defaults (port 0 = auto-select)
- Configuration files (optional)
- Runtime negotiation

---

## 📊 Impact Assessment

### Before Zero Hardcoding:
```rust
// Songbird KNOWS about BearDog
let beardog = BearDogClient::new("http://localhost:9000");
let response = beardog.encrypt(data).await?;

// Hard to swap providers!
// Hard to test!
// Tight coupling!
```

### After Zero Hardcoding:
```rust
// Songbird discovers "security" capability
let adapter = UniversalAdapter::new().await?;
let providers = adapter.discover_capability("security").await?;
let provider = providers.first().unwrap(); // Could be BearDog, or anything!

let response = adapter.call(&provider, "encrypt", json!({ "data": data })).await?;

// Easy to swap providers!
// Easy to test (mock providers)!
// Loose coupling!
```

### Benefits:
1. **Flexibility**: Work with ANY security provider
2. **Testability**: Mock providers in tests
3. **Scalability**: Multiple providers simultaneously
4. **Resilience**: Failover if one provider unavailable
5. **Evolution**: Add new primals without code changes

---

## 🔥 Key Architectural Principles

1. **Self-Knowledge Only**: `self_knowledge.rs` contains ONLY what we know about ourselves
2. **Capability-Based**: Discover by CAPABILITY ("security"), not NAME ("beardog")
3. **Runtime Discovery**: NO compile-time knowledge of other primals
4. **Protocol-Agnostic**: `UniversalAdapter` handles HTTP/tarpc/gRPC translation
5. **Environment-Driven**: All config from env vars (12-factor app)
6. **Infant Model**: "Starts with 0 knowledge, discovers like an infant"

---

## 📝 Files Created/Modified

### Created:
1. `crates/songbird-orchestrator/src/security_capability_client.rs` (467 lines)
2. `crates/songbird-orchestrator/src/self_knowledge.rs` (340 lines)
3. `crates/songbird-orchestrator/src/universal_adapter.rs` (380 lines)
4. `ZERO_HARDCODING_MIGRATION.md` (migration plan)
5. `ZERO_HARDCODING_PHASE_1_STATUS.md` (this file)

### Modified:
1. `crates/songbird-orchestrator/src/lib.rs` - Module exports
2. `crates/songbird-genesis/src/lib.rs` - Renamed client
3. `crates/songbird-genesis/src/security_capability_client.rs` - Provider-agnostic
4. `crates/songbird-genesis/src/ceremony.rs` - Updated imports
5. `crates/songbird-genesis/src/witness.rs` - Updated imports
6. `crates/songbird-genesis/src/identity.rs` - Updated imports
7. `crates/songbird-orchestrator/src/trust/lineage_auth.rs` - In progress
8. `crates/songbird-orchestrator/src/trust/escalation.rs` - In progress

---

## 🚀 Ready for Completion

**Estimated Time to Complete**: 40 minutes

**Blocker Status**: NONE - All design decisions made, just execution remaining

**Test Strategy**: 
- Unit tests for new modules
- Integration tests with mock providers
- Backward compatibility tests

**Deployment Plan**:
- Gradual migration (deprecated aliases)
- Environment variable documentation
- Migration guide for users

---

**Last Updated**: 2026-01-01 (Session in progress)  
**Next Session**: Continue with method implementations and testing

