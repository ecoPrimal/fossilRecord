# 🎭 Mock Audit - Categorized and Prioritized
## November 6, 2025

**Purpose**: Systematic categorization of all mocks for elimination  
**Approach**: DELETE other-primal mocks, IMPLEMENT NestGate domain mocks

---

## 📊 SUMMARY

| Category | Files | Status | Action |
|----------|-------|--------|--------|
| **Category A: NestGate Domain** | 15 files | IMPLEMENT REAL | High Priority |
| **Category B: Other Primals** | 30 files | DELETE | High Priority |
| **Category C: Test Helpers** | 10 files | KEEP (feature-gated) | Low Priority |
| **TOTAL** | 55 files | | |

---

## ❌ CATEGORY B: DELETE - Other Primal Mocks

### **Load Balancing Module** - 🔴 DELETE ALL (Belongs to Songbird)

**Status**: All stub implementations with no real logic  
**Action**: DELETE entire module, use capability discovery

**Files to DELETE** (12 files):
```
code/crates/nestgate-core/src/load_balancing/
├── algorithms.rs          - Stub implementation
├── balancer.rs            - Stub implementation  
├── backends.rs            - Stub implementation
├── circuit_breaker.rs     - Stub implementation
├── health.rs              - Stub implementation
├── metrics.rs             - Stub implementation
├── session.rs             - Stub implementation
├── traffic.rs             - Stub implementation
├── config.rs              - Keep trait definitions
├── error.rs               - Keep error types
├── traits.rs              - Keep trait definitions
└── types.rs               - Keep data structures
```

**Keep Minimal**:
- `config.rs` - Configuration types
- `error.rs` - Error definitions
- `traits.rs` - Trait definitions for capability discovery
- `types.rs` - Data structures

**Delete 8 stub files**, keep 4 definition files

---

### **Orchestration Module** - 🔴 DELETE ALL (Belongs to Songbird)

**Status**: All stub implementations with "IMPLEMENTATION STUB" comments  
**Action**: DELETE entire module, use capability discovery

**Files to DELETE** (2 files):
```
code/crates/nestgate-core/src/orchestration/
├── production_orchestrator.rs  - Stub implementation (DELETE)
└── mod.rs                      - Stub implementation (DELETE)
```

**Replacement**:
```rust
// Use capability discovery instead
pub async fn get_orchestrator() -> Result<Box<dyn OrchestrationProvider>> {
    discover_capability(CapabilityType::Orchestration).await
}
```

---

### **Capability Stubs** - ✅ ALREADY CLEANED!

**Status**: These have ALREADY been cleaned up with good documentation!  
**Action**: VERIFY and confirm completion

**Files ALREADY cleaned** (4 files):
```
code/crates/nestgate-core/src/ecosystem_integration/capabilities/
├── compute.rs         - ✅ Clean! Has migration guide
├── intelligence.rs    - ✅ Clean! Has migration guide  
├── security.rs        - ✅ Clean! Has migration guide
└── orchestration.rs   - ✅ Clean! Has migration guide
```

**Example of good cleanup**:
```rust
//! Compute Capabilities - Real Implementation via Capability Discovery
//!
//! **REMOVED MOCKS**: This module previously contained MockComputeCapability.
//! **MODERN SOLUTION**: Use `universal_adapter::CapabilityDiscovery` instead.
```

---

### **Security Provider Mocks** - 🔴 DELETE (Belongs to BearDog)

**Files to REVIEW and SIMPLIFY**:
```
code/crates/nestgate-core/src/zero_cost_security_provider/
├── traits.rs              - Has 7 mock instances (CLEAN)
├── types.rs               - Keep type definitions  
├── config.rs              - Keep config types
├── authentication.rs      - Keep trait definitions
└── production.rs          - Review for stubs
```

**Action**: Remove mock implementations, keep trait definitions

---

### **Network Mocks** - ⚠️ REVIEW (Some belong to other primals)

**Files to REVIEW**:
```
code/crates/nestgate-core/src/network/
├── auth.rs                - Belongs to BearDog (DELETE or delegate)
├── tls.rs                 - Belongs to BearDog (DELETE or delegate)
├── cache.rs               - Cache belongs to us (IMPLEMENT)
├── circuit_breaker.rs     - Belongs to Songbird (DELETE)
├── middleware.rs          - Review ownership
├── compression.rs         - Keep if for storage
├── connection.rs          - Keep (our network client)
├── pool.rs                - Keep (our connection pooling)
└── retry.rs               - Keep (our retry logic)
```

