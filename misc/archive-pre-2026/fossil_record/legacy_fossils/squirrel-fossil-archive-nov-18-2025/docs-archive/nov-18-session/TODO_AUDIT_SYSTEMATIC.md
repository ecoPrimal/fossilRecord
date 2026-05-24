# 🎯 TODO AUDIT - Systematic Elimination Plan
## November 18, 2025 - Phase 2: Deep Debt Solutions

---

## 📊 SUMMARY

**Total TODOs Found**: 131 across 40 files
- **Production Code**: 51 TODOs ⚠️ **HIGH PRIORITY**
- **Test Code**: 80 TODOs 🟡 **LOWER PRIORITY**

**Categories**:
1. **Migration TODOs** (10) - Ongoing migrations
2. **Placeholder Implementations** (25) - Need to complete
3. **Test TODOs** (80) - Test coverage expansion
4. **Feature TODOs** (16) - Future features

---

## 🚨 CRITICAL PRODUCTION TODOs (Priority 1)

### 1. **SDK Error Migration** (`crates/sdk/src/lib.rs`)
```rust
// TODO: Complete migration to universal-error::sdk::SDKError (Week 2-3)
#![allow(deprecated)]
```

**Action**: Complete migration to universal-error
**Impact**: Currently using deprecated types
**Priority**: **IMMEDIATE**
**Effort**: 2-3 hours

### 2. **Plugin Loading** (`crates/services/commands/src/factory.rs`)
```rust
// TODO: Implement plugin adapter when needed
Err("Plugin adapter not yet implemented".into())
```

**Status**: Returns error - **NOT IMPLEMENTED**
**Action**: Either implement or remove if not needed
**Priority**: **HIGH**
**Effort**: 4-6 hours (if needed) or 10 min (if removing)

### 3. **Default Plugin Manager** (`crates/core/plugins/src/default_manager.rs`)
```rust
async fn load_plugins(&self, _directory: &str) -> Result<Vec<Uuid>> {
    // TODO: Implement plugin loading from directory
    Ok(vec![])
}
```

**Status**: Returns empty list - **PLACEHOLDER**
**Action**: Implement or document as intentional
**Priority**: **HIGH**
**Effort**: 6-8 hours (if implementing)

### 4. **WebSocket Message Handling** (`crates/core/mcp/src/transport/websocket/mod.rs`)
```rust
async fn handle_received_message(&self, _message: Message) -> Result<Option<MCPMessage>> {
    // TODO: Implement deserialization and handling of Ping/Pong/Close/Binary/Text
    Ok(None)
}
```

**Status**: Returns None - **INCOMPLETE**
**Action**: Implement message handling
**Priority**: **HIGH** (if WebSocket transport is used)
**Effort**: 4-6 hours

### 5. **WebSocket Protocol Handler** (`crates/core/mcp/src/protocol/websocket.rs`)
```rust
// TODO: Handle received message
```

**Status**: Empty handler - **INCOMPLETE**
**Action**: Implement handler or remove if not needed
**Priority**: **MEDIUM-HIGH**
**Effort**: 2-4 hours

### 6. **Security Health Check** (`crates/universal-patterns/src/security/client.rs`)
```rust
// TODO: Implement actual health checking that connects to the Beardog service
// For now, we just verify that health_check can be called without panicking
```

**Status**: Placeholder implementation - **NOT REAL**
**Action**: Implement actual health check
**Priority**: **MEDIUM** (affects monitoring)
**Effort**: 2-3 hours

---

## 🟡 INFRASTRUCTURE TODOs (Priority 2)

### 7. **Logging Infrastructure** (`crates/sdk/src/infrastructure/logging.rs`)
```rust
file: None, // TODO: Extract from caller info if available
line: None,
module: None,

fn send_to_host(&self, _entry: &LogEntry) {
    // TODO: Implement host communication
}

pub fn log(&self, _level: LogLevel, _message: &str) {
    // TODO: Implement scoped logging
}
```

**Count**: 3 TODOs in logging
**Status**: Infrastructure partially implemented
**Action**: Complete logging infrastructure
**Priority**: **MEDIUM**
**Effort**: 4-6 hours

### 8. **Routing Metrics** (`crates/core/core/src/routing/mod.rs`)
```rust
federation_nodes: 0, // TODO: implement federation node counting
```

**Status**: Hardcoded to 0
**Action**: Implement federation node tracking
**Priority**: **LOW-MEDIUM** (metrics only)
**Effort**: 1-2 hours

---

## 🧪 TEST TODOs (Priority 3)

### 9. **Config Loader Tests** (`crates/config/src/unified/tests/loader_tests.rs`)

**Count**: **27 TODOs** - Most in this single file!

**Categories**:
- File loading tests (3)
- Validation tests (5)
- Environment tests (4)
- Merging tests (3)
- Default tests (2)
- Edge case tests (5)
- Integration tests (3)
- Concurrency tests (2)

**Status**: Test stubs present, implementations commented out
**Action**: Implement tests systematically
**Priority**: **MEDIUM** (improves coverage)
**Effort**: 8-12 hours (all 27 tests)

**Example**:
```rust
#[test]
fn test_config_validation_success() {
    // TODO: Test that valid configs pass validation
}
```

### 10. **Auth JWT Tests** (`crates/core/auth/tests/jwt_tests.rs`)

**Count**: **21 TODOs**

**Status**: Test stubs, similar pattern to config tests
**Action**: Implement JWT test cases
**Priority**: **MEDIUM** (security-related)
**Effort**: 6-8 hours

