# 🚀 Squirrel: 2-Week Execution Plan
## November 30 - December 14, 2025

**Current Grade**: B+ (88/100)  
**Target Grade**: A- (90/100)  
**Timeline**: 2 weeks (40-50 hours)  
**Status**: ✅ STARTED

---

## 📊 PROGRESS TRACKER

### Week 1 Status
- [x] **Task 1.1**: Run cargo fmt --all ✅ COMPLETE (1 min)
- [x] **Task 1.2**: Capability auto-discovery ✅ COMPLETE (30 min)
- [ ] **Task 1.3**: Plugin directory loading (6-8 hours)
- [ ] **Task 1.4**: WebSocket protocol completion (4-6 hours)
- [ ] **Task 1.5**: Error path tests (10-12 hours)
- [ ] **Task 1.6**: Clean up dead code (4-6 hours)

### Week 2 Status  
- [ ] **Task 2.1**: Edge case tests (10-12 hours)
- [ ] **Task 2.2**: Reduce unwraps in production (8-10 hours)
- [ ] **Task 2.3**: Review hardcoded ports (4-6 hours)
- [ ] **Task 2.4**: Config layer for constants (4-6 hours)

**Total Estimated**: 51-70 hours (aggressive for 2 weeks)  
**Adjusted Target**: Focus on high-impact items

---

## ✅ COMPLETED (Today)

### 1. Formatting Fix ✅
- **Task**: Run `cargo fmt --all`
- **Time**: 1 minute
- **Impact**: Clean CI/CD pipeline
- **Status**: ✅ COMPLETE

### 2. Capability Auto-Discovery Enhancement ✅  
- **Task**: Implement auto-discovery via service mesh, DNS, env vars
- **Time**: 30 minutes
- **Changes**:
  - Added multi-source discovery strategy
  - Implemented service mesh discovery via HTTP
  - Added DNS-SD placeholder (feature-flagged)
  - Improved error handling
- **File**: `crates/main/src/capability_migration.rs`
- **Status**: ✅ COMPLETE
- **TODO Resolved**: Line 67 TODO removed

---

## 🎯 WEEK 1 PRIORITIES (High Impact)

### Priority 1: Test Coverage Improvements (20-24 hours)

**Goal**: 60% → 70% coverage (+10pp)

#### Task 1.5: Error Path Testing (10-12 hours)
**Files to Create/Enhance**:
1. `crates/main/tests/error_path_coverage.rs` (NEW)
2. `crates/core/plugins/tests/error_scenarios.rs` (NEW)
3. `crates/core/mcp/tests/error_handling_enhanced.rs` (NEW)

**Focus Areas**:
- Network failures in capability discovery
- Plugin initialization failures
- MCP protocol errors
- Configuration loading errors
- Service mesh connection failures

**Template**:
```rust
// crates/main/tests/error_path_coverage.rs
#[cfg(test)]
mod error_path_tests {
    use squirrel::capability_registry::*;
    use squirrel::error::PrimalError;

    #[tokio::test]
    async fn test_capability_discovery_network_failure() {
        // Test network timeout
        // Test connection refused
        // Test invalid response format
    }

    #[tokio::test]
    async fn test_plugin_initialization_failures() {
        // Test missing dependencies
        // Test invalid configuration
        // Test resource exhaustion
    }

    #[tokio::test]
    async fn test_mcp_protocol_errors() {
        // Test malformed messages
        // Test protocol violations
        // Test timeout scenarios
    }

    #[tokio::test]
    async fn test_service_mesh_failures() {
        // Test mesh unavailable
        // Test partial failures
        // Test degraded mode
    }

    #[tokio::test]
    async fn test_configuration_errors() {
        // Test missing required config
        // Test invalid values
        // Test conflicting settings
    }
}
```

**Expected Coverage Gain**: +5-7pp

#### Task 1.6: Clean Up Dead Code (4-6 hours)
**Files to Clean**:
1. `crates/core/plugins/src/types.rs`
   - Remove unused constants: `PLUGIN_TYPE_MCP`, `PLUGIN_TYPE_TOOL`, `PLUGIN_TYPE_CLI`
   - Remove unused enums: `PluginState`, `PluginDataFormat`
   - Remove unused traits: `CorePlugin`, `ToolPlugin`

2. `crates/core/plugins/src/unified_manager.rs`
   - Remove `PlaceholderPlugin` struct
   - Remove unused `new()` method

3. `crates/core/plugins/src/web/adapter.rs`
   - Remove unused fields: `endpoints`, `components`

