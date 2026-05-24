# 🔧 TECHNICAL DEBT CATALOG - Squirrel Project
## Date: November 17, 2025

**Purpose**: Comprehensive catalog of ALL technical debt for systematic elimination  
**Goal**: Deep debt solutions & modern idiomatic Rust  
**Status**: Ready for systematic cleanup

---

## 📊 EXECUTIVE SUMMARY

### Current State
- **Build Status**: ✅ Library compiles cleanly
- **Test Status**: ❌ Test compilation fails (12 errors in squirrel-sdk)
- **Coverage**: ❌ Cannot measure (blocked by test compilation)

### Debt Categories

| Category | Count | Priority | Effort |
|----------|-------|----------|--------|
| **Test Compilation Errors** | 12 | 🔴 CRITICAL | 2-4 hrs |
| **Deprecated Types** | ~100 | 🟡 HIGH | 4-6 hrs |
| **Production Unwraps** | ~465-665 | 🟡 HIGH | 20-40 hrs |
| **Expects** | 562 | 🟡 HIGH | 10-20 hrs |
| **Panic! calls** | 143 | 🟡 MEDIUM | 5-10 hrs |
| **TODOs/FIXMEs** | 131 | 🟡 MEDIUM | 15-20 hrs |
| **Hardcoded Ports** | 345 | 🟡 MEDIUM | 8-12 hrs |
| **Dead Code** | 62+ items | 🟢 LOW | 2-4 hrs |
| **Missing Docs** | 100+ | 🟢 LOW | 5-8 hrs |
| **Unimplemented!** | 0 | ✅ NONE | 0 |
| **Unreachable!** | 3 | ✅ MINIMAL | 30 min |

---

## 🔴 PHASE 1: CRITICAL BLOCKERS (2-4 hours)

### 1.1 Test Compilation Errors ❌ URGENT

**Status**: Blocking all test execution and coverage measurement

**Errors Found**:
```
error[E0428]: Multiple module definitions
error[E0061]: Function argument mismatches
error[E0308]: Type mismatches  
error[E0599]: Method not found
```

**Affected**:
- `squirrel-sdk` (lib test) - 12 errors, 506 warnings
- Other test crates blocked by cascading failures

**Files to Fix**:
1. `crates/sdk/src/tests/client_tests.rs`
2. `crates/sdk/src/tests/integration_tests.rs`
3. Test compilation infrastructure

**Priority**: 🔴 CRITICAL - Must fix before any other work
**Effort**: 2-4 hours
**Impact**: Unblocks testing, coverage measurement, CI/CD

---

## 🟡 PHASE 2: DEPRECATED TYPES (4-6 hours)

### 2.1 Deprecated AIError Variants

**Count**: ~60 warnings

**Issue**: Using deprecated tuple variants of `error::AIError`
```rust
// OLD (deprecated):
Error::Provider(msg)
Error::Model(msg)
Error::Runtime(msg)
Error::Configuration(msg)

// NEW (correct):
use universal_error::tools::AIToolsError;
```

**Files Affected**:
1. `crates/tools/ai-tools/src/anthropic/mod.rs` (8 instances)
2. `crates/tools/ai-tools/src/gemini/mod.rs` (11 instances)
3. `crates/tools/ai-tools/src/local/native.rs` (3 instances)
4. `crates/tools/ai-tools/src/local/ollama.rs` (10 instances)
5. `crates/tools/ai-tools/src/router/*.rs` (4 instances)

**Priority**: 🟡 HIGH (blocks clean compilation)
**Effort**: 4-6 hours
**Pattern**: Systematic find-replace with proper error wrapping

### 2.2 Deprecated TimeoutConfig Fields

**Count**: ~30 warnings

**Issue**: Using deprecated fields of `config::types::TimeoutConfig`
```rust
// OLD (deprecated):
timeouts.connect
timeouts.request
timeouts.keep_alive
timeouts.idle

// NEW (correct):
use squirrel_mcp_config::unified::TimeoutConfig
```

**Files Affected**:
1. `crates/universal-patterns/src/config/builder.rs`
2. `crates/universal-patterns/src/config/methods.rs`
3. `crates/universal-patterns/src/config/presets.rs`
4. `crates/universal-patterns/src/config/types.rs`
5. `crates/universal-patterns/src/config/validation.rs`

