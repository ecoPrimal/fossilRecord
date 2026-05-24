# ADR-008: Configuration Standardization

**Date**: November 10, 2025  
**Status**: ✅ Accepted  
**Decision Makers**: Engineering Team  
**Supersedes**: None  
**Related**: ADR-004 (Configuration Unification)

---

## Context

After completing 8 weeks of unification work, Squirrel has achieved 90% configuration unification with the `squirrel-mcp-config` crate. However, we have:

- **383 Config struct definitions** across the codebase
- **Multiple naming patterns**: Config, Configuration, Settings, etc.
- **Deprecated type aliases** for backward compatibility
- **Need for standardization** to maintain long-term consistency

This ADR establishes **configuration standardization principles** for continued excellence.

---

## Decision

We adopt the following configuration standards:

### 1. **Canonical Package: `squirrel-mcp-config`**

✅ **Decision**: `squirrel-mcp-config` is the **canonical configuration package**.

**Rationale**:
- Already established and working
- 90% of codebase uses it
- Provides unified configuration system
- Environment-driven (12-factor principles)

### 2. **Type Naming Standard**

✅ **Primary Types** (Use These):
```rust
use squirrel_mcp_config::{
    SquirrelUnifiedConfig,  // Main config (not "Config")
    ConfigLoader,           // Config loader (not "DefaultConfigManager")
    SecurityConfig,         // Domain configs
    NetworkConfig,
    McpConfig,
    // ... etc
};
```

⚠️ **Deprecated Aliases** (Avoid in New Code):
```rust
// Deprecated since 0.2.0
pub type Config = SquirrelUnifiedConfig;
pub type DefaultConfigManager = ConfigLoader;
```

**Rationale**:
- Explicit names reduce ambiguity
- `SquirrelUnifiedConfig` clearly indicates the unified system
- `ConfigLoader` describes functionality better than "Manager"
- Domain-specific configs use descriptive names

### 3. **Import Patterns**

✅ **Preferred**:
```rust
// Option A: Direct imports
use squirrel_mcp_config::{SquirrelUnifiedConfig, ConfigLoader};

// Option B: Module-qualified (for clarity)
use squirrel_mcp_config::unified::{SquirrelUnifiedConfig, ConfigLoader};
```

❌ **Discouraged** (but allowed for compatibility):
```rust
use squirrel_mcp_config::{Config, DefaultConfigManager};  // Deprecated
```

### 4. **Naming Convention**

✅ **Standard**: `XxxConfig` (not Configuration, Settings, Options)

**Examples**:
```rust
pub struct NetworkConfig { ... }     // ✅ Good
pub struct SecurityConfig { ... }    // ✅ Good
pub struct McpConfiguration { ... }  // ❌ Inconsistent
pub struct SystemSettings { ... }    // ❌ Inconsistent
```

**Rationale**:
- Consistency aids searchability
- `Config` suffix is Rust community standard
- Shorter, clearer names

### 5. **Validation Strategy**

✅ **Centralized validation** in `config/validation/` module (future):

```rust
pub trait ConfigValidator {
    fn validate(&self) -> Result<()>;
    fn warnings(&self) -> Vec<String>;
}
```

**Rationale**:
- Single source of truth for validation
- Easier to test
- Consistent error messages
- Separation of concerns

### 6. **Environment Variables**

✅ **Standard prefix**: `SQUIRREL_*`

**Examples**:
```bash
SQUIRREL_CONNECTION_TIMEOUT_SECS=30
SQUIRREL_REQUEST_TIMEOUT_SECS=60
SQUIRREL_MCP_SERVER_ADDRESS=localhost:8080
```

**Legacy prefix**: `MCP_*` (still supported for compatibility)

**Rationale**:
- Clear namespace
- Avoids conflicts
- Easy to filter/search
- Follows 12-factor app principles

### 7. **Backward Compatibility**

✅ **Gradual migration** approach:

1. **Deprecated aliases remain** until version 1.0
2. **Deprecation warnings** guide developers to new names
3. **Documentation** shows migration paths
4. **No breaking changes** in minor versions

**Migration Timeline**:
- **v0.2.0** (current): Deprecated aliases introduced
- **v0.3.0-v0.9.0**: Gradual migration period
- **v1.0.0**: Remove deprecated aliases (breaking change)

---

## Consequences

### Positive

1. ✅ **Clear Standards**: Developers know exactly how to structure configs
2. ✅ **Consistency**: Uniform naming across 383+ config structs
3. ✅ **Maintainability**: Easier to locate and update configurations
4. ✅ **Searchability**: Standard patterns enable quick grep/search
5. ✅ **Professionalism**: Industry-standard practices
6. ✅ **Backward Compatibility**: Existing code continues to work

### Negative

1. ⚠️ **Migration Effort**: Existing code will need gradual updates
2. ⚠️ **Learning Curve**: Team needs to learn new conventions
3. ⚠️ **Deprecation Warnings**: Will see warnings until migration complete
4. ⚠️ **Documentation Updates**: Need to update examples and guides

