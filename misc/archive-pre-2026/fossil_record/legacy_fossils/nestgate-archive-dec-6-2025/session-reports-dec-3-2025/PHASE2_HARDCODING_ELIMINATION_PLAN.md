# 🧬 Phase 2: Hardcoding Elimination - Evolutionary Plan

**Status**: ✅ **READY TO EXECUTE**  
**Date**: December 3, 2025  
**Compilation**: ✅ Working (367 doc warnings, but compiles)

---

## 🎯 OBJECTIVE

**Evolve from hardcoded constants to capability-based, primal-sovereign configuration**

### Current State
- **868 hardcoded ports/IPs/constants**
- **135 hardcoded primal names** (beardog, songbird, squirrel, toadstool)
- Breaks sovereignty principles
- Prevents flexible deployment

### Target State
- **0 hardcoded primal names**
- **<50 hardcoded values** (only truly universal constants like buffer sizes)
- **100% capability-based discovery**
- **Environment-driven configuration**

---

## 📋 EVOLUTION STRATEGY

### Step 1: Deprecate Hardcoding Modules

**Files to Deprecate**:
1. `code/crates/nestgate-core/src/constants/hardcoding.rs` (47 values)
2. `code/crates/nestgate-core/src/constants/network_hardcoded.rs` (21 values)
3. `code/crates/nestgate-core/src/constants/network_defaults.rs` (59 values)

**Approach**: Add deprecation warnings, create migration path

```rust
#[deprecated(
    since = "0.2.0",
    note = "Use CapabilityConfig::from_env() instead. See MIGRATION_GUIDE.md"
)]
pub mod hardcoding {
    // Keep for backwards compatibility
}
```

### Step 2: Strengthen Capability-Based Config

**File**: `code/crates/nestgate-core/src/capability_config.rs`

**Enhancements Needed**:
```rust
impl CapabilityConfig {
    /// Get endpoint for any capability (replaces hardcoded ports)
    pub fn get_endpoint(&self, capability: &str) -> Result<SocketAddr> {
        // Current: basic implementation
        // Evolution: Add caching, validation, fallbacks
    }
    
    /// NEW: Get capability URL (not just endpoint)
    pub fn get_capability_url(&self, capability: &str) -> Result<String> {
        let endpoint = self.get_endpoint(capability)?;
        Ok(format!("http://{}", endpoint))
    }
    
    /// NEW: Check if capability is available
    pub fn has_capability(&self, capability: &str) -> bool {
        self.capabilities.contains_key(capability)
    }
    
    /// NEW: List all available capabilities
    pub fn available_capabilities(&self) -> Vec<String> {
        self.capabilities.keys().cloned().collect()
    }
}
```

### Step 3: Eliminate Primal Name Hardcoding

**Current Anti-Pattern**:
```rust
// ❌ BAD: code/crates/nestgate-core/src/config/runtime.rs
pub struct ServiceUrls {
    pub beardog_url: Option<String>,    // ❌ Hardcoded primal name
    pub songbird_url: Option<String>,   // ❌ Hardcoded primal name
    pub squirrel_url: Option<String>,   // ❌ Hardcoded primal name
    pub toadstool_url: Option<String>,  // ❌ Hardcoded primal name
}
```

**Evolved Pattern**:
```rust
// ✅ GOOD: Capability-based
pub struct ServiceUrls {
    capabilities: HashMap<String, String>,
}

impl ServiceUrls {
    pub fn from_env() -> Self {
        let mut capabilities = HashMap::new();
        
        // Discover by capability, not primal name
        if let Ok(url) = env::var("NESTGATE_CAPABILITY_SECURITY") {
            capabilities.insert("security".to_string(), url);
        }
        if let Ok(url) = env::var("NESTGATE_CAPABILITY_NETWORKING") {
            capabilities.insert("networking".to_string(), url);
        }
        if let Ok(url) = env::var("NESTGATE_CAPABILITY_AI") {
            capabilities.insert("ai".to_string(), url);
        }
        if let Ok(url) = env::var("NESTGATE_CAPABILITY_COMPUTE") {
            capabilities.insert("compute".to_string(), url);
        }
        
        Self { capabilities }
    }
    
    pub fn get_capability(&self, capability: &str) -> Option<&str> {
        self.capabilities.get(capability).map(|s| s.as_str())
    }
}
```

### Step 4: Update All Consumers

**Files Using Hardcoded Primal Names** (135 references):

Priority order:
1. **Config modules** (~40 refs) - Foundation
2. **API handlers** (~30 refs) - User-facing
3. **Core services** (~25 refs) - Business logic
4. **Discovery** (~20 refs) - Integration
5. **Tests** (~20 refs) - Can use test fixtures

**Migration Pattern**:
```rust
// ❌ OLD:
let auth_url = config.beardog_url.clone().unwrap();
let client = AuthClient::new(&auth_url)?;

// ✅ NEW:
let auth_url = config.get_capability("security")
    .context("Security capability not configured")?;
let client = AuthClient::new(auth_url)?;
```

---

## 🔄 EXECUTION PLAN

### Phase 2A: Foundation (2-3 hours)

1. ✅ Deprecate hardcoding modules
2. ✅ Enhance `CapabilityConfig`
3. ✅ Create `HARDCODING_MIGRATION_GUIDE.md`
4. ✅ Add integration tests for capability-based config

### Phase 2B: Config Evolution (3-4 hours)

1. ✅ Refactor `config/runtime.rs`
2. ✅ Refactor `config/external/services.rs`
3. ✅ Refactor `config/external/services_config.rs`
4. ✅ Update environment variable documentation

### Phase 2C: Consumer Updates (8-12 hours)

1. ✅ Update API handlers
2. ✅ Update core services
3. ✅ Update discovery modules
4. ✅ Update tests (use test fixtures)

### Phase 2D: Validation (2-3 hours)

1. ✅ Run full test suite
2. ✅ Verify no hardcoded primal names remain
3. ✅ Test with different primal configurations
4. ✅ Document new configuration approach

---

## 📊 SUCCESS METRICS

### Quantitative
- ✅ Hardcoded primal names: 0 (from 135)
- ✅ Hardcoded ports in config: <20 (from 868)
- ✅ Environment variables: Complete coverage
- ✅ Tests passing: 100%

### Qualitative
- ✅ Can swap primal implementations without code changes
- ✅ Can run multiple primal configurations
- ✅ Config is self-documenting
- ✅ Migration path is clear

---

## 🚀 BENEFITS

### Sovereignty
- ✅ Each primal knows only itself
- ✅ Runtime discovery of others
- ✅ No hardcoded dependencies
- ✅ True primal independence

### Flexibility
- ✅ Easy to add new primals
- ✅ Easy to swap implementations
- ✅ Easy to test with mocks
- ✅ Easy to configure per environment

### Maintainability
- ✅ Centralized configuration
- ✅ Clear migration path
- ✅ Type-safe capability references
- ✅ Environment-driven

---

## 🎯 IMMEDIATE NEXT STEPS

1. Start with `capability_config.rs` enhancements
2. Deprecate hardcoding modules
3. Refactor `config/runtime.rs`
4. Update first batch of consumers (API handlers)

**Estimated Time for Phase 2**: 15-20 hours total

---

**Ready to execute!** 🚀