**Priority**: 🟡 HIGH (part of ADR-009 migration)
**Effort**: 2-3 hours
**Pattern**: Migrate to unified config types

### 2.3 Deprecated PluginMetadata

**Count**: ~28 warnings

**Issue**: Using deprecated `plugin::PluginMetadata`
```rust
// OLD (deprecated):
use plugin::PluginMetadata;

// NEW (correct):
use squirrel_interfaces::plugins::PluginMetadata;
```

**Files Affected**: Multiple plugin-related files
**Priority**: 🟡 MEDIUM
**Effort**: 1-2 hours
**Pattern**: Simple import update

---

## 🟡 PHASE 3: PRODUCTION UNWRAPS/EXPECTS (30-60 hours)

### 3.1 High-Priority Unwrap Files

**Top 10 Production Files** (by unwrap count):

| File | Unwraps | Priority | Type |
|------|---------|----------|------|
| `crates/core/mcp/src/session/mod.rs` | 36 | 🔴 CRITICAL | Session management |
| `crates/services/commands/src/journal.rs` | 36 | 🔴 CRITICAL | Data persistence |
| `crates/services/commands/src/history.rs` | 33 | 🔴 CRITICAL | Data persistence |
| `crates/integration/web/src/auth/mfa.rs` | 32 | 🔴 CRITICAL | Security |
| `crates/core/mcp/src/task/manager.rs` | 27 | 🟡 HIGH | Task orchestration |
| `crates/core/mcp/src/transport/framing.rs` | 22 | 🟡 HIGH | Network protocol |
| `crates/core/mcp/src/monitoring/clients.rs` | 32 | 🟡 HIGH | Monitoring |
| `crates/services/commands/src/suggestions.rs` | 17 | 🟡 MEDIUM | User features |
| `crates/services/commands/src/mod.rs` | 16 | 🟡 MEDIUM | Core commands |
| `crates/services/commands/src/history.rs` | 33 | 🟡 MEDIUM | History tracking |

### 3.2 Unwrap Patterns to Apply

**Pattern 1: RwLock Operations**
```rust
// OLD (panic risk):
let guard = lock.read().unwrap();

// NEW (idiomatic):
match lock.read() {
    Ok(guard) => {
        // use guard
    },
    Err(e) => {
        tracing::error!("Failed to acquire read lock: {}", e);
        return Err(Error::LockPoisoned);
    }
}

// OR (with logging):
let guard = lock.read()
    .map_err(|e| {
        tracing::error!("Lock poisoned: {}", e);
        Error::LockPoisoned
    })?;
```

**Pattern 2: HashMap/Collection Access**
```rust
// OLD (panic risk):
let value = map.get(key).unwrap();

// NEW (idiomatic):
let value = map.get(key)
    .ok_or_else(|| Error::NotFound(format!("Key not found: {}", key)))?;

// OR (with default):
let value = map.get(key).unwrap_or(&default_value);
```

**Pattern 3: Option Handling**
```rust
// OLD (panic risk):
let result = some_option.unwrap();

// NEW (idiomatic):
let result = some_option
    .ok_or_else(|| Error::MissingValue("expected value"))?;
```

**Pattern 4: JSON Serialization**
```rust
// OLD (panic risk):
let json = serde_json::to_string(&data).unwrap();

// NEW (idiomatic):
let json = serde_json::to_string(&data)
    .map_err(|e| {
        tracing::error!("Failed to serialize: {}", e);
        Error::SerializationFailed(e)
    })?;
```

### 3.3 Expect Cleanup

**Count**: 562 expects across 74 files

**Pattern**:
```rust
// OLD:
let value = option.expect("This should never fail");

// NEW:
let value = option
    .ok_or_else(|| Error::Unexpected("value missing"))?;
```

### 3.4 Panic! Cleanup

**Count**: 143 panics across 59 files

**Categories**:
- Test assertions: ✅ KEEP (appropriate for tests)
- Invariant violations: ⚠️ REPLACE with proper error handling
- Debug assertions: ⚠️ REVIEW (may be appropriate)

**Pattern for Production Code**:
```rust
// OLD:
if condition {
    panic!("Invalid state");
}

// NEW:
if condition {
    tracing::error!("Invalid state detected");
    return Err(Error::InvalidState("condition failed"));
}
```

---

## 🟡 PHASE 4: TODOs & INCOMPLETE CODE (15-20 hours)

### 4.1 TODO Distribution

