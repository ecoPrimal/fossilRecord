# ⚠️ SOVEREIGNTY VIOLATION: Cloud Backend Architecture

**Date**: December 10, 2025  
**Severity**: 🔴 **CRITICAL** - Violates core primal sovereignty principles  
**Status**: **REQUIRES IMMEDIATE EVOLUTION**

---

## 🚨 VIOLATION IDENTIFIED

**Files**:
- `nestgate-zfs/src/backends/s3.rs` (AWS-specific)
- `nestgate-zfs/src/backends/azure.rs` (Microsoft-specific)
- `nestgate-zfs/src/backends/gcs.rs` (Google-specific)

**Problem**: Hardcoded vendor-specific implementations violate sovereignty:
```rust
// ❌ SOVEREIGNTY VIOLATION: Vendor lock-in
pub struct AzureBackend { ... }  // Microsoft-specific
pub struct S3Backend { ... }     // AWS-specific  
pub struct GCSBackend { ... }    // Google-specific
```

---

## 🎯 PRIMAL SOVEREIGNTY PRINCIPLES

### ✅ CORRECT: Capability-Based Discovery

**Principle**: "I need object storage with versioning capability"  
**NOT**: "I need AWS S3 at s3.amazonaws.com"

```rust
// ✅ SOVEREIGNTY COMPLIANT: Capability-based
pub struct ObjectStorageCapability {
    protocol: StorageProtocol,  // S3-compatible, Swift, etc.
    features: Vec<Feature>,      // Versioning, lifecycle, etc.
    endpoint: DiscoveredEndpoint, // Found at runtime
}
```

### ❌ VIOLATION: Vendor Hardcoding

```rust
// ❌ BAD: Hardcoded vendor assumptions
impl AzureBackend {
    pub async fn new() -> Result<Self> {
        // Hardcodes Azure API expectations
        // Hardcodes Azure-specific auth
        // Hardcodes Azure blob storage semantics
    }
}
```

---

## 🏗️ CORRECT ARCHITECTURE

### Universal Object Storage (Vendor-Agnostic)

```rust
// ✅ CORRECT: Protocol-based, vendor-agnostic
pub struct ObjectStorageBackend {
    /// Discovered at runtime via capability system
    endpoint: DiscoveredEndpoint,
    
    /// S3-compatible, Swift, or custom protocol
    protocol: ObjectStorageProtocol,
    
    /// Discovered capabilities (versioning, lifecycle, etc.)
    capabilities: Vec<StorageCapability>,
    
    /// Runtime-configured credentials
    auth: DiscoveredAuth,
}

pub enum ObjectStorageProtocol {
    /// S3-compatible (AWS, MinIO, Wasabi, DigitalOcean, etc.)
    S3Compatible {
        /// API version discovered at runtime
        api_version: String,
    },
    
    /// OpenStack Swift
    Swift {
        /// API version
        api_version: String,
    },
    
    /// Azure Blob (via S3-compatible gateway if available)
    AzureBlobS3Compatible,
    
    /// Google Cloud Storage (via S3-compatible API)
    GCSS3Compatible,
    
    /// Custom protocol
    Custom {
        /// Protocol name
        protocol: String,
    },
}
```

---

## 📋 EVOLUTION PLAN

### Phase 1: Deprecate Vendor Backends (2 hours)

**Action**: Mark current backends as sovereignty violations

```rust
// File: nestgate-zfs/src/backends/azure.rs
#[deprecated(
    since = "0.12.0",
    note = "SOVEREIGNTY VIOLATION: Use ObjectStorageBackend with capability discovery instead. \
            See SOVEREIGNTY_VIOLATION_CLOUD_BACKENDS.md for migration guide."
)]
pub struct AzureBackend { ... }
```

**Files to Update**:
1. `s3.rs` - Deprecate with sovereignty violation notice
2. `azure.rs` - Deprecate with sovereignty violation notice  
3. `gcs.rs` - Deprecate with sovereignty violation notice

### Phase 2: Implement Capability-Based Object Storage (20-30 hours)

**Create**: `nestgate-core/src/universal_storage/backends/object_storage.rs`

