# ✅ Songbird Action Items Checklist
**Date**: November 19, 2025  
**Priority**: Critical → High → Medium → Low  
**Estimated Total Time**: 200 hours (5-6 weeks)

---

## 🚨 P0: CRITICAL (Fix Today - 8-12 hours)

### [ ] 1. Fix Compilation Error (5 minutes)
**File**: `crates/songbird-orchestrator/src/app/mod.rs:240`  
**Error**: Missing field `node_id` in `FederationConfig`

```rust
// Fix: Add node_id field
let config = FederationConfig {
    node_id: self.node_id.clone(), // or appropriate source
    // ... existing fields
};
```

**Verification**: `cargo build --workspace`

---

### [ ] 2. Move Test Code to #[cfg(test)] (30 minutes)

Move these files' content to proper test modules:

```
[ ] crates/songbird-canonical/src/config/environment_tests.rs
[ ] crates/songbird-canonical/src/config/adapters_tests.rs  
[ ] crates/songbird-canonical/src/metadata_tests.rs
[ ] crates/songbird-universal/src/sovereignty/adapter_comprehensive_tests.rs
[ ] crates/songbird-universal/src/discovery_comprehensive_tests.rs
[ ] crates/songbird-universal/src/adapters/security_comprehensive_tests.rs
```

**Impact**: Fixes ~75 "production" unwraps automatically

**Verification**: `./check_production_unwraps.sh`

---

### [ ] 3. Eliminate Remaining Production Unwraps (4-6 hours)

**Priority Files**:

#### [ ] 3a. `crates/songbird-types/src/error_helpers.rs` (2 unwraps) - CRITICAL
```rust
// Replace .unwrap() with proper error handling
// Use ? operator or .ok_or_else()
```

#### [ ] 3b. `crates/songbird-orchestrator/src/server/protocol_api.rs` (1 unwrap)
```rust
// Replace with ? or expect() with clear message
```

#### [ ] 3c. `crates/songbird-config/src/canonical/testing.rs` (6 unwraps)
```rust
// Wrap in #[cfg(test)] or replace with proper error handling
```

**Verification**: 
```bash
./check_production_unwraps.sh
# Target: "Total true production unwraps: 0"
```

---

### [ ] 4. Implement Critical TODOs (4-6 hours)

#### [ ] 4a. Service Registration (tarpc_server.rs:200)
```rust
// TODO: Implement actual service registration
// Wire up to self.federated_service_registry
```

#### [ ] 4b. Service Discovery (tarpc_server.rs:217)
```rust
// TODO: Implement actual service discovery  
// Use self.federated_service_registry.list_services()
```

#### [ ] 4c. Registry Metrics (tarpc_server.rs:232-233)
```rust
total_services: self.federated_service_registry.service_count(),
total_peers: self.federation_state.peer_count(),
```

#### [ ] 4d. WebSocket Metrics (websocket_api.rs:302-304)
```rust
total_services: registry.service_count(),
uptime_seconds: start_time.elapsed().as_secs(),
```

#### [ ] 4e. JSON-RPC Uptime (jsonrpc_api.rs:372)
```rust
"uptime_seconds": self.start_time.elapsed().as_secs()
```

#### [ ] 4f. Testing.rs Update (canonical/mod.rs:20)
```rust
// TODO: Update testing.rs to match current canonical struct definitions
// Review and update all test utilities
```

**Verification**: 
```bash
grep -r "TODO" crates/*/src --include='*.rs' | wc -l
# Should decrease by ~7
```

---

### [ ] 5. Run Cargo Format (1 minute)
```bash
cargo fmt --all
```

**Verification**: `cargo fmt -- --check`

---

## 🔥 P1: HIGH (This Week - 40 hours)

### [ ] 6. Fix Clippy Warnings (~2 hours)

#### [ ] 6a. Add Missing Cargo Metadata (15 min)
Edit `Cargo.toml` for these crates:
- [ ] songbird-remote-deploy
- [ ] songbird-compute-bridge  
- [ ] songbird-canonical