**Total**: 131 TODOs across 40 files

**By Category**:
- MCP Protocol: 16 TODOs (active development)
- Config System: 27 TODOs (migration in progress)
- Tests: 78 TODOs (acceptable - future improvements)
- Production Code: ~10-20 TODOs (must address)

### 4.2 High-Priority TODOs

**Production Code TODOs** (must resolve):

1. **Core Routing** (1 TODO)
   - File: `crates/core/core/src/routing/mod.rs`
   - Context: Load balancing algorithm
   
2. **MCP Enhanced** (3 TODOs)
   - File: `crates/core/mcp/src/enhanced/multi_agent/coordinator.rs`
   - Context: Multi-agent coordination features
   
3. **Config System** (27 TODOs)
   - Files: `crates/config/src/unified/tests/loader_tests.rs`
   - Context: ADR-009 migration in progress
   
4. **Tool Management** (1 TODO)
   - File: `crates/core/mcp/src/tool/lifecycle/mod.rs`
   - Context: Lifecycle management

### 4.3 Resolution Strategy

**For Each TODO**:
1. ✅ **IMPLEMENT**: If critical for functionality
2. ✅ **DOCUMENT**: If intentionally deferred with justification
3. ✅ **DELETE**: If no longer relevant
4. ❌ **NEVER**: Leave without decision

**Template for Documented Deferrals**:
```rust
// DEFERRED: [Brief reason]
// Issue: #[issue-number]
// Priority: [Low/Medium/High]
// Estimated: [effort]
```

---

## 🟡 PHASE 5: HARDCODED VALUES (8-12 hours)

### 5.1 Hardcoded Ports

**Count**: 345 instances across 107 files

**Common Ports**:
- `:8080`, `:8081`, `:8082` - HTTP services (60+ instances)
- `:50051`, `:50052` - gRPC services (40+ instances)
- `:9090` - Metrics/monitoring (15+ instances)
- `:5432` - PostgreSQL (10+ instances)
- `:6379` - Redis (8+ instances)

**Solution**:
```rust
// OLD:
let addr = "127.0.0.1:8080".parse().unwrap();

// NEW:
use universal_constants::network::DEFAULT_HTTP_PORT;
let port = env::var("HTTP_PORT")
    .ok()
    .and_then(|p| p.parse().ok())
    .unwrap_or(DEFAULT_HTTP_PORT);
let addr = SocketAddr::new(IpAddr::V4(Ipv4Addr::LOCALHOST), port);
```

**Files to Update**:
1. All integration tests (use test fixtures)
2. Config files (use environment variables)
3. Examples (use documented defaults)
4. Production code (use `universal-constants`)

---

## 🟢 PHASE 6: DEAD CODE & CLEANUP (2-4 hours)

### 6.1 Dead Code Items

**Count**: 62+ unused items

**Categories**:
1. **Unused Structs**: 15+ (mock types, placeholders)
2. **Unused Fields**: 30+ (incomplete implementations)
3. **Unused Functions**: 10+ (draft code)
4. **Unused Enums**: 7+ (planned features)

**Top Files**:
1. `crates/universal-patterns/src/security/providers/mod.rs` (25+ unused items)
2. `crates/tools/ai-tools/src/local/ollama.rs` (10+ unused fields)
3. `crates/tools/ai-tools/src/router/mcp_adapter.rs` (8 unused items)
4. `crates/main/src/security/rate_limiter.rs` (2 unused fields)

**Strategy**:
1. ✅ **DELETE**: If truly unused and not part of public API
2. ✅ **IMPLEMENT**: If part of planned feature
3. ✅ **MARK**: Use `#[allow(dead_code)]` with justification if intentional
4. ❌ **IGNORE**: Never leave without decision

---

## 🟢 PHASE 7: MISSING DOCUMENTATION (5-8 hours)

### 7.1 Missing Doc Comments

**Count**: 100+ warnings

**Categories**:
- Public structs without docs: 20+
- Public fields without docs: 50+
- Public enums without docs: 10+
- Public variants without docs: 20+

**Files**:
1. `crates/universal-patterns/src/security/hardening.rs` (40+ missing docs)
2. `crates/universal-patterns/src/security/zero_copy.rs` (10+ missing docs)
3. Various other security modules

