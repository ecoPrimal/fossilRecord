# 🎯 Mock Elimination Strategy - Systematic Approach

**Created**: November 5, 2025  
**Goal**: Eliminate 885 mock implementations, replace with real code or proper test helpers  
**Timeline**: 80-160 hours estimated

---

## 📊 ANALYSIS COMPLETE

### Mock Files Identified (16 in nestgate-core/src):

#### ✅ KEEP (Legitimate Test Helpers):
1. **`return_builders/mock_builders.rs`** 
   - Status: ✅ LEGITIMATE - Test/dev helpers
   - Action: Ensure `#[cfg(feature = "dev-stubs")]` throughout
   - Lines: 131 lines
   - Purpose: Build mock return types for tests

2. **`config/canonical_master/domains/test_canonical/mocking.rs`**
   - Status: ✅ LEGITIMATE - Test configuration mocks
   - Action: Ensure properly feature-gated
   - Purpose: Test-specific configuration mocking

3. **`smart_abstractions/test_factory.rs`**
   - Status: ✅ LEGITIMATE - Test factory patterns
   - Action: Keep, document as test-only

#### ⚠️ REFACTOR (Mixed Production/Mock):
4. **`smart_abstractions/service_patterns.rs`** ⚠️ CRITICAL
   - Status: ⚠️ MIXED - Has real code + mock patterns
   - Lines: 763 lines
   - Issue: `create_mock_service()` not feature-gated (line 85-100)
   - Action: 
     * Keep `SmartServiceFactory` (real code)
     * Feature-gate or remove `create_mock_service`
     * Keep `MockServiceBehavior` under #[cfg(test)]

5. **`universal_traits/security.rs`**
   - Status: ⚠️ MIXED - Has deprecated mock provider
   - Action: Already deprecated, tests properly gated
   - Keep for backwards compatibility

#### 🔴 ELIMINATE OR IMPLEMENT (Stubs Needing Real Implementation):
6. **`ecosystem_integration/capabilities/compute.rs`**
   - Status: 🔴 STUB - Mock compute capability provider
   - Action: Implement real capability detection or remove

7. **`ecosystem_integration/capabilities/intelligence.rs`**
   - Status: 🔴 STUB - Mock intelligence capability provider
   - Action: Implement real primal discovery or remove

8. **`ecosystem_integration/capabilities/security.rs`**
   - Status: 🔴 STUB - Mock security capability provider
   - Action: Implement real security discovery or remove

9. **`ecosystem_integration/capabilities/orchestration.rs`**
   - Status: 🔴 STUB - Mock orchestration capability provider
   - Action: Implement real orchestration or remove

10. **`observability/health_checks.rs`**
    - Status: 🔴 STUB - Mock health check system
    - Action: Implement real health checks

11. **`zero_cost/zfs_operations.rs`**
    - Status: 🔴 STUB - Mock ZFS operations
    - Action: Use real nestgate-zfs crate

12. **`zero_cost_security_provider/traits.rs`**
    - Status: 🔴 STUB - Mock security provider
    - Action: Connect to real BearDog or implement

13. **`response/mod.rs`**
    - Status: 🔴 STUB - Mock response builders
    - Action: Implement real response handling

#### 📝 TEST FILES (Keep):
14. **`traits/traits_tests.rs`** - ✅ Test file
15. **`traits/canonical_hierarchy_tests.rs`** - ✅ Test file
16. **`unified_benchmark_config.rs`** - ✅ Benchmark helpers

---

## 🎯 PRIORITY ACTIONS

### Phase 1: Quick Wins (4-8 hours)

**1. Feature-Gate Test Helpers**
```bash
# Ensure all test helpers are properly gated
- mock_builders.rs: Add #[cfg(any(test, feature = "dev-stubs"))]
- test_factory.rs: Verify #[cfg(test)]
- test_canonical/mocking.rs: Verify feature gating
```

**2. Separate Mixed Code**
```rust
// service_patterns.rs - Split into:
// - service_patterns.rs (production)
// - service_patterns_mocks.rs (test helpers under #[cfg(test)])
```

**3. Document Stub Status**
```rust
// Add clear deprecation/stub markers
#[deprecated(
    since = "0.2.0",
    note = "Stub implementation - use real primal discovery"
)]
pub struct MockComputeProvider { ... }
```

---

### Phase 2: Eliminate Capability Stubs (16-24 hours)

