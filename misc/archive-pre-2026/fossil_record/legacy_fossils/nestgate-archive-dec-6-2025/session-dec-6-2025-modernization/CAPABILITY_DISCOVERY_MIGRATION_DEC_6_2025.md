# 🎯 CAPABILITY-BASED DISCOVERY MIGRATION
## Phase 4: Self-Knowledge & Runtime Discovery

**Date**: December 6, 2025  
**Status**: 🔄 IN PROGRESS  
**Philosophy**: Self-knowledge only - discover at runtime, never assume

---

## 📊 DISCOVERY: Already Well-Structured!

### **Excellent Foundation Found** ✅

The codebase analysis reveals **strong capability-based infrastructure already exists**:

**Existing Capability Infrastructure**:
1. ✅ `production_capability_bridge` - Modern capability-aware discovery
2. ✅ `ServiceDiscoveryConfig` - Environment-driven configuration
3. ✅ `RuntimeConfig` - Dynamic port allocation (no hardcoding!)
4. ✅ Deprecation notices - Old APIs marked, migration path clear

**Key Finding**: **Migration is already in progress!**
- Old hardcoded APIs marked `#[deprecated]`
- New capability-based APIs operational
- Clear migration documentation exists
- Backward compatibility maintained

---

## 🔍 CURRENT STATE ANALYSIS

### **Configuration Patterns Found**

#### **✅ GOOD: Environment-Driven (Modern)**
```rust
// From config/runtime_config.rs - EXCELLENT PATTERN!
pub fn service_endpoint(&self, service_type: &str) -> String {
    if let Some(endpoint) = self.network.service_endpoints.get(service_type) {
        endpoint.clone()
    } else {
        // Dynamic generation instead of hardcoding
        let port = self.dynamic_port_for_service(service_type);
        format!("http://{}:{}", self.network.hostname, port)
    }
}

// Dynamic port allocation - deterministic but not hardcoded
fn dynamic_port_for_service(&self, service_type: &str) -> u16 {
    let base_port = self.network.api_port; // From environment!
    let service_offset = match service_type {
        "api" => 0,
        "websocket" => 1,
        // ... deterministic offsets
        _ => {
            // Hash-based for unknown services - smart!
            let hash = service_type.bytes().fold(0u16, |acc, b| 
                acc.wrapping_add(b as u16));
            10 + (hash % 100)
        }
    };
    base_port + service_offset
}
```

**Assessment**: ✅ **This is excellent!** No hardcoded ports, environment-driven base with deterministic offsets.

---

#### **⚠️ NEEDS EVOLUTION: Capability with Hardcoded Fallback**
```rust
// From config/runtime/services.rs - ALMOST THERE
pub fn capability_url_or_local(&self, capability: &str) -> String {
    use crate::constants::hardcoding::{addresses, ports};
    
    let port = match capability {
        "security" => ports::SECURITY_SERVICE_DEFAULT,      // ❌ Hardcoded
        "networking" => ports::NETWORKING_SERVICE_DEFAULT,  // ❌ Hardcoded
        _ => ports::API_DEFAULT,                            // ❌ Hardcoded
    };
    
    self.get_capability_url(capability)
        .unwrap_or_else(|| format!("http://{}:{}", addresses::LOCALHOST_NAME, port))
        // ⬆️ Falls back to hardcoded when discovery fails
}
```

**Problem**: Uses hardcoded ports as fallback  
**Solution**: Return `Option` or `Result`, force caller to handle discovery failure

---

#### **✅ GOOD: Pure Capability Discovery**
```rust
// From production_discovery.rs - EXCELLENT!
#[deprecated(since = "0.12.0", 
    note = "Use CapabilityAwareDiscovery from production_capability_bridge")]
```

**Assessment**: ✅ Old APIs properly deprecated, migration path documented

---

## 🎯 MIGRATION STRATEGY

### **Principle: Progressive Enhancement**

**NOT**: Remove all fallbacks immediately (breaks development)  
**YES**: Add capability-first with explicit fallback handling

### **Three-Tier Approach**

#### **Tier 1: Production** (No Fallbacks)
```rust
// ❌ OLD: Hardcoded fallback
let url = config.capability_url_or_local("security");

// ✅ NEW: Explicit error handling
let url = config.get_capability_url("security")
    .ok_or_else(|| Error::ServiceNotFound {
        capability: "security".to_string(),
        suggestion: "Set NESTGATE_CAPABILITY_SECURITY environment variable"
    })?;
```

