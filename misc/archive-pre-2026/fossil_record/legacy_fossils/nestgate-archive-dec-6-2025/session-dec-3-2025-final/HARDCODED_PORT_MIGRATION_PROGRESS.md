# Hardcoded Port Migration Progress

## Executive Summary

**Goal**: Systematically replace all hardcoded ports with environment-driven configuration.

**Status**: **IN PROGRESS** ✅
- **Files with hardcoded ports identified**: 20
- **Files migrated**: 2 (self_knowledge/builder.rs, self_knowledge/examples.rs)
- **Remaining**: 18

## Migration Strategy

### Phase 1: Foundation (COMPLETE ✅)
- ✅ Created `constants/network_hardcoded.rs` module
- ✅ Implemented environment variable readers:
  - `get_api_port()` → NESTGATE_API_PORT (default: 8080)
  - `get_metrics_port()` → NESTGATE_METRICS_PORT (default: 9090)
  - `get_health_port()` → NESTGATE_HEALTH_PORT (default: 8081)
  - `get_websocket_port()` → NESTGATE_WEBSOCKET_PORT (default: 8081)
- ✅ Created `constants/consolidated.rs` for comprehensive configuration

### Phase 2: Systematic Replacement (IN PROGRESS)

#### ✅ Completed Files
1. **self_knowledge/builder.rs**
   - Replaced: `"0.0.0.0:8080"` → `format!("0.0.0.0:{}", get_api_port())`
   - Replaced: `"0.0.0.0:9090"` → `format!("0.0.0.0:{}", get_metrics_port())`
   - Replaced: `"127.0.0.1:8080"`, `"127.0.0.1:9090"`, `"127.0.0.1:8081"` → environment-driven
   - Lines changed: 3 locations
   - Status: ✅ Compiles cleanly

2. **self_knowledge/examples.rs**
   - Replaced: Example code now uses environment-driven configuration
   - Added documentation comments explaining anti-patterns
   - Lines changed: 3 locations
   - Status: ✅ Compiles cleanly

#### 🔄 Pending Files (18 remaining)

High-Priority Production Code:
1. `universal_primal_discovery/production_discovery.rs`
2. `network/client.rs` (already clean - only test code has ports)
3. `discovery/network_discovery.rs`
4. `config/runtime.rs` (check for any remaining)
5. `services/native_async/mod.rs`
6. `constants/network_hardcoded.rs` (validate usage)

Medium-Priority Test/Example Code:
7. `capability_config/examples.rs`
8. `capability_config.rs`
9. `self_knowledge/mod.rs` (documentation examples)
10. `universal_primal_discovery/migration_to_self_knowledge.rs`
11. `universal_primal_discovery/network.rs`
12. `universal_primal_discovery/error_path_tests.rs`
13. `network/native_async/service.rs`
14. `constants/canonical_defaults.rs`

Low-Priority (mostly documentation):
15. `constants/consolidated.rs` (validate defaults)
16. `services/storage/config.rs`
17. `capabilities/discovery/resolver.rs`
18. `config/sovereignty_config.rs`

## Pattern Reference

### ❌ Old Pattern (Hardcoded)
```rust
// Hardcoded port - inflexible, deployment-specific
const API_ENDPOINT: &str = "http://127.0.0.1:8080";
let endpoint = "0.0.0.0:8080".parse()?;
```

### ✅ New Pattern (Environment-Driven)
```rust
use crate::constants::network_hardcoded::{get_api_port, get_api_bind_address};

// Environment-driven - flexible, 12-factor compliant
let api_port = get_api_port(); // Reads NESTGATE_API_PORT or defaults to 8080
let bind_addr = get_api_bind_address(); // Reads NESTGATE_BIND_ADDRESS or defaults to 0.0.0.0
let endpoint = format!("{}:{}", bind_addr, api_port).parse()?;
```

### 📝 Documentation Examples
```rust
// For documentation/examples, add clarifying comment:
// Example using default configuration (override with NESTGATE_API_PORT)
.with_endpoint("api", &format!("0.0.0.0:{}", get_api_port()).parse()?)
```

### 🧪 Test Code
```rust
// Test code can use environment-driven config for integration tests
// or hardcoded values for unit tests (with justification comment)

// ✅ Integration test - respects environment
let port = crate::constants::network_hardcoded::get_api_port();

// ✅ Unit test - hardcoded acceptable with comment
let port = 8080; // Test fixture - not production value
```

## Environment Variables Reference

All configuration supports environment overrides:

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `NESTGATE_API_HOST` | 127.0.0.1 | API server bind host |
| `NESTGATE_API_PORT` | 8080 | Main API HTTP port |
| `NESTGATE_HTTPS_PORT` | 8443 | HTTPS port |
| `NESTGATE_METRICS_PORT` | 9090 | Prometheus metrics port |
| `NESTGATE_HEALTH_PORT` | 8081 | Health check endpoint port |
| `NESTGATE_WEBSOCKET_PORT` | 8081 | WebSocket port |
| `NESTGATE_BIND_ADDRESS` | 0.0.0.0 | Global bind address |

## Progress Tracking

- **Total hardcoded port instances**: ~133 (from initial audit)
- **Instances migrated**: ~6
- **Percentage complete**: ~4.5%
- **Files migrated**: 2 / 20 = 10%

## Next Steps

1. ✅ **Continue systematic file-by-file migration** (current focus)
2. Migrate production code first (universal_primal_discovery, discovery)
3. Update test code to use environment-driven config where appropriate
4. Update documentation examples
5. Run comprehensive test suite to validate changes
6. Update deployment documentation with new environment variables
7. Create migration script to help others update custom deployments

## Validation Checklist

For each migrated file:
- [ ] All hardcoded ports replaced with `get_*_port()` calls
- [ ] Code compiles without errors
- [ ] Tests pass (if applicable)
- [ ] Documentation updated (if applicable)
- [ ] No regression in functionality

## Benefits of Migration

1. **12-Factor App Compliance**: Configuration via environment
2. **Deployment Flexibility**: Different ports per environment without code changes
3. **Container-Friendly**: Easy to override in docker-compose, k8s, etc.
4. **Development Convenience**: Local development can use different ports
5. **Security**: No ports hardcoded in version control
6. **Sovereignty**: No assumptions about network topology

## Completion Criteria

- [ ] All 20 identified files migrated
- [ ] All tests pass with environment-driven configuration
- [ ] Documentation examples updated
- [ ] Deployment guide includes environment variable reference
- [ ] Zero hardcoded ports in production code paths

---

**Last Updated**: December 3, 2025 (Evening Session)
**Status**: Phase 2 - Systematic Replacement (10% complete)
**Next File**: universal_primal_discovery/production_discovery.rs