---

## ✅ CATEGORY A: IMPLEMENT REAL - NestGate Domain

### **ZFS Operations** - 🔴 HIGH PRIORITY

**File**: `code/crates/nestgate-core/src/zero_cost/zfs_operations.rs`  
**Status**: 15 mock instances  
**Action**: Replace with nestgate-zfs crate integration

**Current Mock Pattern**:
```rust
pub struct MockZfsOperations {
    // Fake implementations
}
```

**Target Implementation**:
```rust
use nestgate_zfs::{ZfsManager, Dataset, Pool};

pub struct RealZfsOperations {
    manager: Arc<ZfsManager>,
}

impl RealZfsOperations {
    pub async fn create_dataset(&self, name: &str) -> Result<Dataset> {
        self.manager.create_dataset(name).await
    }
    // Real implementations...
}
```

---

### **Health Checks** - 🔴 HIGH PRIORITY

**File**: `code/crates/nestgate-core/src/observability/health_checks.rs`  
**Status**: 5 mock instances  
**Action**: Implement real system health monitoring

**Current Mock Pattern**:
```rust
pub async fn check_health(&self) -> HealthStatus {
    HealthStatus::Healthy // Always returns healthy
}
```

**Target Implementation**:
```rust
pub async fn check_health(&self) -> Result<HealthStatus> {
    let mut checks = Vec::new();
    checks.push(self.check_memory_usage().await?);
    checks.push(self.check_disk_space().await?);
    checks.push(self.check_zfs_pools().await?);
    Ok(HealthStatus::from_checks(checks))
}
```

**Dependencies**: Add `sysinfo` crate for real metrics

---

### **Cache Consistency** - 🔴 HIGH PRIORITY

**File**: `code/crates/nestgate-core/src/cache/consistency.rs`  
**Status**: Mock (10% real)  
**Action**: Implement real cache invalidation

---

### **Storage Backends** - ⚠️ HIGH PRIORITY

**Files with mocks/stubs**:
```
code/crates/nestgate-core/src/universal_storage/
├── backends/block_storage.rs      - Stub (IMPLEMENT or DELETE)
├── backends/network_fs.rs         - Stub (IMPLEMENT or DELETE)
├── backends/object_storage.rs     - Stub (IMPLEMENT or DELETE)
├── storage_detector/profiling.rs  - Stub (IMPLEMENT)
├── storage_detector/analysis.rs   - Stub (IMPLEMENT)
├── sync.rs                        - Review
├── manager.rs                     - Review
├── events.rs                      - Review
└── replication.rs                 - Stub (IMPLEMENT or DELETE)
```

**Decision Matrix**:
- **Filesystem storage**: IMPLEMENT (our domain)
- **ZFS storage**: IMPLEMENT (our domain)
- **Block storage**: DELETE (not our domain)
- **Object storage**: DELETE (not our domain, use capability discovery)
- **Network FS**: DELETE (not our domain)

---

### **Response Builders** - ⚠️ MEDIUM PRIORITY

**File**: `code/crates/nestgate-core/src/response/mod.rs`  
**Status**: 3 mock instances  
**Action**: Implement real response builders or simplify

---

### **ZFS Features** - ⚠️ REVIEW

**Files with stubs**:
```
code/crates/nestgate-core/src/universal_storage/zfs_features/
├── compression_engine.rs      - Review for mocks
├── deduplication_manager.rs   - Review for mocks
└── integrity_manager.rs       - Review for mocks
```

**Action**: These might be wrappers around nestgate-zfs, verify if needed

---

## 🔧 CATEGORY C: KEEP - Test Helpers (Feature-Gated)

### **Test Helpers** - ✅ KEEP (properly gated)

**Files to VERIFY feature-gating**:
```
code/crates/nestgate-core/src/
├── return_builders/mock_builders.rs   - #[cfg(test)] (VERIFY)
├── smart_abstractions/test_factory.rs - Test helpers (VERIFY)
├── universal_primal_discovery/stubs.rs - Fallback stubs (REVIEW)
└── config/canonical_master/domains/test_canonical/mocking.rs - Test config (VERIFY)
```