#### **Tier 2: Development** (Explicit Fallback)
```rust
// ✅ GOOD: Explicit development fallback
let url = config.get_capability_url("security")
    .or_else(|| {
        if config.is_development() {
            tracing::warn!("Security service not discovered, using localhost:9090 for development");
            Some("http://localhost:9090".to_string())
        } else {
            None
        }
    })
    .ok_or_else(|| Error::ServiceNotFound { capability: "security" })?;
```

#### **Tier 3: Testing** (Test Doubles)
```rust
// ✅ BEST: Test doubles, not hardcoding
#[cfg(test)]
fn test_with_mock_service() {
    let mut config = Config::new_for_test();
    config.set_capability_url("security", "http://localhost:12345"); // Test server
    
    // Test code uses discovered URL
    let result = use_security_service(&config).await?;
    assert!(result.is_ok());
}
```

---

## 📋 CONCRETE MIGRATION EXAMPLES

### **Example 1: Migrate `capability_url_or_local`**

**Current Code** (config/runtime/services.rs:252):
```rust
pub fn capability_url_or_local(&self, capability: &str) -> String {
    use crate::constants::hardcoding::{addresses, ports};

    let port = match capability {
        "security" => ports::SECURITY_SERVICE_DEFAULT,
        "networking" | "orchestration" => ports::NETWORKING_SERVICE_DEFAULT,
        _ => ports::API_DEFAULT,
    };

    self.get_capability_url(capability)
        .unwrap_or_else(|| format!("http://{}:{}", addresses::LOCALHOST_NAME, port))
}
```

**Evolved Code**:
```rust
/// Get capability URL with environment-aware fallback
///
/// **PRODUCTION**: Returns error if not discovered
/// **DEVELOPMENT**: Falls back to localhost with warning
/// **TEST**: Uses test configuration
pub fn capability_url(&self, capability: &str) -> Result<String> {
    // Try discovery first
    if let Some(url) = self.get_capability_url(capability) {
        return Ok(url);
    }

    // Production: No fallback, return error
    if self.is_production() {
        return Err(Error::CapabilityNotDiscovered {
            capability: capability.to_string(),
            help: format!(
                "Set NESTGATE_CAPABILITY_{} environment variable or ensure service discovery is running",
                capability.to_uppercase()
            ),
        });
    }

    // Development: Explicit fallback with warning
    if self.is_development() {
        tracing::warn!(
            capability = %capability,
            "Capability not discovered, using localhost fallback for development"
        );
        
        // Dynamic port allocation even for fallback
        let base_port = std::env::var("NESTGATE_DEV_BASE_PORT")
            .ok()
            .and_then(|s| s.parse().ok())
            .unwrap_or(8000);
        
        let port = self.dynamic_port_for_capability(capability, base_port);
        return Ok(format!("http://localhost:{}", port));
    }

    // Unknown environment: require explicit configuration
    Err(Error::CapabilityNotDiscovered {
        capability: capability.to_string(),
        help: "Capability discovery failed and environment is not development".to_string(),
    })
}

/// Dynamic port allocation for capability (deterministic, not hardcoded)
fn dynamic_port_for_capability(&self, capability: &str, base_port: u16) -> u16 {
    let offset = match capability {
        "api" => 0,
        "security" => 1,
        "orchestration" => 2,
        "compute" => 3,
        "ai" => 4,
        "storage" => 5,
        _ => {
            // Hash-based offset for custom capabilities
            let hash = capability.bytes().fold(0u16, |acc, b| 
                acc.wrapping_add(b as u16));
            10 + (hash % 100)
        }
    };
    base_port + offset
}
```

**Benefits**:
- ✅ Production: No silent fallbacks (fail fast)
- ✅ Development: Explicit warnings when using fallbacks
- ✅ Testing: Can inject test URLs
- ✅ Still no hardcoded ports (dynamic allocation)
- ✅ Clear error messages guide configuration

---

### **Example 2: Primal Discovery Pattern**

**Current**: Some code assumes primals at specific URLs  
**Evolution**: Discover capabilities, map to primals