**Pattern**:
```rust
/// Brief one-line description.
///
/// More detailed explanation of what this does,
/// when to use it, and any important caveats.
///
/// # Examples
///
/// ```
/// // Usage example
/// ```
pub struct MyStruct {
    /// Description of this field
    pub field: Type,
}
```

---

## 🚀 MODERNIZATION OPPORTUNITIES

### Modern Idiomatic Rust Patterns

**1. Async Trait Migration** (Future)
- Current: 593 `#[async_trait]` usages
- Target: Native `async fn` in traits (Rust 1.75+)
- Effort: 20-30 hours
- Benefit: 20-50% performance improvement

**2. Error Handling**
- Current: Mix of unwrap, expect, manual Result handling
- Target: Consistent `thiserror` + proper propagation
- Status: Partially complete

**3. Builder Pattern**
- Current: Mix of constructors
- Target: Consistent `derive(Builder)` where appropriate
- Status: Partially implemented

**4. Zero-Copy**
- Current: Good (`Arc<str>`, no `Arc<String>`)
- Target: Expand to more hot paths
- Effort: 4-6 hours (profiling-guided)

---

## 📋 SYSTEMATIC CLEANUP PLAN

### Week 1: Critical Fixes (10-15 hours)
- ✅ Day 1: Fix test compilation errors (2-4 hrs)
- ✅ Day 2: Deprecated type migration (4-6 hrs)
- ✅ Day 3: Top 5 unwrap-heavy files (4-5 hrs)

### Week 2-3: Production Quality (30-40 hours)
- Clean remaining production unwraps (20-30 hrs)
- Configure hardcoded ports (8-12 hrs)
- Resolve all production TODOs (10-15 hrs)

### Week 4: Polish & Verification (10-15 hours)
- Remove dead code (2-4 hrs)
- Add missing documentation (5-8 hrs)
- Verify 90% test coverage (3-5 hrs)

---

## 🎯 SUCCESS CRITERIA

### Build & Test
- ✅ All tests compile cleanly
- ✅ All tests pass
- ✅ 90% test coverage achieved
- ✅ Zero compilation warnings

### Code Quality
- ✅ <100 production unwraps
- ✅ Zero production expects
- ✅ Zero production panics (except invariants)
- ✅ All TODOs resolved or documented
- ✅ Zero hardcoded configuration values

### Documentation
- ✅ 100% public API documented
- ✅ All modules have module-level docs
- ✅ Examples for key features

### Idiomatic Rust
- ✅ Consistent error handling
- ✅ Proper ownership patterns
- ✅ Zero-copy where beneficial
- ✅ Modern async patterns

---

## 📊 TRACKING METRICS

### Current Baseline (Nov 17, 2025)
```
Build Status:          ✅ Library compiles
Test Status:           ❌ Tests fail (12 errors)
Coverage:              ❓ Unknown (blocked)
Production Unwraps:    ~465-665
Expects:               562
Panics:                143
TODOs:                 131
Hardcoded Ports:       345
Dead Code Items:       62+
Missing Docs:          100+
Compilation Warnings:  500+ (mostly deprecations)
```

### Target State (Week 4)
```
Build Status:          ✅ All compiles
Test Status:           ✅ All pass
Coverage:              ✅ 90%+
Production Unwraps:    <100
Expects:               0 (in production)
Panics:                0 (except invariants)
TODOs:                 0 (or documented)
Hardcoded Ports:       0
Dead Code Items:       0
Missing Docs:          0 (public API)
Compilation Warnings:  0
```

---

## 🔧 TOOLS & AUTOMATION

### Available Tools
1. `cargo clippy --fix` - Auto-fix some issues
2. `cargo fmt` - Format code
3. `cargo test` - Run tests
4. `cargo llvm-cov` - Measure coverage
5. Custom scripts in `scripts/` directory

### Recommended Workflow
```bash
# 1. Fix one category at a time
# 2. After each fix:
cargo build --workspace --lib
cargo test --workspace --lib
cargo clippy --workspace --all-targets
cargo fmt --all

# 3. Measure progress:
cargo llvm-cov --workspace --summary-only

# 4. Commit frequently with descriptive messages
git commit -m "fix: Remove unwraps from session management (36 → 0)"
```

---

**Status**: Catalog complete, ready for systematic cleanup  
**Next**: Start Phase 1 (test compilation fixes)  
**Timeline**: 4 weeks to complete all phases  
**Confidence**: HIGH (clear plan, proven patterns)