**Action**: Ensure all have `#[cfg(test)]` or `#[cfg(feature = "dev-stubs")]`

---

### **Service Pattern Mocks** - ⚠️ MIXED

**File**: `code/crates/nestgate-core/src/smart_abstractions/service_patterns.rs`  
**Status**: 17 mock instances, MIXED production + test code  
**Action**: SPLIT into separate files

**Split**:
- `service_patterns.rs` - Production code only
- `service_patterns_mocks.rs` - Test helpers with `#[cfg(test)]`

**Current Issue**: `MockSmartService` is under `#[cfg(test)]` ✅ (Good!)  
But need to verify no production code uses it.

---

## 📋 EXECUTION ORDER

### **Week 1: Delete Other-Primal Mocks** (Days 1-5)

**Day 1: Load Balancing**
- [ ] Delete 8 stub files from load_balancing/
- [ ] Keep 4 definition files (config, error, traits, types)
- [ ] Update imports in any dependent code
- [ ] Add capability discovery examples

**Day 2: Orchestration**
- [ ] Delete orchestration/production_orchestrator.rs
- [ ] Delete orchestration/mod.rs
- [ ] Update imports
- [ ] Add capability discovery examples

**Day 3: Network Auth/TLS**
- [ ] Review network/auth.rs - delete or simplify
- [ ] Review network/tls.rs - delete or simplify
- [ ] Review network/circuit_breaker.rs - delete (Songbird)

**Day 4: Storage Backend Stubs**
- [ ] Delete backends/block_storage.rs
- [ ] Delete backends/object_storage.rs
- [ ] Delete backends/network_fs.rs (or delegate)

**Day 5: Security Provider Cleanup**
- [ ] Clean zero_cost_security_provider/traits.rs
- [ ] Remove mock implementations
- [ ] Keep trait definitions

---

### **Week 2: Implement NestGate Domain** (Days 6-12)

**Days 6-8: ZFS Operations**
- [ ] Replace zero_cost/zfs_operations.rs with real implementation
- [ ] Use nestgate-zfs crate
- [ ] Write tests

**Days 9-10: Health Checks**
- [ ] Replace observability/health_checks.rs with real implementation
- [ ] Add sysinfo dependency
- [ ] Write tests

**Days 11-12: Cache Consistency**
- [ ] Implement real cache invalidation
- [ ] Version tracking
- [ ] Write tests

---

## 🎯 SUCCESS METRICS

### After Week 1 (Deletions):
- [ ] ✅ 0 load balancing stubs
- [ ] ✅ 0 orchestration stubs
- [ ] ✅ 0 other-primal mocks in production
- [ ] ✅ All capability discovery documented

### After Week 2 (Implementations):
- [ ] ✅ Real ZFS operations working
- [ ] ✅ Real health checks working
- [ ] ✅ Real cache consistency working
- [ ] ✅ Test coverage for new implementations

### Overall Target:
- [ ] ✅ ZERO production mocks
- [ ] ✅ ZERO other-primal stubs
- [ ] ✅ All test helpers feature-gated
- [ ] ✅ Modern idiomatic Rust patterns

---

**Status**: 📋 READY FOR EXECUTION  
**Next Action**: Start deleting load_balancing stubs  
**Timeline**: 2 weeks to eliminate all mocks

---

## 🔍 VERIFICATION COMMANDS

```bash
# Find remaining mocks after cleanup
rg "Mock|mock_|Stub|stub_" code/crates/nestgate-core/src --type rust | grep -v "#\[cfg(test)\]" | grep -v "//!"

# Find TODO/FIXME in production
rg "TODO|FIXME" code/crates/*/src --type rust

# Verify no other-primal names
rg -i "songbird|beardog|squirrel|toadstool" code/crates/*/src --type rust

# Check test feature-gating
rg "Mock.*Service" code/crates/*/src --type rust -A 1 | grep -v "#\[cfg(test)\]"
```

---

**Created**: November 6, 2025  
**Status**: 🎯 READY TO EXECUTE  
**Priority**: CRITICAL