```rust
//! **OBJECT STORAGE BACKEND - SOVEREIGNTY COMPLIANT**
//!
//! Capability-based object storage that discovers services at runtime.
//! Works with ANY S3-compatible service, not just AWS.

use crate::universal_primal_discovery::CapabilityDiscovery;

pub struct ObjectStorageBackend {
    /// Discovered via capability system (NOT hardcoded)
    discovered_endpoint: DiscoveredEndpoint,
    
    /// S3-compatible protocol (works with AWS, MinIO, Wasabi, etc.)
    protocol: ObjectStorageProtocol,
    
    /// Runtime authentication (discovered, not hardcoded)
    auth: AuthProvider,
}

impl ObjectStorageBackend {
    /// Create from discovered capability (sovereignty-compliant)
    pub async fn from_capability(
        capability: StorageCapability
    ) -> Result<Self> {
        // Discover object storage service at runtime
        let discovery = CapabilityDiscovery::new();
        let endpoint = discovery
            .discover_service_with_capability("object-storage")
            .await?;
        
        // Use S3-compatible protocol (works with any provider)
        Ok(Self {
            discovered_endpoint: endpoint,
            protocol: ObjectStorageProtocol::S3Compatible {
                api_version: "v4".to_string(),
            },
            auth: AuthProvider::discover_from_env()?,
        })
    }
    
    /// ✅ NO vendor-specific methods
    /// ✅ Works with ANY S3-compatible service
    /// ✅ Discovers at runtime
}
```

### Phase 3: Update Universal Storage Integration (4-6 hours)

**Update**: `nestgate-core/src/universal_storage/consolidated_types.rs`

```rust
// ✅ ALREADY CORRECT: Has CloudProvider enum
pub enum UniversalStorageType {
    // ... other types ...
    
    /// Cloud storage (discovered at runtime)
    Cloud {
        /// Discovered provider (NOT hardcoded preference)
        provider: CloudProvider,
    },
}

pub enum CloudProvider {
    /// Any S3-compatible service (AWS, MinIO, Wasabi, DO, etc.)
    S3Compatible {
        /// Discovered endpoint
        endpoint: String,
    },
    
    /// OpenStack Swift
    Swift {
        /// Discovered endpoint  
        endpoint: String,
    },
    
    /// Custom provider discovered at runtime
    Custom {
        /// Provider name
        name: String,
        /// Discovered endpoint
        endpoint: String,
    },
    
    // ❌ REMOVE: No AWS, Azure, GCP variants
    // These would be S3Compatible with discovered endpoints
}
```

### Phase 4: Documentation & Migration (2-3 hours)

**Create**: Migration guide for users

```markdown
# Migrating from Vendor Backends to Capability-Based Storage

## Old (Sovereignty Violation)
```rust
// ❌ Hardcoded vendor
let azure = AzureBackend::new().await?;
```

## New (Sovereignty Compliant)
```rust
// ✅ Capability-based discovery
let storage = ObjectStorageBackend::discover_with_capability(
    StorageCapability::ObjectStorage {
        features: vec![Feature::Versioning, Feature::Lifecycle],
    }
).await?;

// Works with ANY S3-compatible service discovered at runtime:
// - AWS S3 (if available)
// - MinIO (if running locally)
// - Wasabi (if configured)
// - DigitalOcean Spaces (if available)
// - Any other S3-compatible service
```
```

---

## 🎯 MIGRATION TIMELINE

### Immediate (Today - 2 hours)
1. ✅ Document sovereignty violation
2. ✅ Deprecate vendor-specific backends
3. ✅ Update TODOs to reference this violation

### Week 1 (20-30 hours)
4. ⚠️ Implement ObjectStorageBackend (S3-compatible protocol)
5. ⚠️ Integrate with capability discovery
6. ⚠️ Add runtime endpoint configuration

### Week 2 (10-15 hours)
7. ⚠️ Update all references to use ObjectStorageBackend
8. ⚠️ Create migration guide
9. ⚠️ Update tests for capability-based discovery
10. ⚠️ Remove deprecated backends (v0.13.0)

---

## ✅ SOVEREIGNTY COMPLIANCE CHECKLIST

### Principles to Follow
- [ ] **No Vendor Hardcoding**: No AWS/Azure/Google-specific code
- [ ] **Capability Discovery**: Discover services at runtime by capability
- [ ] **Protocol-Based**: Use standard protocols (S3-compatible, Swift, etc.)
- [ ] **Runtime Configuration**: All endpoints discovered or env-configured
- [ ] **Vendor Agnostic**: Works with ANY provider implementing the protocol