**ecosystem_integration/capabilities/** - 4 files

#### Option A: Remove (if not used in production)
```bash
# Check usage
rg "MockComputeProvider|ComputeCapabilityMock" --type rust

# If not used, delete
rm code/crates/nestgate-core/src/ecosystem_integration/capabilities/compute.rs
```

#### Option B: Implement Real (if needed)
```rust
// Replace with infant discovery pattern
pub struct RealComputeCapabilityProvider {
    discovery_client: InfantDiscoveryClient,
}

impl RealComputeCapabilityProvider {
    pub async fn discover_compute_primals(&self) -> Result<Vec<ComputePrimal>> {
        self.discovery_client
            .discover_by_capability(CapabilityType::Compute)
            .await
    }
}
```

---

### Phase 3: Implement Real Health Checks (8-12 hours)

**observability/health_checks.rs**

```rust
// BEFORE (Mock)
pub async fn check_health(&self) -> HealthStatus {
    HealthStatus::Healthy // Always returns healthy
}

// AFTER (Real)
pub async fn check_health(&self) -> Result<HealthStatus> {
    let mut checks = vec![];
    
    // Real checks
    checks.push(self.check_memory().await?);
    checks.push(self.check_disk().await?);
    checks.push(self.check_network().await?);
    checks.push(self.check_dependencies().await?);
    
    Ok(HealthStatus::from_checks(checks))
}
```

---

### Phase 4: Replace ZFS Stubs (12-16 hours)

**zero_cost/zfs_operations.rs**

```rust
// BEFORE (Mock)
pub struct MockZfsOperations { ... }

// AFTER (Real)
use nestgate_zfs::{ZfsDatasetManager, ZfsPoolManager};

pub struct RealZfsOperations {
    dataset_manager: Arc<ZfsDatasetManager>,
    pool_manager: Arc<ZfsPoolManager>,
}
```

---

### Phase 5: Connect Real Security (16-20 hours)

**zero_cost_security_provider/traits.rs**

```rust
// BEFORE (Mock)
pub struct MockSecurityProvider { ... }

// AFTER (Real - with BearDog integration)
pub struct RealSecurityProvider {
    beardog_client: Option<Arc<BearDogClient>>,
    fallback: LocalSecurityProvider,
}

impl RealSecurityProvider {
    pub async fn encrypt(&self, data: &[u8]) -> Result<Vec<u8>> {
        if let Some(beardog) = &self.beardog_client {
            beardog.encrypt(data).await
        } else {
            self.fallback.encrypt(data).await
        }
    }
}
```

---

## 📋 DETAILED FILE-BY-FILE PLAN

### File: `smart_abstractions/service_patterns.rs` (PRIORITY 1)

**Current State**: 763 lines, mixed production + mock code

**Actions**:
1. Extract lines 85-100 `create_mock_service()` to separate file
2. Create `service_patterns_test_helpers.rs` with #[cfg(test)]
3. Keep real `SmartServiceFactory` in service_patterns.rs
4. Update imports in test files

**Estimated Time**: 2-3 hours

---

### File: `ecosystem_integration/capabilities/*.rs` (PRIORITY 2)

**Files**: compute.rs, intelligence.rs, security.rs, orchestration.rs

**Decision Matrix**:
```
Used in Production? → Implement Real
Not Used? → Delete
Used Only in Tests? → Move to test helpers
```

**Estimated Time**: 12-16 hours total (4 files @ 3-4 hours each)

---

### File: `observability/health_checks.rs` (PRIORITY 3)

**Current**: Mock health checks always return "Healthy"

**Implement**:
- Real memory usage checks
- Real disk space checks
- Real network connectivity checks
- Real service dependency checks

**Estimated Time**: 8-12 hours

---

### File: `zero_cost/zfs_operations.rs` (PRIORITY 4)

**Current**: Mock ZFS operations

**Implement**: Wire to real nestgate-zfs crate

**Estimated Time**: 12-16 hours

---

### File: `zero_cost_security_provider/traits.rs` (PRIORITY 5)

**Current**: Mock security provider

**Implement**: 
- BearDog integration (if available)
- Fallback to local crypto
- Real key management

**Estimated Time**: 16-20 hours

---

## 🔧 IMPLEMENTATION CHECKLIST

### Before Starting Each File:
- [ ] Check usage: `rg "FileName" --type rust`
- [ ] Identify dependencies
- [ ] Check if used in production vs tests
- [ ] Review existing tests
- [ ] Plan backwards compatibility

### During Implementation:
- [ ] Feature-gate old code with `#[deprecated]`
- [ ] Add new real implementation
- [ ] Update tests to use real implementation
- [ ] Document migration path
- [ ] Add integration tests

### After Completion:
- [ ] Run full test suite
- [ ] Update documentation
- [ ] Mark in MOCK_ELIMINATION_PROGRESS.md
- [ ] Measure coverage improvement

---

## 📊 PROGRESS TRACKING

### Completed: 0/16 files
### In Progress: 0/16 files  
### Remaining: 16/16 files

---

## 🎯 SUCCESS METRICS

### Phase 1 Complete When:
- [ ] All test helpers properly feature-gated
- [ ] service_patterns.rs split into prod + test
- [ ] All stubs documented with deprecation warnings

### Phase 2-5 Complete When:
- [ ] All capability stubs eliminated or implemented
- [ ] Real health checks working
- [ ] Real ZFS operations
- [ ] Real security provider
- [ ] 0 mock implementations in production paths

---

## ⚠️ RISKS & MITIGATION

### Risk: Breaking Existing Tests
**Mitigation**: 
- Keep deprecated code for one release cycle
- Provide migration guide
- Update tests incrementally

### Risk: Real Implementations Too Complex
**Mitigation**:
- Start with simple implementations
- Add features incrementally
- Keep fallback/stub mode for development

### Risk: External Dependencies Not Available
**Mitigation**:
- Graceful degradation (e.g., if BearDog not found, use local crypto)
- Feature flags for optional integrations
- Clear error messages when external deps needed

---

**Next Update**: After Phase 1 completion  
**Owner**: Development Team  
**Status**: 🚀 Ready to Execute