### Neutral

1. 📝 **More Explicit Names**: Longer type names (SquirrelUnifiedConfig vs Config)
2. 📝 **Transition Period**: Coexistence of old and new patterns during migration

---

## Implementation Status

### Completed ✅
- [x] Configuration system unified (90%)
- [x] Canonical package established (`squirrel-mcp-config`)
- [x] Deprecated aliases created for compatibility
- [x] Environment variable standards defined
- [x] ADR-008 documented

### In Progress ⏳
- [ ] Config validation unification (Week 2 of action plan)
- [ ] Migration of deprecated usage (gradual, ongoing)
- [ ] Documentation updates (Week 1 of action plan)

### Planned 📅
- [ ] Create `config/validation/` module (Week 2)
- [ ] Comprehensive migration guide
- [ ] Type registry system (optional, future)
- [ ] Remove deprecated aliases (v1.0.0)

---

## Migration Guide

### For New Code

✅ **Always use new names**:
```rust
use squirrel_mcp_config::{
    SquirrelUnifiedConfig,
    ConfigLoader,
    SecurityConfig,
};

fn initialize_config() -> Result<SquirrelUnifiedConfig> {
    ConfigLoader::load_from_env()
}
```

### For Existing Code

⚠️ **Two options**:

**Option A: Leave as-is** (if working)
```rust
// Keep using deprecated names temporarily
use squirrel_mcp_config::{Config, DefaultConfigManager};
// Migrate later when convenient
```

**Option B: Update proactively** (preferred)
```rust
// Before
use squirrel_mcp_config::Config;

// After
use squirrel_mcp_config::SquirrelUnifiedConfig;
```

### Batch Migration

```bash
# Find deprecated usage
grep -r "use squirrel_mcp_config::Config;" crates/

# Replace (carefully!)
# Review each file to ensure context is correct
```

---

## Examples

### ✅ Good Configuration Pattern

```rust
//! Network configuration module

use squirrel_mcp_config::{NetworkConfig, ConfigLoader};
use std::time::Duration;

pub fn setup_network() -> Result<NetworkConfig> {
    // Load unified config
    let config = ConfigLoader::load_from_env()?;
    
    // Extract network config
    Ok(config.network)
}
```

### ❌ Anti-Pattern (Avoid)

```rust
// Multiple naming styles
pub struct NetworkConfiguration { ... }  // Inconsistent suffix
pub struct SecuritySettings { ... }      // Wrong suffix
pub struct McpOptions { ... }            // Wrong suffix

// Using deprecated types in new code
use squirrel_mcp_config::Config;  // Deprecated!
```

---

## Validation

### Compliance Check

```bash
# Check for deprecated usage
grep -r "use.*::Config;" crates/ | wc -l

# Check for non-standard naming
grep -r "pub struct.*Configuration" crates/ | wc -l
grep -r "pub struct.*Settings" crates/ | wc -l
```

### Expected Results (After Full Migration)

```
Deprecated `Config` usage:         0 instances
Deprecated `DefaultConfigManager`: 0 instances
Non-standard naming:               0 instances
Standard `XxxConfig` pattern:      100% compliance
```

---

## References

### Related Documentation
- **ADR-004**: Configuration Unification (initial unification decision)
- **UNIFICATION_MODERNIZATION_REPORT_NOV_10_2025.md**: Current state analysis
- **NEXT_30_DAYS_ACTION_PLAN.md**: Week 2 validation unification plan

### Rust Standards
- [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/)
- [12-Factor App](https://12factor.net/) - Configuration principles

### Squirrel Documentation
- `crates/config/src/lib.rs` - Config crate documentation
- `crates/config/README.md` - Usage examples
- `universal-constants/README.md` - Constants standardization

---

## Review and Updates

**Next Review**: December 10, 2025  
**Review Trigger**: Version 1.0.0 preparation  
**Update Frequency**: As needed for major changes

---

## Appendix: Current State (Nov 10, 2025)

### Package Statistics
```
Total Config Structs:      383
Unified in main package:   ~90%
Deprecated alias usage:    13 active imports
Standard naming:           ~95% compliance
```

### Import Patterns Found
```
Pattern                                 Count   Status
────────────────────────────────────────────────────────
use squirrel_mcp_config::Config;        4       ⚠️ Deprecated
use squirrel_mcp_config::DefaultConfig  1       ⚠️ Deprecated
  Manager;
use squirrel_mcp_config::unified::*;    6       ✅ Good
use squirrel_mcp_config::XxxConfig;     2       ✅ Good
```

---

**Status**: ✅ **ACCEPTED AND DOCUMENTED**  
**Implementation**: GRADUAL (ongoing)  
**Target**: v1.0.0 for full compliance

---

**Created**: November 10, 2025  
**Last Updated**: November 10, 2025  
**Version**: 1.0  
**Author**: Engineering Team