### 11. **MCP Client Tests** (`crates/core/mcp/src/client/tests.rs`)

**Count**: **16 TODOs**

**Status**: Test stubs
**Action**: Implement MCP client tests
**Priority**: **MEDIUM**
**Effort**: 4-6 hours

---

## 📋 SYSTEMATIC ELIMINATION STRATEGY

### Phase 2A: Critical Production TODOs (This Session)
1. ✅ **SDK Error Migration** (2-3 hours)
2. ✅ **Plugin Adapter Decision** (10 min - remove or 4-6 hours - implement)
3. ✅ **Plugin Loading** (implement or document)
4. ✅ **WebSocket Handlers** (implement or remove)

**Target**: Eliminate all critical production placeholders

### Phase 2B: Infrastructure TODOs (Next Session)
5. Logging infrastructure completion
6. Metrics implementation
7. Health check implementation

**Target**: Complete all infrastructure TODOs

### Phase 2C: Test TODOs (Future Sessions)
8. Config loader tests (27 tests)
9. Auth JWT tests (21 tests)
10. MCP client tests (16 tests)

**Target**: 90% test coverage

---

## 🎯 DECISION FRAMEWORK

For each TODO, ask:

### 1. **Is this feature actually needed?**
- ✅ YES → Implement it
- ❌ NO → Remove the placeholder, update documentation
- 🤷 MAYBE → Document as future work, remove TODO

### 2. **Is this blocking production?**
- ✅ YES → **IMMEDIATE** priority
- ❌ NO → Schedule for later

### 3. **Is there a better modern pattern?**
- ✅ YES → Implement with modern idioms
- ❌ NO → Implement as designed

---

## 📊 TODO CATEGORIES (Full Breakdown)

| Category | Count | Priority | Effort |
|----------|-------|----------|--------|
| **SDK Migration** | 1 | IMMEDIATE | 2-3 hrs |
| **Plugin System** | 2 | HIGH | 6-8 hrs or remove |
| **WebSocket** | 2 | HIGH | 6-10 hrs or remove |
| **Security** | 1 | MEDIUM | 2-3 hrs |
| **Logging** | 3 | MEDIUM | 4-6 hrs |
| **Metrics** | 1 | LOW-MEDIUM | 1-2 hrs |
| **Config Tests** | 27 | MEDIUM | 8-12 hrs |
| **Auth Tests** | 21 | MEDIUM | 6-8 hrs |
| **MCP Tests** | 16 | MEDIUM | 4-6 hrs |
| **Other Tests** | 30 | MEDIUM | 8-10 hrs |
| **Feature TODOs** | 27 | LOW | Variable |

**Total**: 131 TODOs

---

## ✅ ACTION PLAN (THIS SESSION)

### Step 1: SDK Error Migration (30 min)
- Review `universal-error::sdk::SDKError`
- Complete migration
- Remove `#![allow(deprecated)]`

### Step 2: Plugin Adapter (30 min)
- Determine if plugin adapter is needed
- If NO: Remove TODO and stub, document decision
- If YES: Create implementation ticket

### Step 3: Plugin Loading (30 min)
- Determine if directory loading is needed
- If NO: Document why returning empty list is correct
- If YES: Implement or create ticket

### Step 4: WebSocket Handlers (1 hour)
- Check if WebSocket transport is actually used
- If NO: Remove or document as future work
- If YES: Implement handlers

**Total Estimated Time**: 2.5-3 hours for critical production TODOs

---

## 🎓 MODERN RUST PATTERNS TO APPLY

As we eliminate TODOs, apply modern patterns:

1. **Type-Driven Design**: Use types to prevent errors
```rust
// Instead of returning Result<Vec<Uuid>> that's always empty
// Use a proper type that expresses intent
pub enum PluginLoadResult {
    Loaded(Vec<Uuid>),
    NotImplemented,
    DirectoryNotFound(PathBuf),
}
```

2. **Documentation as Code**: If something is intentionally unimplemented:
```rust
/// Returns empty list intentionally - dynamic plugin loading is not enabled
/// in this build. Use compile-time plugin linking instead.
///
/// # Future Work
/// Dynamic loading may be added in v2.0 if sandboxing can be guaranteed.
async fn load_plugins(&self, _directory: &str) -> Result<Vec<Uuid>> {
    Ok(vec![])  // Intentionally empty - see docs
}
```

3. **Feature Flags**: For optional features:
```rust
#[cfg(feature = "websocket-transport")]
async fn handle_received_message(&self, message: Message) -> Result<Option<MCPMessage>> {
    // Implementation
}

#[cfg(not(feature = "websocket-transport"))]
async fn handle_received_message(&self, _message: Message) -> Result<Option<MCPMessage>> {
    Err(TransportError::NotEnabled("websocket-transport"))
}
```

---

## 📈 SUCCESS METRICS

### Target for This Session
- [ ] SDK migration complete (1 TODO)
- [ ] Plugin decisions made (2 TODOs)
- [ ] WebSocket decisions made (2 TODOs)
- [ ] Security health check decision (1 TODO)

**Total**: Remove or complete 6 **CRITICAL** production TODOs

### Phase 2 Complete Criteria
- [ ] Zero placeholder implementations in production code
- [ ] All TODOs have clear justification or are removed
- [ ] Test TODOs converted to GitHub issues
- [ ] Documentation complete for intentional gaps

---

**Status**: Phase 2A starting now
**Next Update**: After critical TODOs eliminated

*"No placeholders in production. Complete or remove."* 🎯