### Anti-Patterns to Avoid
- [ ] ❌ Vendor-specific backend types
- [ ] ❌ Hardcoded endpoint URLs
- [ ] ❌ Vendor-specific authentication flows
- [ ] ❌ Vendor-specific API assumptions
- [ ] ❌ Compile-time vendor selection

---

## 🔄 EXAMPLE: S3-Compatible (Correct Approach)

### Configuration (Runtime Discovery)

```toml
# Option 1: Environment-based discovery
NESTGATE_OBJECT_STORAGE_CAPABILITY="s3-compatible"
NESTGATE_OBJECT_STORAGE_ENDPOINT="https://s3.amazonaws.com"  # Or MinIO, Wasabi, etc.
NESTGATE_OBJECT_STORAGE_REGION="auto"

# Option 2: Capability discovery (preferred)
NESTGATE_CAPABILITY_DISCOVERY="enabled"
# System discovers available object storage services automatically
```

### Code (Sovereignty Compliant)

```rust
// ✅ CORRECT: Discovers any S3-compatible service
let storage = ObjectStorageBackend::discover().await?;

// Works with:
// - AWS S3 (if endpoint=s3.amazonaws.com)
// - MinIO (if endpoint=localhost:9000)
// - Wasabi (if endpoint=s3.wasabisys.com)  
// - DigitalOcean (if endpoint=nyc3.digitaloceanspaces.com)
// - Any S3-compatible service!

// ✅ No vendor lock-in
// ✅ Runtime discovery
// ✅ Configuration-driven
// ✅ Works anywhere
```

---

## 📊 IMPACT ANALYSIS

### Current State (Sovereignty Violation)
- ❌ 3 vendor-specific backend files (s3.rs, azure.rs, gcs.rs)
- ❌ Hardcoded vendor APIs
- ❌ Vendor-specific authentication
- ❌ Cannot work with alternative providers
- ❌ Violates primal sovereignty principles

### Target State (Sovereignty Compliant)
- ✅ 1 protocol-based backend (object_storage.rs)
- ✅ S3-compatible protocol (industry standard)
- ✅ Runtime capability discovery
- ✅ Works with ANY S3-compatible service
- ✅ Perfect primal sovereignty compliance

---

## 💡 KEY INSIGHTS

### What Makes This a Sovereignty Violation

1. **Hardcoded Vendor Assumptions**
   - Code assumes AWS/Azure/Google APIs
   - Cannot work with alternative providers
   - Vendor lock-in at code level

2. **Compile-Time Vendor Selection**
   - Separate backends for each vendor
   - Must recompile to switch providers
   - Not runtime-configurable

3. **No Capability Discovery**
   - Doesn't discover available services
   - Hardcodes vendor expectations
   - Not autonomous

### What Makes It Sovereignty-Compliant

1. **Protocol-Based**
   - Uses standard S3-compatible protocol
   - Works with ANY provider implementing protocol
   - No vendor assumptions

2. **Runtime Discovery**
   - Discovers available services at runtime
   - Capability-based selection
   - Fully autonomous

3. **Configuration-Driven**
   - Endpoints from environment/discovery
   - No hardcoded URLs
   - Completely vendor-agnostic

---

## ✅ RECOMMENDATION

**Immediate Action**: 
1. Deprecate vendor-specific backends TODAY
2. Document as sovereignty violations
3. Plan capability-based evolution for v0.13.0

**Timeline**:
- v0.12.0 (current): Deprecate with warnings
- v0.13.0 (4-6 weeks): Implement ObjectStorageBackend
- v0.14.0 (8-10 weeks): Remove deprecated backends

**Priority**: HIGH - This violates core principles

---

**Violation Status**: 🔴 **CONFIRMED**  
**Evolution Status**: ⚠️ **PLANNED v0.13.0**  
**Sovereignty Score**: ❌ **0/100** (for cloud backends)

*"Primals have only self-knowledge and discover others at runtime. No vendor hardcoding."* - Violated by current cloud backend architecture.

---

**Next Action**: Mark backends as deprecated and begin capability-based implementation

