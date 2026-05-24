# 🔧 HARDCODING MIGRATION PATTERN GUIDE

**Date**: December 1, 2025  
**Status**: Ready for execution  
**Infrastructure**: ✅ Complete  
**Total Values**: 1,370 to migrate

---

## ✅ INFRASTRUCTURE ANALYSIS

**Good News**: Migration infrastructure is **100% complete** and ready to use!

### Existing Infrastructure

1. **`NetworkConstants` struct** (consolidated.rs)
   - Environment-driven configuration
   - Thread-safe initialization
   - All network constants supported

2. **`env_helpers` module** (defaults.rs)
   - Runtime environment lookups
   - Type-safe parsing
   - Fallback to defaults

3. **Environment variable patterns**
   - `NESTGATE_API_PORT`
   - `NESTGATE_BIND_ADDRESS`
   - 50+ variables documented

---

## 🎯 MIGRATION PATTERN

### Pattern 1: Replace Direct Constants

**Before** ❌:
```rust
// Hardcoded value
let port = 8080;
let addr = "localhost";
```

**After** ✅:
```rust
// Environment-driven
use nestgate_core::defaults::env_helpers;
let port = env_helpers::api_port();
let addr = env_helpers::hostname();
```

### Pattern 2: Replace Const Declarations

**Before** ❌:
```rust
pub const API_PORT: u16 = 8080;
pub const METRICS_PORT: u16 = 9090;
```

**After** ✅:
```rust
// Use runtime helpers instead
use nestgate_core::defaults::env_helpers;

pub fn api_port() -> u16 {
    env_helpers::api_port()
}

pub fn metrics_port() -> u16 {
    env_helpers::metrics_port()
}
```

### Pattern 3: Update Test Constants

**Before** ❌:
```rust
const TEST_PORT: u16 = 18080;
```

**After** ✅:
```rust
fn test_port() -> u16 {
    std::env::var("NESTGATE_TEST_PORT")
        .ok()
        .and_then(|s| s.parse().ok())
        .unwrap_or(18080)
}
```

---

## 📊 MIGRATION PRIORITIES

### Phase 1: High-Impact Files (Week 1) - 20-30 values

**Priority 1: API Server** (HIGHEST IMPACT)
- File: Already using `env_helpers` ✅
- Status: GOOD - minimal work needed

**Priority 2: Network Layer**
- Files:
  - `constants/hardcoding.rs`
  - `constants/ports.rs`  
  - `constants/canonical.rs`
- Replace: `pub const` with function calls
- Impact: 30-40 values

**Priority 3: Configuration**
- Files:
  - `config/canonical_primary/mod.rs`
  - `config/core.rs`
  - `config/runtime.rs`
- Replace: Const generics with runtime config
- Impact: 15-20 values

### Phase 2: Medium-Impact Files (Week 2) - 50-75 values

**Constants Consolidation**:
- `constants/consolidated.rs` - Already good structure
- `constants/network_defaults_config.rs`
- `constants/port_defaults_config.rs`

**Discovery Layer**:
- `universal_primal_discovery/` modules
- `service_discovery/` modules

### Phase 3: Low-Impact Files (Week 3-4) - 100+ values

**Test Files**: Update test constants
**Type Definitions**: Const generics in traits
**Documentation**: Update examples

---

## 🚀 QUICK START MIGRATION

### Example 1: Migrate `constants/hardcoding.rs`

**Current** (lines 41-47):
```rust
pub mod ports {
    pub const HTTP_DEFAULT: u16 = 8080;
    pub const API_DEFAULT: u16 = 3000;
    pub const METRICS_DEFAULT: u16 = 9090;
}
```

**Migrated**:
```rust
pub mod ports {
    use crate::defaults::env_helpers;
    
    /// Get HTTP port from environment or default (8080)
    pub fn http_default() -> u16 {
        env_helpers::api_port()
    }
    
    /// Get API port from environment or default (3000)
    pub fn api_default() -> u16 {
        std::env::var("NESTGATE_API_PORT")
            .ok()
            .and_then(|s| s.parse().ok())
            .unwrap_or(3000)
    }
    
    /// Get metrics port from environment or default (9090)
    pub fn metrics_default() -> u16 {
        env_helpers::metrics_port()
    }
}
```

### Example 2: Update Usages

**Before**:
```rust
use crate::constants::hardcoding::ports::API_DEFAULT;
let port = API_DEFAULT;
```

**After**:
```rust
use crate::constants::hardcoding::ports;
let port = ports::api_default();
```

---

## 📝 MIGRATION CHECKLIST

For each file:

- [ ] Identify all const declarations
- [ ] Check if env_helper exists
- [ ] Replace const with function
- [ ] Update all usages (const → function call)
- [ ] Add environment variable to docs
- [ ] Test with environment variable set
- [ ] Test with default value
- [ ] Verify all tests still pass

---

## 🎯 WEEK-BY-WEEK PLAN

### Week 1 (Dec 1-7): 20-30 values
Files:
- `constants/hardcoding.rs` - Priority ports
- `constants/ports.rs` - Core ports
- Test infrastructure

### Week 2 (Dec 8-14): 50-75 more values (cumulative: 70-105)
Files:
- `constants/consolidated.rs` - Network layer
- `config/canonical_primary/` - Configuration layer
- Service discovery constants

### Week 3 (Dec 15-21): 100-150 more values (cumulative: 170-255)
Files:
- Universal adapter constants
- Primal discovery constants
- Storage constants

### Week 4 (Dec 22-28): Remaining to 50% (cumulative: 685)
Files:
- Test constants
- Const generic defaults
- Documentation examples

---

## ✅ VERIFICATION STEPS

After each migration:

```bash
# 1. Verify tests pass
cargo test --lib --package nestgate-core

# 2. Verify with environment variable
NESTGATE_API_PORT=9999 cargo run --bin nestgate-api-server

# 3. Verify default still works
cargo run --bin nestgate-api-server

# 4. Check no regressions
cargo test --all
```

---

## 🚀 READY TO EXECUTE

**Infrastructure**: ✅ 100% Complete  
**Pattern**: ✅ Clear and documented  
**Examples**: ✅ Provided  
**Tools**: ✅ All exist

**Next Steps**:
1. Start with `constants/hardcoding.rs` ports module
2. Migrate 5-10 highest-impact constants first
3. Update usages systematically
4. Verify with tests
5. Document environment variables

---

**The hardest part (infrastructure) is done. Execution is now straightforward pattern application.**

*Created*: December 1, 2025  
*Ready for*: Immediate execution  
*Estimated*: 1-2 hours for first 20 values

