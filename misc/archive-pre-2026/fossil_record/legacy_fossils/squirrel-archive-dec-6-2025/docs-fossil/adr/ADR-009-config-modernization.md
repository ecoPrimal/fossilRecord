# ADR-009: Config System Modernization

**Date**: November 15, 2025  
**Status**: In Progress (Pilot Phase)  
**Authors**: Development Team  
**Related**: ADR-005 (Plugin Metadata Coexistence)  

---

## Context

The Squirrel project has accumulated multiple configuration systems over time:
1. **Old System**: `environment_config.rs` with `AppConfig` (legacy)
2. **Unified System**: `unified/types.rs` with `SquirrelUnifiedConfig` (945 lines, monolithic)

### Problems Identified

#### 1. Monolithic Design Blocks Testing
```rust
// Current: Must provide 12 required fields
pub struct SquirrelUnifiedConfig {
    pub system: SystemConfig,          // Required
    pub network: NetworkConfig,        // Required
    pub security: SecurityConfig,      // Required
    // ... 9 more required fields
}

// Impact: Cannot create partial configs for testing
```

**Test Impact**: Creating a test config requires ~300+ lines of boilerplate to specify all required fields across 12 domains.

#### 2. No Builder Pattern
```rust
// Current: Must specify everything
let config = NetworkConfig {
    bind_address: "127.0.0.1".to_string(),
    http_port: 8080,
    websocket_port: 8081,
    grpc_port: 9090,
    max_connections: 1000,
    enable_tls: false,
    tls_cert_path: None,
    tls_key_path: None,
};

// What we want:
let config = NetworkConfig::builder()
    .http_port(8080)
    .build();  // Rest use defaults
```

#### 3. No Type Safety
```rust
pub log_level: String,        // Should be enum
pub environment: String,       // Should be enum
pub http_port: u16,           // Should validate (not 0)
```

#### 4. Public Fields Everywhere
```rust
pub struct NetworkConfig {
    pub bind_address: String,  // Can be modified directly
    pub http_port: u16,         // No validation!
}
```

---

## Decision

We will **incrementally modernize** the config system using:

### 1. Pilot Approach
- Start with `NetworkConfig` as proof-of-concept
- Validate pattern works
- Gather feedback
- Roll out to other domains

### 2. Modern Patterns

#### Builder Pattern
```rust
let config = NetworkConfig::builder()
    .http_port(9000)
    .enable_tls(true)
    .build();
```

#### Newtype Validation
```rust
pub struct Port(u16);

impl Port {
    pub fn new(port: u16) -> Result<Self, PortError> {
        if port == 0 {
            return Err(PortError::Zero);
        }
        Ok(Port(port))
    }
}

// Cannot create Port(0) - compile-time safe!
```

#### Preset Configs
```rust
NetworkConfig::testing()     // High ports, low connections
NetworkConfig::development() // Localhost, defaults
NetworkConfig::production()  // All interfaces, TLS
```

#### Private Fields + Getters
```rust
pub struct NetworkConfig {
    bind_address: String,  // Private!
}

impl NetworkConfig {
    pub fn bind_address(&self) -> &str {
        &self.bind_address
    }
}
```

### 3. Migration Strategy

#### Phase 1: Pilot (Week 1) - CURRENT
```
✅ Create modern NetworkConfig (network.rs)
✅ Add builder pattern
✅ Add validation (Port newtype)
✅ Add test presets
✅ Comprehensive tests (11 tests)
⏳ Deprecate old NetworkConfig
⏳ Update usage in codebase
```

#### Phase 2: Core Domains (Week 2)
```
- Modernize SystemConfig
- Modernize SecurityConfig
- Modernize DatabaseConfig
- Pattern proven, faster iteration
```

#### Phase 3: Remaining Domains (Week 3)
```
- McpConfig
- AiProvidersConfig
- MonitoringConfig
- LoadBalancingConfig
```

