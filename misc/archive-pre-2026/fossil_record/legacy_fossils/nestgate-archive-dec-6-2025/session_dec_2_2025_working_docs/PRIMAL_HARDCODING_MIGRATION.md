# 🔧 PRIMAL HARDCODING MIGRATION

**Date**: December 2, 2025  
**Status**: IN PROGRESS  
**Target**: 160 instances across 16 files

---

## 🎯 MIGRATION MAPPING

### Primal Names → Capabilities

| Primal Name | Capability | Description |
|-------------|------------|-------------|
| `songbird` | `"orchestration"` | Orchestration services |
| `beardog` | `"security"` | Security services |
| `squirrel` | `"ai"` | AI/ML services |
| `toadstool` | `"compute"` | Compute services |
| `biomeos` | `"ecosystem"` | Ecosystem services |

---

## 🔧 MIGRATION PATTERN

### Pattern 1: Direct URL Hardcoding
```rust
// ❌ OLD: Hardcoded primal name
let url = "http://songbird:8080";
let url = format!("http://beardog:{}", port);

// ✅ NEW: Capability-based
let url = config.get_capability_url("orchestration")
    .ok_or(NestGateError::CapabilityNotConfigured("orchestration"))?;
```

### Pattern 2: Config Method Calls
```rust
// ❌ OLD: Primal-specific method (deprecated)
let url = config.get_songbird_url();
let url = config.get_beardog_url();

// ✅ NEW: Capability-based method
let url = config.get_capability_url("orchestration");
let url = config.get_capability_url("security");
```

### Pattern 3: String Literals in Tests
```rust
// ❌ OLD: Test with hardcoded primal
assert!(url.contains("songbird"));
let test_url = "http://beardog:9000";

// ✅ NEW: Test with capability
let test_url = config.get_capability_url("orchestration")
    .unwrap_or_else(|| "http://test-orchestration:8080".to_string());
```

### Pattern 4: Documentation Examples
```rust
// ❌ OLD: Documentation showing primal names
/// Connect to Songbird at `http://songbird:8080`

// ✅ NEW: Documentation showing capabilities
/// Connect to orchestration service via `get_capability_url("orchestration")`
```

---

## 📂 FILES TO MIGRATE (16 total)

### Priority 1: Core Config (3 files)
1. ✅ `config/external/services_config.rs` - Already has infrastructure
2. 🔄 `config/external/services.rs` - Needs migration
3. 🔄 `config/runtime.rs` - Needs migration

### Priority 2: Universal Adapter (4 files)
4. 🔄 `universal_adapter/mod.rs` - 5 instances
5. 🔄 `universal_adapter/networking_capability.rs` - 4 instances
6. 🔄 `universal_adapter/security_capability.rs` - 4 instances
7. 🔄 `capabilities/taxonomy/types.rs` - 2 instances

### Priority 3: Integration (4 files)
8. 🔄 `zfs/orchestrator_integration/types.rs` - 1 instance
9. 🔄 `zero_cost_security_provider/authentication.rs` - 3 instances
10. 🔄 `biomeos/types.rs` - 1 instance
11. 🔄 `biomeos/adapters.rs` - 1 instance

### Priority 4: Other (5 files)
12. 🔄 `biomeos/mod.rs` - 1 instance
13. 🔄 `security/mod.rs` - 1 instance
14. 🔄 `config/canonical_primary/domains/consolidated_domains.rs` - 3 instances
15. 🔄 `api/handlers/workspace_management/README.md` - 3 instances (docs)
16. 🔄 `nestgate-canonical/Cargo.toml` - 1 instance (metadata)

---

## 🚀 EXECUTION STRATEGY

### Phase 2A: Core Config (Today)
- Migrate config files
- Establish pattern
- Verify tests pass

### Phase 2B: Universal Adapter (This Week)
- Update adapter modules
- Fix capability routing
- Comprehensive testing

### Phase 2C: Integration & Polish (Next Week)
- Integration points
- Documentation updates
- Final verification

---

## ✅ SUCCESS CRITERIA

- [ ] Zero hardcoded primal names in code
- [ ] All code uses `get_capability_url()`
- [ ] All tests passing
- [ ] Documentation updated
- [ ] Backward compatibility maintained

---

**Status**: Phase 2A starting now

