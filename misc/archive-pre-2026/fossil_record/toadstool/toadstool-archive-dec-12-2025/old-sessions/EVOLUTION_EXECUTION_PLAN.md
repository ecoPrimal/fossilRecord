# 🚀 ToadStool Evolution Execution Plan
**Date**: December 10, 2025  
**Status**: IN PROGRESS

## Phase 1: Critical Foundations (Weeks 1-6)

### ✅ Already Complete (Dec 9, 2025)
- [x] mDNS/DNS-SD discovery system
- [x] Self-identity with runtime resource detection  
- [x] Capability-based service advertising
- [x] Real GPU detection via wgpu
- [x] Archive cleanup (1,683 → 28 TODOs)

### 🔄 In Progress (Dec 10, 2025)

#### 1. unwrap/expect Reduction (Priority: HIGH)
**Current**: 2,116 in production  
**Target Phase 1**: <500  
**Strategy**: Context-based error propagation

**Approach**:
```rust
// Pattern 1: Simple unwrap → ?
// Before:
let value = some_operation().unwrap();

// After:
let value = some_operation()
    .context("Failed to perform operation")?;

// Pattern 2: expect with message → proper error
// Before:
let value = operation().expect("Operation failed");

// After:
let value = operation()
    .map_err(|e| ToadStoolError::runtime(format!("Operation failed: {}", e)))?;

// Pattern 3: Creation/initialization
// Before:
let resource = Resource::new().unwrap();

// After:
let resource = Resource::new()
    .context("Failed to initialize resource")?;
```

**Files to prioritize** (production code only):
1. `crates/runtime/gpu/src/cpu_resource.rs` - 9 instances
2. `crates/core/toadstool/src/` - Multiple files
3. `crates/distributed/src/` - Multiple files

**Timeline**: 3-4 weeks (systematic migration)

---

#### 2. Test Coverage Expansion (Priority: CRITICAL)
**Current**: 42.4% (18,549/43,722 lines)  
**Target Phase 1**: 60%  
**Required**: ~400 new tests

**Focus Areas**:
- Core orchestration paths (low coverage)
- Discovery system integration tests
- GPU framework edge cases  
- BYOB executor scenarios
- Error handling paths

**Test Types to Add**:
- Integration tests for capability matching
- Discovery timeout scenarios
- GPU fallback behavior
- Resource allocation edge cases
- Concurrent workload handling

**Timeline**: 4-5 weeks

---

#### 3. GPU Framework Restoration (Priority: HIGH)
**Current**: WebGPU only  
**Target**: WebGPU + Vulkan + OpenCL

**Status Review**:
- ✅ WebGPU: Fully implemented
- ⚠️ Vulkan: Fallback stub (needs implementation)
- ⚠️ OpenCL: Fallback stub (needs implementation)

**Implementation Plan**:
- Use `ash` crate for Vulkan bindings
- Use `ocl` crate for OpenCL bindings  
- Maintain same `ParallelComputeFramework` trait
- Feature-gated compilation

**Timeline**: 2-3 weeks

---

## Phase 2: Quality & Modernization (Weeks 7-14)

### 4. Smart File Refactoring (Priority: MEDIUM)
**Files >1000 lines**: 8 (all test files)

**Architectural Refactoring Strategy**:
```
Before: biomeos_integration_tests.rs (1424 lines)
After:
  - biomeos_integration_tests/
    - mod.rs (main test orchestration)
    - auth_tests.rs (authentication scenarios)
    - storage_tests.rs (storage scenarios)
    - agent_tests.rs (agent scenarios)
    - fixtures.rs (shared test data)
```

**Benefits**:
- Better organization by domain
- Parallel test execution
- Easier to find/maintain tests
- Clearer test intent

**Timeline**: 1 week

---

### 5. Unsafe Evolution (Priority: MEDIUM)
**Current**: 45 unsafe blocks (all in WASM cache)  
**Target**: <20, all justified and documented

**Strategy**:
- ✅ `cache_zero_unsafe.rs` already exists (100% safe alternative)
- Benchmark safe vs unsafe performance
- Default to safe implementation
- Document trade-offs clearly
- Provide unsafe as opt-in for extreme performance needs

**Timeline**: 1-2 weeks

---

### 6. Mock Evolution to Real Implementations (Priority: HIGH)

**Production Mocks Identified**:
1. Edge platform monitoring (ESP32, Arduino)
2. Songbird gRPC/WebSocket clients (stubs)
3. Zero-config health checks
4. Legacy system integrations

**Approach**:
- Isolate mocks to `#[cfg(test)]` only
- Implement real clients with proper error handling
- Use feature flags for optional integrations
- Document integration requirements

**Timeline**: 3-4 weeks

---

### 7. Hardcoding Evolution (Priority: HIGH)

**Current State**:
- ✅ Ports: Centralized in `config/defaults.rs`
- ✅ Discovery: mDNS capability-based (implemented)
- ✅ Self-knowledge: No peer assumptions
- 🟡 Some hardcoded addresses in tests (acceptable)

**Remaining Work**:
- Ensure ALL production code uses discovery
- Remove any hardcoded primal endpoints
- Document configuration via env vars
- Add examples of full capability-based deployment

**Philosophy**: "Know Yourself, Discover Others at Runtime" ✅

**Timeline**: 1-2 weeks (mostly documentation)

---

## Phase 3: Optimization & Polish (Weeks 15-18)

### 8. Zero-Copy Optimizations (Priority: MEDIUM)
**Current**: 13,424 string allocations  
**Target**: Profile-guided reduction (50-70% in hot paths)