Add:
```toml
[package]
license = "MIT OR Apache-2.0"
repository = "https://github.com/your-org/songbird"
readme = "README.md"
keywords = ["orchestration", "service-mesh", "distributed"]
categories = ["network-programming"]
```

#### [ ] 6b. Fix Deprecation Warnings (30 min)
```rust
// Replace deprecated imports:
use songbird_config::SongbirdConfig;
// With:
use songbird_types::config::CanonicalSongbirdConfig;

// Replace:
use unified::observability;
// With:
use canonical::observability;
```

#### [ ] 6c. Remove Dead Code (30 min)
In `songbird-remote-deploy/src/http_deploy.rs`:
- [ ] Remove unused structs or add `#[allow(dead_code)]` if intentional
- [ ] Remove unused fields or mark as `#[allow(dead_code)]`

#### [ ] 6d. Clean Up Unused Imports (15 min)
```bash
cargo clippy --workspace --fix --allow-dirty
```

**Verification**: 
```bash
cargo clippy --workspace --all-targets 2>&1 | grep "warning:" | wc -l
# Target: < 5 warnings
```

---

### [ ] 7. Security Adapter Test Coverage (1-2 days, ~100 tests)

**Current**: 14.71% ❌  
**Target**: 85%+ ✅

**Files to add tests for**:
- [ ] `crates/songbird-universal/src/adapters/security.rs`

**Test types needed**:
```rust
// [ ] Integration tests
#[tokio::test]
async fn test_security_adapter_authentication() { ... }

#[tokio::test]
async fn test_security_adapter_authorization() { ... }

#[tokio::test]  
async fn test_security_adapter_encryption() { ... }

// [ ] Error path tests
#[tokio::test]
async fn test_security_adapter_invalid_credentials() { ... }

#[tokio::test]
async fn test_security_adapter_expired_token() { ... }

// [ ] Edge case tests
#[tokio::test]
async fn test_security_adapter_concurrent_requests() { ... }
```

**New test file**: `crates/songbird-universal/tests/security_adapter_comprehensive_integration_tests.rs`

**Verification**:
```bash
cargo llvm-cov --workspace --lib | grep "security.rs"
# Target: > 85% coverage
```

---

### [ ] 8. Compute/AI/Storage Adapter Tests (2-3 days, ~200 tests)

#### [ ] 8a. Compute Adapter (60.13% → 85%)
- [ ] Add 40-50 integration tests
- [ ] Test async operations
- [ ] Test error handling
- [ ] Test timeout scenarios

#### [ ] 8b. AI Adapter (64.62% → 85%)  
- [ ] Add 40-50 integration tests
- [ ] Test model inference
- [ ] Test batching
- [ ] Test error recovery

#### [ ] 8c. Storage Adapter (66.50% → 85%)
- [ ] Add 40-50 integration tests
- [ ] Test CRUD operations
- [ ] Test concurrent access
- [ ] Test data consistency

**Verification**:
```bash
cargo llvm-cov --workspace --lib --summary-only
# Target: Overall > 75%
```

---

### [ ] 9. Split Large Test File (1-2 hours)

**File**: `crates/songbird-universal/tests/unified_adapter_core_tests.rs` (1,231 lines)

Split into:
- [ ] `unified_adapter_creation_tests.rs` (~400 lines)
- [ ] `unified_adapter_config_tests.rs` (~400 lines)  
- [ ] `unified_adapter_lifecycle_tests.rs` (~400 lines)

**Verification**:
```bash
wc -l crates/songbird-universal/tests/unified_adapter_*.rs
# All should be < 1000 lines
```

---

## 🟡 P2: MEDIUM (Weeks 2-4 - 80 hours)

### [ ] 10. Expand Overall Test Coverage (2-3 weeks)

**Current**: 55.96%  
**Target**: 85-90%