4. `crates/core/plugins/src/web/example.rs`
   - Remove `ExampleData` struct
   - Remove unused methods

5. `crates/core/mcp/src/` - Various files
   - Remove unused recovery functions
   - Remove unused codec fields

**Commands**:
```bash
# Identify dead code
cargo clippy --all-targets 2>&1 | grep "never used" > dead_code.txt

# Review and remove systematically
# Then verify
cargo test --all
```

**Expected Impact**: -100+ warnings

---

### Priority 2: Plugin Directory Loading (6-8 hours)

#### Task 1.3: Implement Plugin Loading
**File**: `crates/core/plugins/src/default_manager.rs`
**Line**: 200-203

**Implementation Plan**:
```rust
async fn load_plugins(&self, directory: &str) -> Result<Vec<Uuid>> {
    use std::fs;
    use std::path::Path;
    
    let plugin_dir = Path::new(directory);
    if !plugin_dir.exists() {
        return Err(PluginError::DirectoryNotFound(directory.to_string()));
    }

    let mut loaded_plugin_ids = Vec::new();

    // Read plugin manifests
    for entry in fs::read_dir(plugin_dir)? {
        let entry = entry?;
        let path = entry.path();

        // Look for plugin.toml or plugin.json
        if path.is_dir() {
            let manifest_path = path.join("plugin.toml");
            if manifest_path.exists() {
                match self.load_plugin_from_manifest(&manifest_path).await {
                    Ok(plugin_id) => loaded_plugin_ids.push(plugin_id),
                    Err(e) => tracing::warn!("Failed to load plugin from {:?}: {}", path, e),
                }
            }
        }
    }

    Ok(loaded_plugin_ids)
}

async fn load_plugin_from_manifest(&self, manifest_path: &Path) -> Result<Uuid> {
    // Parse manifest
    let manifest_content = fs::read_to_string(manifest_path)?;
    let plugin_config: PluginManifest = toml::from_str(&manifest_content)?;

    // Load plugin library
    let plugin = self.load_plugin_library(&plugin_config)?;

    // Register plugin
    self.register_plugin(plugin).await
}
```

**Test Cases**:
```rust
#[tokio::test]
async fn test_load_plugins_from_directory() {
    // Create test plugin directory
    // Add valid plugin manifests
    // Test loading
    // Verify plugins registered
}

#[tokio::test]
async fn test_load_plugins_invalid_manifest() {
    // Test malformed manifest
    // Verify graceful failure
}

#[tokio::test]
async fn test_load_plugins_missing_directory() {
    // Test non-existent directory
    // Verify appropriate error
}
```

---

### Priority 3: WebSocket Protocol Completion (4-6 hours)

#### Task 1.4: Implement WebSocket Message Handling
**File**: `crates/core/mcp/src/transport/websocket/mod.rs`
**Line**: 395

**Implementation**:
```rust
// Handle different WebSocket message types
match message {
    Message::Text(text) => {
        // Deserialize and handle text messages
        self.handle_text_message(&text).await?;
    }
    Message::Binary(data) => {
        // Handle binary protocol messages
        self.handle_binary_message(&data).await?;
    }
    Message::Ping(data) => {
        // Respond with pong
        self.send_pong(data).await?;
    }
    Message::Pong(_) => {
        // Update keepalive state
        self.update_last_pong().await;
    }
    Message::Close(frame) => {
        // Handle graceful close
        self.handle_close(frame).await?;
    }
    Message::Frame(_) => {
        // Raw frame handling (usually not needed)
    }
}
```

---

## 🎯 WEEK 2 PRIORITIES

### Priority 1: Edge Case Testing (10-12 hours)

**Goal**: 70% → 75% coverage (+5pp)

**Focus**:
- Concurrent operations stress testing
- Race condition scenarios
- Resource exhaustion handling
- Partial failure recovery
- State corruption scenarios

### Priority 2: Production Unwrap Reduction (8-10 hours)

**Target Files**:
1. `crates/services/commands/` - 69 unwraps
2. `crates/main/src/ecosystem/mod.rs` - Estimated 30-40 unwraps
3. `crates/main/src/monitoring/metrics.rs` - Estimated 20-30 unwraps

**Strategy**:
```rust
// BEFORE
let value = map.get("key").unwrap();

// AFTER
let value = map.get("key")
    .ok_or_else(|| PrimalError::MissingConfiguration("key".to_string()))?;

// OR for initialization
let value = map.get("key")
    .expect("key must be present: validated in constructor");
```

### Priority 3: Hardcoded Value Review (4-6 hours)