**Strategy**:
```rust
// Pattern 1: &str instead of String
// Before:
fn process_data(key: String) { ... }

// After:
fn process_data(key: &str) { ... }

// Pattern 2: Cow<str> for flexible ownership
// Before:
let result = if needs_owned {
    input.to_string()
} else {
    input.to_string()  // Always allocates!
};

// After:
use std::borrow::Cow;
let result: Cow<str> = if needs_owned {
    Cow::Owned(modified_string)
} else {
    Cow::Borrowed(input)
};

// Pattern 3: Arc<str> for shared strings
// Before:
struct Config {
    endpoint: String,  // Cloned frequently
}

// After:
struct Config {
    endpoint: Arc<str>,  // Cheap to clone
}
```

**Process**:
1. Profile with `cargo flamegraph`
2. Identify hot paths (request/response, discovery)
3. Apply zero-copy patterns strategically
4. Benchmark improvements
5. Document patterns for future code

**Timeline**: 2-3 weeks

---

### 9. Chaos Test Infrastructure (Priority: CRITICAL)
**Current**: Stubs only (infrastructure not implemented)  
**Target**: Full chaos testing framework

**Implementation**:
```rust
// Chaos test scenarios:
- Network partition simulation
- Resource exhaustion (memory, CPU)
- Service discovery failures
- Partial system failures
- Byzantine behavior simulation
- Timing attacks
- Load spikes

// Infrastructure needed:
- Fault injection framework
- Network simulator
- Resource limiter
- Time manipulation
- Distributed test coordinator
```

**Timeline**: 3-4 weeks

---

### 10. Fault Injection (Priority: CRITICAL)
**Integration with chaos tests**

**Scenarios**:
- GPU driver failures
- Discovery timeout
- Partial capability matches
- Resource allocation failures
- Concurrent access conflicts
- State corruption recovery

**Timeline**: 2-3 weeks (with chaos infrastructure)

---

## Modern Idiomatic Rust Patterns

### Patterns to Apply Across Codebase:

#### 1. Error Handling
```rust
use anyhow::{Context, Result};

// Layered error context
fn complex_operation() -> Result<Data> {
    let config = load_config()
        .context("Failed to load configuration")?;
    
    let connection = connect(&config)
        .context("Failed to establish connection")?;
    
    process_data(connection)
        .context("Failed to process data")
}
```

#### 2. Builder Patterns
```rust
// Already present, ensure consistency
let identity = SelfIdentity::new()
    .with_network("host", Some(8084), vec!["http"])
    .with_capabilities(vec![...])
    .build()?;
```

#### 3. Type State Patterns
```rust
// For complex state machines
struct Uninitialized;
struct Ready;

struct Service<State> {
    state: PhantomData<State>,
    // ... fields
}

impl Service<Uninitialized> {
    fn initialize(self) -> Result<Service<Ready>> { ... }
}

impl Service<Ready> {
    fn execute(&self) -> Result<()> { ... }  // Only callable when ready
}
```

#### 4. Async Patterns
```rust
// Structured concurrency
use tokio::task::JoinSet;

let mut set = JoinSet::new();
for service in services {
    set.spawn(async move {
        service.discover().await
    });
}

while let Some(res) = set.join_next().await {
    // Handle results
}
```

---

## Progress Tracking

### Week 1-2: unwrap Reduction Foundation
- [ ] Audit all production unwrap/expect
- [ ] Categorize by complexity
- [ ] Implement context-based errors for top 100 files
- [ ] Target: Reduce to <1500

### Week 3-4: Test Coverage Push
- [ ] Identify low-coverage modules
- [ ] Write integration tests for discovery
- [ ] Add GPU framework edge case tests
- [ ] Target: 50% coverage

### Week 5-6: GPU Framework Restoration
- [ ] Implement Vulkan support
- [ ] Implement OpenCL support
- [ ] Integration tests for all frameworks
- [ ] Target: 3 frameworks operational

### Week 7-8: Production Mock Evolution
- [ ] Identify all production mocks
- [ ] Implement Songbird client
- [ ] Implement edge monitoring
- [ ] Target: Zero production mocks

### Week 9-10: File Refactoring
- [ ] Smart split of 8 large test files
- [ ] Maintain test coverage
- [ ] Improve test discoverability

### Week 11-12: Test Coverage to 60%
- [ ] Add ~200 more tests
- [ ] Focus on integration scenarios
- [ ] E2E test expansion

### Week 13-14: unwrap Reduction Complete
- [ ] Reduce to <500 unwrap/expect
- [ ] Document remaining justified uses

### Week 15-16: Chaos Infrastructure
- [ ] Build fault injection framework
- [ ] Implement chaos test scenarios
- [ ] Network partition simulation

### Week 17-18: Zero-Copy & Polish
- [ ] Profile hot paths
- [ ] Apply zero-copy optimizations
- [ ] Final test coverage push to 70%+

---

## Success Metrics

### Phase 1 Complete (Week 6):
- ✅ unwrap/expect: <500
- ✅ Test coverage: 60%
- ✅ GPU frameworks: 3 operational
- ✅ Grade: B+ → A-

### Phase 2 Complete (Week 14):
- ✅ unwrap/expect: <200
- ✅ Test coverage: 80%
- ✅ Zero production mocks
- ✅ Grade: A- → A

### Phase 3 Complete (Week 18):
- ✅ unwrap/expect: <100
- ✅ Test coverage: 90%+
- ✅ Chaos tests operational
- ✅ Grade: A → A+

---

**Status**: Ready to Execute  
**Next Action**: Begin unwrap/expect reduction (high-impact, systematic)