**Focus areas**:
- [ ] `songbird-universal/src/capabilities/adapter.rs` (68.35% → 85%)
- [ ] `songbird-universal/src/discovery.rs` (70.81% → 85%)
- [ ] Edge cases across all modules
- [ ] Error path testing

**Estimated new tests**: 300-400 tests

**Verification**:
```bash
cargo llvm-cov --workspace --lib --summary-only
# Target: > 85% overall coverage
```

---

### [ ] 11. Expand E2E Test Scenarios (1 week)

**Current**: 9 E2E test files  
**Target**: 15-20 comprehensive scenarios

Add tests for:
- [ ] Full service lifecycle (register → discover → use → deregister)
- [ ] Multi-primal coordination (Songbird + Toadstool + Squirrel)
- [ ] Federation scenarios (multi-node coordination)
- [ ] Failure recovery (node crashes, network partitions)
- [ ] Load balancing strategies (all 9 strategies)
- [ ] Circuit breaker scenarios (failure → open → half-open → closed)

**Verification**:
```bash
cargo test --test e2e_* --workspace
# All tests should pass
```

---

### [ ] 12. Expand Chaos Testing (1 week)

**Current**: 24 chaos/fault test files  
**Target**: 40-50 comprehensive chaos scenarios

Add tests for:
- [ ] Network chaos (latency, packet loss, partitions)
- [ ] Resource chaos (CPU spike, memory pressure, disk full)
- [ ] Service chaos (random crashes, slow responses)
- [ ] State chaos (corrupted data, inconsistent state)
- [ ] Time chaos (clock skew, time jumps)

**Verification**:
```bash
cargo test --test chaos_* --workspace
cargo test --test fault_* --workspace
```

---

### [ ] 13. Review Hardcoded Values (2-4 hours)

**Current**: 1,958 instances (mostly in tests)

Audit production source files:
- [ ] `crates/songbird-orchestrator/src/**/*.rs`
- [ ] `crates/songbird-universal/src/**/*.rs`
- [ ] `crates/songbird-config/src/**/*.rs`

Ensure all use:
```rust
// ✅ Good:
SafeEnv::get_or_default("SONGBIRD_PORT", defaults::ports::orchestrator_port())

// ❌ Bad:
let port = 8080; // Hardcoded
```

**Verification**:
```bash
grep -r "8080\|3000\|5000\|localhost" crates/*/src --include='*.rs' | wc -l
# Should be minimal (< 20 in production code)
```

---

### [ ] 14. Fix Documentation Warnings (1-2 hours)

#### [ ] 14a. Fix HTML Tags
```rust
// Replace:
/// Returns the <Enum> value
// With:
/// Returns the `Enum` value

// Replace:
/// <DiscoveryMethod>
// With:
/// `DiscoveryMethod`

// Replace:  
/// <dyn Trait>
// With:
/// `dyn Trait`
```

#### [ ] 14b. Add Error Documentation
```rust
/// # Errors
///
/// Returns `SongbirdError::Configuration` if...
/// Returns `SongbirdError::Network` if...
pub async fn some_function() -> Result<T, SongbirdError> { ... }
```

#### [ ] 14c. Fix Unresolved Links
```rust
// Replace :: with proper links
/// See also: [`SomeType`]
```

**Verification**:
```bash
cargo doc --workspace --no-deps 2>&1 | grep "warning:" | wc -l
# Target: < 5 warnings
```

---

### [ ] 15. Review Clone Usage (4-8 hours)

**Current**: 1,586 `.clone()` calls

Profile and optimize:
```bash
# [ ] 1. Profile hot paths
cargo build --release --workspace
# Run profiler (perf, flamegraph)

# [ ] 2. Identify expensive clones
# Look for:
# - Large struct clones in loops
# - Unnecessary String clones  
# - Vec clones that could be borrowed

# [ ] 3. Selective optimization
# Replace with:
# - References (&T)
# - Cow<'_, T>
# - Arc::clone() for shared ownership
```

**Note**: Don't over-optimize. Arc clones are cheap. Focus on hot paths only.

---

## 🔵 P3: LOW (Optional Polish - 20 hours)