**Files to Review**:
- `universal-constants/src/network.rs` - Port constants
- `config/src/unified/database.rs` - Connection strings
- `ecosystem-api/src/defaults.rs` - API endpoints

**Add Configuration Layer**:
```rust
// config/src/defaults.rs
pub struct NetworkDefaults {
    pub default_port: u16,
    pub health_check_port: u16,
    pub metrics_port: u16,
}

impl NetworkDefaults {
    pub fn from_env() -> Self {
        Self {
            default_port: env::var("SQUIRREL_PORT")
                .ok()
                .and_then(|s| s.parse().ok())
                .unwrap_or(8080),
            health_check_port: env::var("SQUIRREL_HEALTH_PORT")
                .ok()
                .and_then(|s| s.parse().ok())
                .unwrap_or(8081),
            metrics_port: env::var("SQUIRREL_METRICS_PORT")
                .ok()
                .and_then(|s| s.parse().ok())
                .unwrap_or(9090),
        }
    }
}
```

### Priority 4: Configuration Testing (4-6 hours)

**Test various config scenarios**:
- Missing configuration
- Invalid values
- Environment override
- Fallback behavior

---

## 📈 EXPECTED OUTCOMES

### After Week 1
- **Grade**: B+ (88/100) → B+ (89/100)
- **Coverage**: 60% → 65-67%
- **Warnings**: 624 → ~500
- **TODOs**: 108 → ~95

### After Week 2
- **Grade**: B+ (89/100) → A- (90/100)
- **Coverage**: 65-67% → 70-73%
- **Warnings**: ~500 → ~400
- **Unwraps**: 4,434 → ~4,200 (-200+ in production)
- **Hardcoding**: Reviewed and documented

---

## 🚀 QUICK COMMANDS

```bash
# Format and check
cargo fmt --all
cargo fmt --check

# Test coverage
cargo llvm-cov --lib --html --open

# Run specific test modules
cargo test error_path_coverage
cargo test --package squirrel-plugins

# Check for dead code
cargo clippy --all-targets 2>&1 | grep "never used"

# Run all tests
cargo test --all --lib

# Build and verify
cargo build --release
cargo check --all-targets
```

---

## 📋 DAILY CHECKLIST

### Daily Workflow
- [ ] Start with `cargo fmt --all`
- [ ] Run `cargo test --lib` before changes
- [ ] Make focused changes (1-2 hours)
- [ ] Run `cargo test --lib` after changes
- [ ] Run `cargo clippy` to check warnings
- [ ] Commit with descriptive message
- [ ] Update progress in this document

### Weekly Milestones
- **End of Week 1**: 65% coverage, key TODOs resolved
- **End of Week 2**: 70% coverage, A- grade achieved

---

## 💡 TIPS FOR SUCCESS

### 1. Focus on High-Impact Items
- Test coverage has biggest grade impact
- Error path tests are quick wins
- Dead code cleanup reduces noise

### 2. Batch Similar Work
- Do all error path tests together
- Clean up all dead code in one session
- Review all hardcoded values at once

### 3. Test as You Go
- Run tests frequently (every 30-60 min)
- Catch regressions early
- Verify coverage improvements

### 4. Document as You Work
- Update TODO status in this document
- Note any blockers or issues
- Track actual time vs estimates

---

## 🎯 SUCCESS CRITERIA

### Week 1 Success
- ✅ 3+ critical TODOs resolved
- ✅ Test coverage above 65%
- ✅ <550 clippy warnings
- ✅ All tests passing

### Week 2 Success
- ✅ Test coverage above 70%
- ✅ <400 clippy warnings
- ✅ 200+ production unwraps eliminated
- ✅ A- grade (90/100) achieved

### Overall Success
- ✅ Production-ready with A- grade
- ✅ Clear path to A (93/100)
- ✅ Technical debt reduced by 20%
- ✅ Confidence level: ⭐⭐⭐⭐⭐

---

## 📞 NEXT STEPS

1. **Review this plan** - Adjust priorities based on your goals
2. **Start with Week 1, Priority 1** - Highest impact
3. **Track progress daily** - Update this document
4. **Celebrate wins** - Each TODO completed is progress!

---

**Status**: 🚀 **EXECUTION IN PROGRESS**  
**Current**: 2 tasks complete (formatting, capability auto-discovery)  
**Next**: Plugin directory loading or error path tests  
**Timeline**: On track for A- (90/100) in 2 weeks

🎉 **You've got this! Let's build something amazing.** 🎉

---

**Last Updated**: November 30, 2025  
**Progress**: 2/12 tasks complete (17%)  
**Grade Trajectory**: 88 → 90 (+2 points)

