# Primal Name Hardcoding Migration Progress

**Started**: December 2, 2025  
**Target**: Remove all 222 hardcoded primal name references  
**Status**: IN PROGRESS

---

## ✅ Completed (3 files)

### 1. `nestgate-core/src/config/runtime.rs` ✅
- **Fixed**: Replaced primal-specific helper methods with capability-based methods
- **Changes**:
  - Removed: `security_service_url_or_default()` and `networking_service_url_or_default()`
  - Added: `get_capability_url(capability: &str)` and `capability_url_or_local(capability: &str)`
  - Removed: `service_url(name: &str)` (used primal names)
  - Added: `capability_url(capability: &str)` and `capability_url_or_local(capability: &str)`
- **Impact**: Core configuration now uses capability-based discovery

### 2. `nestgate-automation/src/types/config.rs` ✅
- **Fixed**: Updated import and usage from `service_url` to `capability_url`
- **Changes**:
  - Changed: `service_url("songbird")` → `capability_url("orchestration")`
  - Changed: `service_url("orchestration")` → `capability_url("networking")`
- **Impact**: Automation discovery now capability-based

### 3. `nestgate-api/src/handlers/workspace_management/optimization.rs` ✅
- **Fixed**: AI service discovery now uses capability types
- **Changes**:
  - Changed: `service_url("squirrel")` → `capability_url("ai")`
  - Changed: `service_url("songbird")` → `capability_url("orchestration")`
  - Added fallback: `capability_url("intelligence")`
- **Impact**: Workspace optimization uses generic AI capability, not primal names

---

## 🔄 Remaining (29 files)

### High Priority Production Code
- [ ] `nestgate-core/src/discovery/capability_scanner.rs` - Test code has hardcoded primal names
- [ ] `nestgate-core/src/universal_adapter/mod.rs`
- [ ] `nestgate-core/src/zero_cost_security_provider/authentication.rs`
- [ ] `nestgate-core/src/capabilities/taxonomy/types.rs`
- [ ] `nestgate-core/src/ecosystem_integration/fallback_providers/mod.rs`
- [ ] `nestgate-core/src/config_root/mod.rs`
- [ ] `nestgate-core/src/load_balancing/mod.rs`
- [ ] `nestgate-core/src/config/external/services_config.rs`
- [ ] `nestgate-core/src/discovery/network_discovery.rs`
- [ ] `nestgate-core/src/universal_adapter/capability_discovery.rs`
- [ ] `nestgate-core/src/universal_providers.rs`
- [ ] `nestgate-core/src/orchestration/mod.rs`
- [ ] `nestgate-core/src/ecosystem_integration/capabilities/security.rs`
- [ ] `nestgate-core/src/ecosystem_integration/capabilities/orchestration.rs`
- [ ] `nestgate-core/src/config/external/services.rs`
- [ ] `nestgate-core/src/universal_adapter/networking_capability.rs`
- [ ] `nestgate-core/src/universal_adapter/security_capability.rs`
- [ ] `nestgate-core/src/security/mod.rs`

### Medium Priority
- [ ] `nestgate-network/src/discovery_comprehensive_tests.rs` - Test file
- [ ] `nestgate-network/src/connection_manager.rs`
- [ ] `nestgate-api/src/bin/nestgate-api-server.rs`
- [ ] `nestgate-zfs/src/orchestrator_integration.rs`
- [ ] `nestgate-zfs/src/orchestrator_integration/types.rs`

### Lower Priority (Tests/Docs)
- [ ] `nestgate-core/src/universal_adapter/adapter_error_tests.rs` - Test file
- [ ] `nestgate-core/src/infant_discovery/tests_expansion.rs` - Test file
- [ ] `nestgate-zfs/src/orchestrator_integration/tests.rs` - Test file
- [ ] `nestgate-bin/tests/integration_tests.rs` - Test file
- [ ] `nestgate-canonical/Cargo.toml` - Dependency reference
- [ ] `nestgate-api/src/handlers/workspace_management/README.md` - Documentation
- [ ] `nestgate-automation/src/types/config.rs` - Some test examples remain

---

## 📊 Progress Statistics

- **Files Fixed**: 3 / 32 (9.4%)
- **Estimated Instances Fixed**: ~15-20 / 222 (6.8-9%)
- **Compilation Status**: ✅ Clean
- **Tests Status**: Not yet run

---

## 🎯 Next Steps

1. Continue with high-priority production code files
2. Fix capability_scanner.rs test code
3. Fix universal_adapter modules
4. Update ecosystem_integration modules
5. Run full test suite to verify changes
6. Update tests to use capability-based patterns

---

## 📝 Migration Pattern

### ❌ Before (Primal Names)
```rust
use nestgate_core::config::runtime::service_url;
let beardog_url = service_url("beardog");
let songbird_endpoint = "http://songbird:8080";
```

### ✅ After (Capability-Based)
```rust
use nestgate_core::config::runtime::capability_url;
let security_url = capability_url("security"); // Any provider
let orchestration_url = capability_url("orchestration"); // Any provider
```

---

**Status**: Making good progress. Core infrastructure migrated. Continuing with remaining files.


