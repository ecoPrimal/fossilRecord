# 📐 File Refactoring Plan - November 27, 2025

## 🎯 Goal
Achieve **100% file size compliance** by splitting 6 files that exceed the 1000-line limit.

**Current Compliance**: 99.4% (1,155/1,161 files)  
**Target Compliance**: 100% (all files <1000 lines)

---

## 📊 Files to Refactor (In Priority Order)

### 1. `crates/core/mcp/src/server_impl.rs` (1,151 lines) ⚠️
**Status**: DUPLICATE/LEGACY  
**Analysis**: This appears to be a legacy implementation. The modular `server.rs` already exists with proper structure:
- `server/config.rs` - Configuration types
- `server/handlers.rs` - Handler traits  
- `server/connection.rs` - Connection management
- `server/adapters.rs` - Routing adapters

**Recommendation**: 
- **Option A**: Delete `server_impl.rs` if it's unused (verify no imports)
- **Option B**: Consolidate unique functionality into modular `server/` structure
- **Effort**: 1-2 hours (investigation + migration)

---

### 2. `crates/core/context/src/visualization/types.rs` (1,142 lines) ⚠️
**Status**: NEEDS SPLITTING  
**Purpose**: Visualization type definitions

**Proposed Split**:
```
visualization/types/
├── mod.rs           (50 lines)  - Re-exports
├── metrics.rs       (350 lines) - Metric types
├── events.rs        (300 lines) - Event types
├── layouts.rs       (250 lines) - Layout definitions
└── rendering.rs     (250 lines) - Rendering types
```

**Rationale**: Natural grouping by type category
**Effort**: 3-4 hours

---

### 3. `crates/core/mcp/src/enhanced/multi_agent/mod.rs` (1,079 lines) ⚠️
**Status**: NEEDS SPLITTING  
**Purpose**: Multi-agent coordination

**Proposed Split**:
```
multi_agent/
├── mod.rs           (100 lines) - Core types & re-exports
├── coordinator.rs   (400 lines) - Coordination logic
├── protocols.rs     (300 lines) - Communication protocols
└── consensus.rs     (300 lines) - Consensus mechanisms
```

**Rationale**: Separate coordination, protocols, and consensus
**Effort**: 2-3 hours

---

### 4. `crates/core/mcp/src/server.rs` (1,040 lines) ⚠️
**Status**: PARTIALLY REFACTORED  
**Note**: Already has submodules declared, but main implementation still in server.rs

**Current Structure**:
```
server/
├── mod.rs         (exists?)
├── config.rs      (✅ exists)
├── handlers.rs    (✅ exists)
├── connection.rs  (✅ exists)
└── adapters.rs    (✅ exists)
```

**Action Needed**: Move core `MCPServer` impl from `server.rs` to `server/core.rs` or `server/server_impl.rs`

**Proposed**:
```
server/
├── mod.rs           (50 lines)  - Re-exports
├── config.rs        (✅ existing)
├── handlers.rs      (✅ existing)
├── connection.rs    (✅ existing)
├── adapters.rs      (✅ existing)
└── core.rs          (600 lines) - MCPServer implementation
```

**Effort**: 2-3 hours

---

### 5. `crates/core/context/src/sync.rs` (1,036 lines) ⚠️
**Status**: NEEDS SPLITTING  
**Purpose**: Context synchronization

**Proposed Split**:
```
sync/
├── mod.rs           (100 lines) - Core types & re-exports
├── engine.rs        (400 lines) - Sync engine
├── strategies.rs    (300 lines) - Sync strategies
└── conflict.rs      (250 lines) - Conflict resolution
```

**Rationale**: Separate engine, strategies, and conflict handling
**Effort**: 2-3 hours

---

### 6. `crates/adapter-pattern-tests/src/lib.rs` (1,007 lines) ⚠️
**Status**: TEST FILE - LOW PRIORITY  
**Purpose**: Adapter pattern tests

**Proposed Split**:
```
tests/
├── mod.rs           (50 lines)  - Test utilities
├── mcp_tests.rs     (400 lines) - MCP adapter tests
├── plugin_tests.rs  (300 lines) - Plugin adapter tests
└── auth_tests.rs    (300 lines) - Auth adapter tests
```