### [ ] 16. Document Environment Variables (2-4 hours)

Create: `docs/ENVIRONMENT_VARIABLES.md`

Document all supported env vars:
```markdown
## Songbird Environment Variables

### Core Configuration
- `SONGBIRD_PORT` - HTTP server port (default: 9000)
- `SONGBIRD_BIND_ADDRESS` - Bind address (default: [::])
- `SONGBIRD_TARPC_PORT` - tarpc server port (default: 9001)

### Federation
- `SONGBIRD_NODE_ID` - Unique node identifier
- `SONGBIRD_FEDERATION_ENABLED` - Enable federation (default: false)

...
```

---

### [ ] 17. Add Performance Benchmarks (4-8 hours)

Expand existing benchmarks in `benches/`:
- [ ] Service discovery performance
- [ ] Load balancer throughput
- [ ] Circuit breaker overhead
- [ ] Adapter call latency

**Verification**:
```bash
cargo bench --workspace
```

---

### [ ] 18. Security Audit (4-8 hours)

Run security analysis:
```bash
# [ ] Install and run cargo-audit
cargo install cargo-audit
cargo audit

# [ ] Install and run cargo-deny
cargo install cargo-deny
cargo deny check

# [ ] Review all unsafe blocks
grep -r "unsafe" crates/*/src --include='*.rs' -A 5
# Ensure all are necessary and documented
```

---

## 📊 PROGRESS TRACKING

### Phase 1: Critical Fixes (Week 1)
- [ ] P0 items 1-5 complete
- [ ] P1 items 6-9 complete
- [ ] Verification: Clean build, no unwraps, tests compile

### Phase 2: Test Coverage (Weeks 2-3)  
- [ ] P1 items 7-8 complete
- [ ] P2 items 10-12 complete
- [ ] Verification: 85%+ coverage

### Phase 3: Polish (Week 4-6)
- [ ] P2 items 13-15 complete
- [ ] P3 items 16-18 complete
- [ ] Verification: All quality gates passing

---

## 🎯 SUCCESS CRITERIA

### After Phase 1 (1 week):
```bash
✅ cargo build --workspace                      # Clean build
✅ cargo test --workspace --lib                 # All tests pass
✅ ./check_production_unwraps.sh                # 0 unwraps
✅ cargo clippy --workspace                     # < 5 warnings
✅ cargo fmt --all -- --check                   # Clean
```

### After Phase 2 (3-4 weeks):
```bash
✅ cargo llvm-cov --workspace --lib             # 85%+ coverage
✅ All security adapter tests passing           # 85%+ coverage
✅ All compute/AI/storage tests passing         # 85%+ coverage
```

### After Phase 3 (5-6 weeks):
```bash
✅ cargo llvm-cov --workspace --lib             # 90% coverage
✅ All E2E tests passing                        # 15-20 scenarios
✅ All chaos tests passing                      # 40-50 scenarios
✅ cargo doc --workspace --no-deps              # < 5 warnings
✅ Production deployment successful             # Staging + Prod
```

---

## 📞 QUICK COMMANDS

```bash
# Check progress
./check_progress.sh  # (create this script)

# Run all quality checks
cargo build --workspace && \
cargo test --workspace --lib && \
cargo clippy --workspace --all-targets && \
cargo fmt --all -- --check && \
./check_production_unwraps.sh && \
cargo llvm-cov --workspace --lib --summary-only

# Quick fix commands
cargo fmt --all                              # Format all code
cargo clippy --workspace --fix --allow-dirty  # Auto-fix clippy issues
cargo fix --workspace --lib --allow-dirty    # Auto-fix compiler suggestions
```

---

**Total Estimated Time**: 200 hours (5-6 weeks)  
**Critical Path**: P0 + P1 (1 week) → P2 (3 weeks) → P3 (2 weeks)  
**Result**: Production-ready A-grade codebase ✅

---

*Generated: November 19, 2025*  
*Print this checklist and track your progress!*