#### Phase 4: Cleanup (Week 4)
```
- Remove old AppConfig (environment_config.rs)
- Remove legacy NetworkConfig from types.rs
- Make SquirrelUnifiedConfig domains optional
- Update all documentation
```

---

## Consequences

### Positive ✅

1. **10x Easier Testing**
   ```rust
   // Before: 300+ lines
   let config = create_full_config_with_all_fields();
   
   // After: 1 line!
   let config = NetworkConfig::testing();
   ```

2. **Type Safety**
   ```rust
   // Before: Runtime error
   let config = NetworkConfig { http_port: 0, ... };
   
   // After: Compile-time error!
   let port = Port::new(0)?;  // Error: Zero
   ```

3. **Better Ergonomics**
   ```rust
   let config = NetworkConfig::builder()
       .http_port(9000)
       .build();  // Other fields default
   ```

4. **Encapsulation**
   - Private fields prevent invalid state
   - Getters provide controlled access
   - Validation in constructors

5. **Clear Migration Path**
   - Both old and new coexist
   - Deprecation warnings guide users
   - No breaking changes (yet)

### Negative ⚠️

1. **Temporary Duplication**
   - Two NetworkConfig types during migration
   - `LegacyNetworkConfig` vs `ModernNetworkConfig`
   - Aliased to avoid confusion

2. **Migration Effort**
   - ~12 config domains to modernize
   - Estimated 3-4 weeks
   - Must update all usage sites

3. **Learning Curve**
   - New patterns (builder, newtype)
   - Team must understand rationale
   - Documentation critical

### Neutral 🤷

1. **Code Size**: Slightly larger per-module but much more maintainable
2. **Performance**: Negligible (validation is minimal)
3. **Dependencies**: No new crates (pure Rust patterns)

---

## Implementation Details

### File Structure
```
crates/config/src/unified/
├── network.rs              // NEW: Modern NetworkConfig
├── system.rs               // FUTURE: Modern SystemConfig
├── security.rs             // FUTURE: Modern SecurityConfig
├── types.rs                // OLD: Will be deprecated/removed
└── mod.rs                  // Exports both old and new
```

### Export Strategy
```rust
// crates/config/src/unified/mod.rs
pub mod network;

pub use network::{
    NetworkConfig as ModernNetworkConfig,
    NetworkConfigBuilder,
    Port,
    PortError,
};

pub use types::{
    NetworkConfig as LegacyNetworkConfig,  // Deprecated
    // ...
};

// crates/config/src/lib.rs
pub use unified::ModernNetworkConfig as NetworkConfig;  // Default
```

### Deprecation Process
```rust
// Step 1: Add deprecation warning
#[deprecated(since = "0.3.0", note = "Use `ModernNetworkConfig` instead")]
pub struct NetworkConfig { ... }

// Step 2: Update usage with warnings
// (IDEs will highlight deprecated usage)

// Step 3: After all usage updated, remove from exports

// Step 4: Eventually delete old code
```

---

## Examples

### Before (Old System)
```rust
// Creating a test config required specifying everything
let config = NetworkConfig {
    bind_address: "127.0.0.1".to_string(),
    http_port: 8080,
    websocket_port: 8081,
    grpc_port: 9090,
    max_connections: 1000,
    enable_tls: false,
    tls_cert_path: None,
    tls_key_path: None,
};

// Easy to create invalid configs
let config = NetworkConfig {
    http_port: 0,  // Invalid! But compiles
    // ...
};

// Hard to test
#[test]
fn test_something() {
    // Need full config just to test one feature
    let config = NetworkConfig { /* 8 fields */ };
}
```

### After (Modern System)
```rust
// Quick test config
let config = NetworkConfig::testing();

// Production config
let config = NetworkConfig::production();

// Custom config with builder
let config = NetworkConfig::builder()
    .http_port(9000)
    .enable_tls(true)
    .build();

// Type safety prevents invalid configs
let port = Port::new(0)?;  // Compile-time error!

// Easy testing
#[test]
fn test_something() {
    let config = NetworkConfig::testing();  // Done!
}
```