**Rationale**: Group tests by adapter type
**Effort**: 1-2 hours
**Note**: Test files are lower priority for size compliance

---

## 🎯 Execution Strategy

### Phase 1: Investigation (1 hour)
1. ✅ Verify `server_impl.rs` usage
2. ✅ Check import dependencies  
3. ✅ Identify dead code
4. ✅ Plan consolidation

### Phase 2: Quick Wins (2-3 hours)
1. Delete or consolidate `server_impl.rs` (if unused)
2. Move `server.rs` impl to `server/core.rs`
3. Update imports and re-exports

### Phase 3: Major Refactorings (6-8 hours)
1. Split `visualization/types.rs` → 4 files
2. Split `multi_agent/mod.rs` → 3 files
3. Split `sync.rs` → 3 files
4. (Optional) Split `adapter-pattern-tests/lib.rs`

### Phase 4: Verification (1 hour)
1. Run `cargo test --workspace`
2. Run `cargo build --workspace`
3. Run `cargo clippy --workspace`
4. Verify all imports work
5. Update documentation

---

## 📐 Refactoring Patterns

### Pattern 1: Type Splitting
```rust
// Before: types.rs (1,142 lines)
pub struct MetricType { ... }
pub struct EventType { ... }
pub struct LayoutType { ... }

// After: types/mod.rs (50 lines)
pub mod metrics;
pub mod events;  
pub mod layouts;

pub use metrics::*;
pub use events::*;
pub use layouts::*;
```

### Pattern 2: Functionality Splitting
```rust
// Before: coordinator.rs (1,079 lines)
impl MultiAgentCoordinator {
    fn coordinate() { ... }
    fn send_protocol() { ... }
    fn reach_consensus() { ... }
}

// After: Split into focused modules
// coordinator.rs - coordination only
// protocols.rs - protocol handling
// consensus.rs - consensus mechanisms
```

### Pattern 3: Module Consolidation
```rust
// Before: server_impl.rs + server.rs (both large)

// After: Unified server/ directory
server/
├── mod.rs - Public API
├── config.rs - Configuration
├── core.rs - Main implementation
├── handlers.rs - Handler traits
└── connection.rs - Connection mgmt
```

---

## ✅ Success Criteria

- [ ] All files <1000 lines
- [ ] All tests passing
- [ ] All imports working
- [ ] Documentation updated
- [ ] No functionality lost
- [ ] Clippy clean
- [ ] 100% file size compliance ✅

---

## 📊 Impact Metrics

### Before
```
Files >1000 lines: 6 (0.6%)
Compliance: 99.4%
Largest file: 1,151 lines
```

### After
```
Files >1000 lines: 0 (0%)
Compliance: 100% ✅
Largest file: <1000 lines
```

---

## ⚠️ Risks & Mitigations

### Risk 1: Breaking Changes
**Mitigation**: 
- Use re-exports for backward compatibility
- Update imports incrementally
- Run tests after each change

### Risk 2: Import Cycles
**Mitigation**:
- Plan module hierarchy carefully
- Use traits for abstraction
- Document dependencies

### Risk 3: Lost Functionality
**Mitigation**:
- Comprehensive test coverage
- Verify all public APIs
- Check documentation examples

---

## 🚀 Estimated Timeline

**Total Effort**: 10-14 hours

```
Phase 1: Investigation        1 hour   (today)
Phase 2: Quick Wins           2-3 hours (today)
Phase 3: Major Refactorings   6-8 hours (next 2 days)
Phase 4: Verification         1 hour   (final)
```

**Recommended Pace**: 
- Today: Phases 1-2 (3-4 hours)
- Tomorrow: Phase 3, Part 1 (3-4 hours)
- Day 3: Phase 3, Part 2 + Phase 4 (4-5 hours)

---

## 📝 Next Actions

1. **Immediate**: Verify `server_impl.rs` usage
2. **Today**: Complete Phases 1-2 (quick wins)
3. **This Week**: Complete Phase 3 (major refactorings)
4. **End of Week**: 100% compliance achieved ✅

---

**Plan Created**: November 27, 2025  
**Status**: READY FOR EXECUTION  
**Priority**: MEDIUM (Week 2 goal)

*Reality > Hype. Truth > Marketing. Safety > Speed.* ✅

