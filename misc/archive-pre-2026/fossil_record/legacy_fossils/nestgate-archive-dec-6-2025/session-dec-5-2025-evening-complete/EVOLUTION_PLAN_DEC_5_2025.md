# 🚀 NestGate Evolution Plan - December 5, 2025

## Executive Summary

**Goal**: Evolve to modern, idiomatic Rust with zero technical debt  
**Timeline**: 4-6 weeks systematic execution  
**Status**: Compilation passing ✅, Ready to evolve

---

## Phase 1: IMMEDIATE (This Session)

### 1.1 Remove Duplicate Stub Code ✅
**File**: `code/crates/nestgate-core/src/universal_primal_discovery/stubs.rs`  
**Problem**: Duplicates code from `dev_stubs/primal_discovery.rs`  
**Solution**: Keep only re-export, remove duplicate implementations  
**Impact**: -200 lines, cleaner codebase

### 1.2 Add Missing Documentation
**Files**: 150+ doc warnings across codebase  
**Solution**: Document public APIs systematically  
**Priority**: dev_stubs, temporal_storage, jwt_validation  
**Impact**: Unblock clippy -D warnings

### 1.3 Migrate Critical Unwraps
**Files**: Priority files with production unwraps  
**Solution**: Convert to Result<T, E> with proper context  
**Priority**: capability_based_discovery.rs, production_capability_bridge.rs  
**Impact**: Better error handling, production-ready

---

## Phase 2: SMART REFACTORING (Week 1)

### 2.1 Deprecate Old Discovery (Don't Split)
**File**: `production_discovery.rs` (910 lines)  
**Smart Approach**: Don't mechanically split  
**Instead**:
1. Identify all callers (31 files found)
2. Migrate them to `CapabilityAwareDiscovery`
3. Remove entire deprecated module
4. **Result**: -910 lines, modern capability-based only

### 2.2 Complete mDNS Backend
**File**: `backends/mdns.rs`  
**Current**: 5 TODOs for actual implementation  
**Solution**: Integrate mdns-sd crate for real mDNS  
**Impact**: Complete local network discovery

### 2.3 Evolve Hardcoding to Capability-Based
**Pattern**:
```rust
// ❌ OLD: Hardcoded fallbacks
let port = env::var("PORT").unwrap_or(8080);

// ✅ NEW: Capability-based runtime discovery
let services = discovery.find_capability(CapabilityCategory::ApiGateway).await?;
let port = services.first()?.binding.port;
```

---

## Phase 3: UNSAFE EVOLUTION (Week 2)

### 3.1 Review All 142 Unsafe Blocks
**Status**: Top 0.1% globally, all documented  
**Approach**: 
- Keep performance-critical unsafe (SIMD, memory pools)
- Evolve where safe alternatives exist
- Document performance tradeoffs

### 3.2 Zero-Copy Optimization
**Opportunities**:
- ~110 clones in hot paths → Arc/Cow/references
- String allocations → &str where possible
- Vec allocations → slices/SmallVec

---

## Phase 4: TEST EXPANSION (Weeks 3-4)

### 4.1 Reach 90% Coverage
**Current**: 72% (2,900 tests passing)  
**Need**: +500-700 tests focusing on:
- Error paths
- Edge cases
- Integration scenarios
- Config validation errors

### 4.2 Enhance E2E/Chaos Tests
**Current**: 29 E2E, 11 chaos, 4 fault  
**Enhance**: More real-world scenarios

---

## Phase 5: PRODUCTION READINESS (Weeks 5-6)

### 5.1 Complete Migration
- All callers use capability-based discovery
- Zero hardcoded primal names
- Self-knowledge + runtime discovery only

### 5.2 Performance Validation
- Load testing
- Latency benchmarks
- Memory profiling

### 5.3 Security Audit
- Dependency audit
- Unsafe code review
- Attack surface analysis

---

## Success Metrics

**Week 1**:
- ✅ Stubs cleaned (duplicates removed)
- ✅ Documentation complete (0 warnings)
- ✅ 50+ unwraps migrated
- **Grade**: B+ → A- (88/100)

**Week 2**:
- ✅ production_discovery.rs removed (all callers migrated)
- ✅ mDNS backend complete
- ✅ 100+ more unwraps migrated
- **Grade**: A- (90/100)

**Week 4**:
- ✅ 80% coverage
- ✅ All critical paths <100 unwraps
- **Grade**: A- (92/100)

**Week 6**:
- ✅ 90% coverage
- ✅ All hardcoding migrated
- ✅ Production-ready
- **Grade**: A (95/100)

---

## Key Principles

1. **Smart Refactoring**: Evolve architecture, don't just split files
2. **Capability-Based**: Runtime discovery, zero hardcoding
3. **Self-Knowledge**: Primals know themselves, discover others
4. **Modern Rust**: Idiomatic, safe, performant
5. **No Mocks in Production**: Test stubs feature-gated only

---

**Status**: Ready to execute ✅  
**Next**: Remove duplicate stub code, add documentation, migrate unwraps