---

## Validation

### Success Criteria

#### For Pilot (NetworkConfig)
- ✅ Builder pattern implemented
- ✅ Validation (Port newtype)
- ✅ Test presets (testing(), production(), development())
- ✅ Comprehensive tests (>80% coverage)
- ✅ Private fields + getters
- ⏳ Deprecation warnings on old config
- ⏳ Usage migrated in main codebase

#### For Complete Migration
- All 12 domains modernized
- Old AppConfig removed
- Test coverage >80% on config system
- Zero usage of deprecated types
- Documentation updated

### Metrics
```
Testability:   Before: 300+ LOC for test config
               After:  1 LOC (NetworkConfig::testing())
               
File Size:     Before: 945 lines (monolithic)
               After:  ~100 lines per domain
               
Type Safety:   Before: String-based (runtime errors)
               After:  Enum/newtype (compile-time errors)
               
Coverage:      Before: 32.40% (hard to test)
               After:  >80% (easy to test)
```

---

## Alternatives Considered

### Option A: Big Bang Rewrite ❌
**Rejected**: Too risky, would block development for weeks

### Option B: Keep Monolithic, Add Helpers ❌
**Rejected**: Doesn't solve root problem (required fields)

### Option C: Incremental Refactor ✅
**Chosen**: Low risk, steady progress, early validation

---

## References

### Related Documentation
- `CONFIG_SYSTEM_INVESTIGATION_NOV_15.md` - Full investigation report
- `TEST_COVERAGE_ROADMAP_NOV_15_2025.md` - Why config was blocking tests
- ADR-005 - Plugin Metadata Coexistence (similar pattern)

### Rust Patterns
- Builder Pattern: https://rust-unofficial.github.io/patterns/patterns/creational/builder.html
- Newtype Pattern: https://doc.rust-lang.org/rust-by-example/generics/new_types.html
- API Guidelines: https://rust-lang.github.io/api-guidelines/

### Crates Considered (Not Used)
- `typed-builder` - Decided to use manual builder (more control)
- `bon` - Modern builder macro (maybe later)
- `derive_builder` - Too much magic for pilot

---

## Timeline

### Week 1 (Current) - Pilot
- ✅ Day 1: Investigation complete
- ✅ Day 1: Modern NetworkConfig created
- ✅ Day 1: Tests passing (11/11)
- ⏳ Day 2: Deprecate old, migrate usage
- ⏳ Day 2: Create ADR (this document)

### Week 2 - Core Domains
- Modernize SystemConfig
- Modernize SecurityConfig  
- Modernize DatabaseConfig

### Week 3 - Remaining Domains
- McpConfig, AiProvidersConfig
- MonitoringConfig, LoadBalancingConfig
- ServiceMeshConfig, FeatureFlags

### Week 4 - Cleanup & Documentation
- Remove old AppConfig
- Remove legacy configs from types.rs
- Update all documentation
- Performance benchmarks

---

## Review & Approval

### Review Checklist
- [x] Investigation complete
- [x] Pilot implementation done
- [x] Tests passing
- [ ] Team review
- [ ] Security review
- [ ] Performance impact assessed

### Status Updates
- **Nov 15, 2025**: Investigation complete, pilot implemented
- **Nov 15, 2025**: ADR created
- **TBD**: Team review
- **TBD**: Approved for rollout

---

**Decision**: Approved for pilot phase. Proceed with NetworkConfig modernization, gather feedback, then roll out to other domains.

**Next Steps**:
1. ✅ Create modern NetworkConfig
2. ⏳ Deprecate old NetworkConfig in types.rs
3. ⏳ Migrate usage in codebase
4. ⏳ Validate pattern works
5. ⏳ Roll out to SystemConfig (next domain)