```rust
/// Discover services offering security capabilities
///
/// This finds ANY service offering security, not just "BearDog"
/// Self-knowledge: We know what we need (security), not who provides it
pub async fn discover_security_provider(&self) -> Result<Vec<ServiceInfo>> {
    // 1. Check explicit configuration first
    if let Some(url) = std::env::var("NESTGATE_CAPABILITY_SECURITY").ok() {
        return Ok(vec![ServiceInfo {
            url,
            capabilities: vec!["security".to_string()],
            primal_name: None, // Don't care who provides it!
        }]);
    }

    // 2. Active discovery - ask the network
    let discovered = self.capability_scanner
        .scan_for_capability("security")
        .await?;

    if !discovered.is_empty() {
        tracing::info!(
            "Discovered {} service(s) offering security capability",
            discovered.len()
        );
        return Ok(discovered);
    }

    // 3. Production: Error
    if self.is_production() {
        return Err(Error::NoSecurityProvider {
            help: "Set NESTGATE_CAPABILITY_SECURITY or ensure a security service is discoverable"
        });
    }

    // 4. Development: Log warning, return empty (graceful degradation)
    tracing::warn!("No security provider discovered in development mode");
    Ok(vec![])
}
```

**Key Principles**:
1. **Environment first** - Explicit config always wins
2. **Discovery second** - Ask the network what's available
3. **Production fails fast** - No silent fallbacks
4. **Development gracefully degrades** - With warnings
5. **Never assume** - Don't hardcode "BearDog at :9090"

---

## 📈 MIGRATION PROGRESS

### **Already Completed** ✅
1. Infrastructure exists (capability bridge, discovery)
2. Old APIs deprecated
3. Environment-driven config operational
4. Dynamic port allocation working

### **In Progress** 🔄
1. Complete capability_url_or_local evolution
2. Remove hardcoded fallback ports
3. Add proper error types for discovery failures

### **Remaining Work** 📋
1. Migrate ~240 hardcoded localhost/IP references
2. Add discovery tests for all capabilities
3. Document capability registration
4. Create discovery troubleshooting guide

---

## 🎯 IMPLEMENTATION PLAN

### **Week 1: Core API Evolution**
- [ ] Evolve `capability_url_or_local` → `capability_url` (Result-based)
- [ ] Add `Error::CapabilityNotDiscovered` error type
- [ ] Update 5-10 call sites to use new API
- [ ] Add tests for production/development/test environments

### **Week 2: Primal Discovery**
- [ ] Implement capability scanner for active discovery
- [ ] Add mDNS/DNS-SD support for local discovery
- [ ] Create service registry integration
- [ ] Document capability announcement protocol

### **Week 3: Migration**
- [ ] Migrate remaining hardcoded references
- [ ] Update all primals to announce capabilities
- [ ] Create migration guide for external services
- [ ] Comprehensive testing

---

## 💡 KEY INSIGHTS

### **What Makes This Different**

**Traditional Service Discovery**:
```rust
// Assumes BearDog exists at specific address
let beardog = connect_to("http://beardog.local:9090")?;
```

**Capability-Based Discovery**:
```rust
// Asks: "Who can do security?" Not "Where is BearDog?"
let security_provider = discover_capability("security").await?;
let providers = security_provider.iter().map(|p| &p.url);
```

**Benefits**:
- ✅ No vendor lock-in (any security provider works)
- ✅ Multiple providers possible (redundancy)
- ✅ Hot-swappable services (change providers dynamically)
- ✅ Self-documenting (capabilities explicit)
- ✅ Test-friendly (inject test providers)

---

## 🎊 CONCLUSION

**The foundation is already excellent!**

**Current State**:
- ✅ Infrastructure exists
- ✅ Old APIs deprecated
- ✅ Migration path documented
- ⚠️ Some hardcoded fallbacks remain

**Evolution Focus**:
1. Remove hardcoded fallbacks in production mode
2. Add explicit error handling
3. Improve discovery documentation
4. Complete active discovery implementation

**This isn't starting from scratch** - it's completing a well-designed migration already in progress! 🚀

---

**Status**: Plan Complete, Implementation Ready  
**Confidence**: HIGH - Foundation is solid  
**Timeline**: 2-3 weeks for complete migration  
**Impact**: HIGH - True primal independence achieved

