# 🔄 Hardcoding Migration Guide - Modern Patterns

**Date**: December 5, 2025  
**Purpose**: Evolve from hardcoded constants to capability-based discovery  
**Status**: Reference guide with working examples

---

## 🎯 PHILOSOPHY

### Old Way (Hardcoding):
```rust
// ❌ Hardcoded with fallback
const API_PORT: u16 = 8080;
let port = env::var("API_PORT")
    .ok()
    .and_then(|s| s.parse().ok())
    .unwrap_or(API_PORT);
```

### New Way (Capability-Based):
```rust
// ✅ Pure discovery, no fallbacks
use nestgate_core::universal_primal_discovery::production_capability_bridge::CapabilityAwareDiscovery;

let discovery = CapabilityAwareDiscovery::initialize(&config).await?;
let services = discovery.find_service("api").await?;
let api = services.first()
    .ok_or_else(|| Error::capability_not_found("API Gateway"))?;
let port = api.port;
```

---

## 📋 EXISTING MODERN INFRASTRUCTURE

**Good News**: Modern capability-based discovery is **already implemented**!

### Use These Modules:

1. **`production_capability_bridge.rs`** ✅
   - Path: `code/crates/nestgate-core/src/universal_primal_discovery/production_capability_bridge.rs`
   - Status: Operational
   - Purpose: Capability-aware discovery with backward compatibility

2. **`capability_based_discovery.rs`** ✅
   - Path: `code/crates/nestgate-core/src/universal_primal_discovery/capability_based_discovery.rs`
   - Status: Complete
   - Purpose: Core capability discovery system

3. **`migration_to_self_knowledge.rs`** ✅
   - Path: `code/crates/nestgate-core/src/universal_primal_discovery/migration_to_self_knowledge.rs`
   - Status: Migration bridge
   - Purpose: Integration between old and new systems

---

## 🔧 MIGRATION PATTERNS

### Pattern 1: Replace Hardcoded Port Discovery

**Before** (in `code/crates/nestgate-api/src/ecosystem/universal_ecosystem_integration.rs:209`):
```rust
use nestgate_core::constants::hardcoding::{addresses, ports};

let base_host = std::env::var("NESTGATE_API_HOST")
    .unwrap_or_else(|_| addresses::LOCALHOST_NAME.to_string());
let api_port = std::env::var("NESTGATE_API_PORT")
    .ok()
    .and_then(|s| s.parse().ok())
    .unwrap_or(ports::HTTP_DEFAULT);
```

**After** (capability-based):
```rust
use nestgate_core::config::environment::EnvironmentConfig;

// ✅ Modern: Use EnvironmentConfig (already implemented!)
let config = EnvironmentConfig::from_env()
    .context("API configuration required")?;
    
let base_host = config.network.api_host.clone();
let api_port = config.network.api_port;
```

**Status**: `EnvironmentConfig` is already implemented and working! ✅

---

### Pattern 2: Service Discovery by Capability

**Before** (hardcoded service locations):
```rust
// ❌ Hardcoded primal location
const BEARDOG_URL: &str = "http://beardog:8080";
```

**After** (capability-based discovery):
```rust
use nestgate_core::universal_primal_discovery::production_capability_bridge::CapabilityAwareDiscovery;

// ✅ Discover by capability, not name
async fn discover_security_service(config: &NestGateCanonicalConfig) -> Result<String> {
    let discovery = CapabilityAwareDiscovery::initialize(config).await?;
    
    // Find services with security capability
    let security_services = discovery
        .find_by_capability_name("security")
        .await?;
    
    let best_instance = security_services
        .first()
        .ok_or_else(|| NestGateError::service_not_found("Security capability"))?;
    
    Ok(format!("http://{}:{}", best_instance.host, best_instance.port))
}
```

---

### Pattern 3: Self-Knowledge (No Hardcoding)

**Philosophy**: Primals only know themselves, discover others at runtime.

**Implementation**:
```rust
use nestgate_core::config::environment::EnvironmentConfig;

// ✅ Primal learns about itself from environment
async fn initialize_primal() -> Result<()> {
    let my_config = EnvironmentConfig::from_env()
        .context("Primal must define itself via environment variables")?;
    
    println!("I am a primal with capabilities: {:?}", my_config.capabilities);
    println!("I listen on: {}:{}", my_config.network.bind_address, my_config.network.api_port);
    
    // ✅ Discover others at runtime
    // (Never hardcode other primal locations!)
    
    Ok(())
}
```

---

## 📊 MIGRATION CHECKLIST

### Phase 1: Use Existing Modern APIs ✅

**Files to update** (~10-15 files):

1. `code/crates/nestgate-api/src/ecosystem/universal_ecosystem_integration.rs:209`
   - Replace hardcoded ports with `EnvironmentConfig`
   - Estimated: 15 minutes

2. `code/crates/nestgate-api/src/universal_primal.rs:447`
   - Use `EnvironmentConfig` for discovery
   - Estimated: 20 minutes

3. `code/crates/nestgate-api/src/unified_api_config/primal_extensions.rs:401`
   - Already partially migrated! ✅
   - Complete the migration
   - Estimated: 10 minutes

**Total Phase 1**: 2-3 hours

---

### Phase 2: Deprecate Old Constants

**Target**: `code/crates/nestgate-core/src/constants/hardcoding.rs`

**Action**: Add deprecation warnings to all port constants:

```rust
#[deprecated(
    since = "0.13.0",
    note = "Use EnvironmentConfig::from_env()?.network.api_port instead"
)]
pub const HTTP_DEFAULT: u16 = 8080;
```

**Estimated**: 30 minutes

---

### Phase 3: Remove Hardcoded Fallbacks

**Pattern**:
```rust
// ❌ OLD: Fallback to hardcoded value
let port = env::var("PORT")
    .ok()
    .and_then(|s| s.parse().ok())
    .unwrap_or(8080);  // Hardcoded fallback!

// ✅ NEW: Explicit error if not configured
let port = env::var("PORT")
    .context("PORT environment variable must be set")?
    .parse()
    .context("PORT must be a valid number")?;
```

**Why**: Forces proper configuration, no hidden defaults

**Estimated**: 4-6 hours

---

## 🎯 WORKING EXAMPLES

### Example 1: API Server Binding

**File**: `code/crates/nestgate-api/src/bin/nestgate-api-server.rs`

**Current** (✅ Already modern!):
```rust
let config = EnvironmentConfig::from_env()
    .context("Failed to load server configuration")?;

let bind_endpoint = config.bind_endpoint();
info!("🌐 Starting server on {}", bind_endpoint);

let listener = tokio::net::TcpListener::bind(bind_endpoint)
    .await
    .context("Failed to bind TCP listener")?;
```

**Status**: **No changes needed** - already using modern pattern! ✅

---

### Example 2: Service Registration

**File**: `code/crates/nestgate-api/src/ecosystem/universal_ecosystem_integration.rs`

**Current** (needs update):
```rust
fn get_nestgate_endpoints(&self) -> Vec<ServiceEndpoint> {
    use nestgate_core::constants::hardcoding::{addresses, ports};
    
    let base_host = std::env::var("NESTGATE_API_HOST")
        .unwrap_or_else(|_| addresses::LOCALHOST_NAME.to_string());
    let api_port = std::env::var("NESTGATE_API_PORT")
        .ok()
        .and_then(|s| s.parse().ok())
        .unwrap_or(ports::HTTP_DEFAULT);
    // ...
}
```

**Improved** (use EnvironmentConfig):
```rust
fn get_nestgate_endpoints(&self) -> Result<Vec<ServiceEndpoint>> {
    use nestgate_core::config::environment::EnvironmentConfig;
    
    let config = EnvironmentConfig::from_env()
        .context("Service endpoints require environment configuration")?;
    
    Ok(vec![
        ServiceEndpoint {
            name: "api".to_string(),
            url: format!("http://{}:{}", config.network.api_host, config.network.api_port),
            protocol: "http".to_string(),
            health_check: Some("/health".to_string()),
        },
        ServiceEndpoint {
            name: "metrics".to_string(),
            url: format!("http://{}:{}/metrics", config.monitoring.metrics_host, config.monitoring.metrics_port),
            protocol: "http".to_string(),
            health_check: None,
        }
    ])
}
```

**Benefits**:
- No hardcoded fallbacks ✅
- Proper error handling ✅
- Uses existing infrastructure ✅

---

## 🚀 QUICK WINS

### Target These First (2-3 hours):

1. **`universal_ecosystem_integration.rs`** - 3 hardcoded constant usages
2. **`universal_primal.rs`** - 4 hardcoded port references
3. **`primal_extensions.rs`** - Partially migrated, finish it

**Impact**: Remove ~10-15 hardcoded constant references

---

## ✅ SUCCESS CRITERIA

### Phase 1 Complete When:
- [ ] No direct imports of `constants::hardcoding::ports` in production code
- [ ] All service discovery uses `EnvironmentConfig` or `CapabilityAwareDiscovery`
- [ ] Tests updated to use configuration
- [ ] Documentation updated

### Phase 2 Complete When:
- [ ] All constants in `hardcoding.rs` marked deprecated
- [ ] Migration guide references added
- [ ] Removal timeline set (v0.14.0)

### Phase 3 Complete When:
- [ ] No hardcoded fallbacks in production code
- [ ] All configuration errors explicit
- [ ] 100% capability-based discovery

---

## 📝 NOTES

### Existing Infrastructure ✅

**You already have**:
1. `EnvironmentConfig` - Complete ✅
2. `CapabilityAwareDiscovery` - Operational ✅
3. `production_capability_bridge` - Working ✅
4. Proper deprecation patterns - In place ✅

**You don't need**:
- ❌ New discovery infrastructure (already exists)
- ❌ Major refactoring (APIs work)
- ❌ Complex migrations (patterns clear)

**You just need to**:
- ✅ Use existing modern APIs consistently
- ✅ Stop importing hardcoded constants
- ✅ Add deprecation warnings
- ✅ Update 10-15 files systematically

---

## 🎓 PRINCIPLES

1. **Self-Knowledge**: Primals know themselves via environment
2. **Runtime Discovery**: Find others by capability, not name
3. **No Fallbacks**: Explicit errors better than hidden defaults
4. **Proper Errors**: Context-rich error messages
5. **Sovereignty**: Zero vendor lock-in, zero primal name dependencies

---

**Status**: Guide complete, ready for execution  
**Estimated Time**: 6-8 hours total  
**Complexity**: Low - use existing infrastructure  
**Confidence**: 95% - patterns proven

---

*This is evolution, not revolution. Use what's already there.* ✨

