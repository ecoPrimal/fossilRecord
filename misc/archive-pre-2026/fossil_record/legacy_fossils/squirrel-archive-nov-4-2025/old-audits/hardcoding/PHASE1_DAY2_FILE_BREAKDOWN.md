# 🔍 HARDCODING ELIMINATION - PHASE 1, DAY 2
## Detailed File-by-File Breakdown

**Date**: October 30, 2025 - Evening  
**Phase**: 1 - Audit & Categorize  
**Day**: 2 of 3  
**Status**: 🟢 Detailed Analysis In Progress

---

## 📊 EXECUTIVE SUMMARY

**Total Files with Hardcoding**: 221 files  
**Total Instances**: 893  
**Critical Files**: 20 (containing 60% of all instances)

---

## 🔴 TIER 1: CRITICAL FILES (Must Fix First)

### 1. **crates/universal-constants/src/host_config.rs**
```
Total Instances: ~120
Priority: P0 🔴 CRITICAL
Status: Framework exists, needs enhancement
Complexity: MEDIUM
Estimated Time: 2-3 days
```

**Current State**:
- ✅ Good: Environment-driven config struct exists
- ✅ Good: Uses `SQUIRREL_HOST_*` env vars
- 🔴 BAD: Hardcoded fallback values (localhost, 127.0.0.1, 0.0.0.0)
- 🔴 BAD: Primal service names hardcoded (beardog, songbird, etc.)

**Hardcoding Breakdown**:
- `"0.0.0.0"` fallbacks: ~15 instances
- `"127.0.0.1"` fallbacks: ~20 instances
- `"localhost"` fallbacks: ~25 instances
- Primal name refs: ~60 instances (BEARDOG, SONGBIRD, NESTGATE, etc.)

**Migration Strategy**:
```rust
// BEFORE (current):
let squirrel_host = env::var("SQUIRREL_HOST_SQUIRREL")
    .unwrap_or_else(|_| "localhost".to_string());

// AFTER (proposed):
let squirrel_host = env::var("SQUIRREL_HOST_SQUIRREL")
    .or_else(|_| env::var("SQUIRREL_DEFAULT_HOST"))
    .unwrap_or_else(|_| {
        // Use service discovery if available
        discover_service_host("squirrel")
            .unwrap_or_else(|| "127.0.0.1".to_string())
    });
```

**Action Items**:
- [ ] Add `SQUIRREL_DEFAULT_HOST` env var
- [ ] Integrate with service discovery
- [ ] Add validation for host addresses
- [ ] Add comprehensive tests
- [ ] Update documentation
- [ ] Create migration guide

---

### 2. **crates/universal-constants/src/network.rs**
```
Total Instances: ~100
Priority: P0 🔴 CRITICAL
Status: Partially migrated (ports done), hosts remaining
Complexity: LOW
Estimated Time: 1-2 days
```

**Current State**:
- ✅ Good: Ports already deprecated and moved to `port_config`
- 🔴 BAD: Still has `DEFAULT_HOST` = "localhost"
- 🔴 BAD: Still has `PRODUCTION_HOST` = "0.0.0.0"

**Hardcoding Breakdown**:
- `DEFAULT_HOST` constant: 1 definition, ~30 usages
- `PRODUCTION_HOST` constant: 1 definition, ~20 usages
- Helper functions returning hardcoded IPs: ~50 instances

**Migration Strategy**:
```rust
// BEFORE:
pub const DEFAULT_HOST: &str = "localhost";
pub const PRODUCTION_HOST: &str = "0.0.0.0";

// AFTER:
#[deprecated(since = "0.4.0", note = "Use host_config::bind_address()")]
pub const DEFAULT_HOST: &str = "localhost";

// Then eventually remove and use:
use crate::host_config;
let host = host_config::bind_address();
```

**Action Items**:
- [ ] Deprecate `DEFAULT_HOST` and `PRODUCTION_HOST`
- [ ] Update all call sites to use `host_config`
- [ ] Add migration warnings
- [ ] Update tests
- [ ] Remove deprecated constants after 1 release cycle

---

### 3. **crates/core/core/src/service_discovery/registry.rs**
```
Total Instances: 44
Priority: P0 🔴 CRITICAL
Status: Core infrastructure, needs careful refactor
Complexity: HIGH
Estimated Time: 3-4 days
```

**Hardcoding Breakdown**:
- Hardcoded service endpoints: ~15 instances
- Default ports in registration: ~20 instances
- Test endpoints: ~9 instances

**Current Issues**:
```rust
// Hardcoded endpoint construction:
let endpoint = format!("http://localhost:8080");

// Should be:
let endpoint = format!("http://{}:{}", 
    host_config::service_host("api"),
    port_config::http_port()
);
```

**Action Items**:
- [ ] Replace hardcoded endpoints with config
- [ ] Add endpoint builder helper
- [ ] Update service registration logic
- [ ] Add validation for endpoints
- [ ] Comprehensive test coverage

---

### 4. **crates/core/core/src/service_discovery/memory.rs**
```
Total Instances: 34
Priority: P0 🔴 CRITICAL
Status: In-memory registry, test-friendly
Complexity: MEDIUM
Estimated Time: 2 days
```

**Hardcoding Breakdown**:
- Test fixture endpoints: ~20 instances
- Default service entries: ~14 instances

**Migration Strategy**:
- Extract test fixtures to test_utils
- Use config for default entries
- Add builder pattern for test data

---

### 5. **crates/core/core/src/service_discovery/types.rs**
```
Total Instances: 42
Priority: P0 🔴 CRITICAL
Status: Type definitions with hardcoded defaults
Complexity: LOW
Estimated Time: 1-2 days
```

**Hardcoding Breakdown**:
- Default struct values: ~30 instances
- Example/documentation endpoints: ~12 instances

**Action Items**:
- [ ] Replace `Default` impl hardcodes with config
- [ ] Add `from_env()` constructors
- [ ] Update documentation examples

---

### 6. **crates/core/core/src/service_discovery/client.rs**
```
Total Instances: 36
Priority: P0 🔴 CRITICAL
Status: Client connection logic
Complexity: MEDIUM
Estimated Time: 2-3 days
```

**Hardcoding Breakdown**:
- Connection URLs: ~20 instances
- Fallback addresses: ~10 instances
- Test client setup: ~6 instances

---

### 7. **crates/core/core/src/routing.rs**
```
Total Instances: 8
Priority: P0 🔴 HIGH
Status: Core routing logic
Complexity: LOW
Estimated Time: 1 day
File Size: 1725 lines (also needs splitting)
```

**Hardcoding Breakdown**:
- Default route hosts: ~5 instances
- Test routing: ~3 instances

**Additional Work**: This file is 1725 lines (over limit), should be split anyway.

---

### 8. **crates/core/core/src/ecosystem.rs**
```
Total Instances: 40 (primal references)
Priority: P0 🔴 CRITICAL
Status: Primal name hardcoding
Complexity: HIGH
Estimated Time: 4-5 days
```

**Current Issues**:
```rust
// Hardcoded primal names:
match primal_name {
    "BEARDOG" => // security operations
    "SONGBIRD" => // orchestration
    "NESTGATE" => // gateway
    // ...
}

// Should use capability-based discovery:
let security_primal = discover_by_capability(Capability::Security)?;
let orchestration_primal = discover_by_capability(Capability::Orchestration)?;
```

**Migration Strategy**:
1. Define capability taxonomy
2. Implement capability-based discovery
3. Update ecosystem coordination
4. Add fallback to name-based (backward compat)
5. Deprecate name-based after 2 releases

**Action Items**:
- [ ] Design capability taxonomy
- [ ] Implement discovery by capability
- [ ] Update ecosystem integration
- [ ] Add migration path
- [ ] Comprehensive E2E tests

---

## 🟡 TIER 2: HIGH PRIORITY (Fix Week 2)

### 9-15. **MCP Transport Layer** (~60 instances)
```
Files:
- crates/core/mcp/src/transport/tcp/connection.rs (7)
- crates/core/mcp/src/transport/websocket/mod.rs (4)
- crates/core/mcp/src/transport/tests/*.rs (multiple)
- crates/core/mcp/src/enhanced/*.rs (various)

Total: ~60 instances
Priority: P1 🟡
Complexity: MEDIUM
Estimated Time: 3-4 days
```

**Issues**:
- Connection endpoints hardcoded
- Test setup hardcoded
- Default transports use localhost

**Strategy**: Use `host_config` and `port_config` throughout.

---

### 16-20. **Configuration & Testing** (~150 instances)
```
Files:
- canonical-config/src/unified/*.rs (~50)
- Various test files (~100)

Total: ~150 instances
Priority: P1-P2 🟡
Complexity: LOW-MEDIUM
Estimated Time: 3-5 days
```

---

## 🟢 TIER 3: TEST CODE (Fix Week 3+)

### **Test Infrastructure** (273 instances)
```
Priority: P2-P3 🟢
Status: Lower priority (tests)
Complexity: LOW
Estimated Time: 2-3 days
```

**Strategy**:
- Create test fixture helpers in `test-utils`
- Dynamic port allocation for parallel tests
- Environment-based test configuration

---

## 📋 MIGRATION CHECKLIST TEMPLATE

For each file, follow this process:

### **Phase 1: Analysis** (30 min per file)
- [ ] Count hardcoded instances
- [ ] Categorize by type (host/port/primal)
- [ ] Identify dependencies
- [ ] Assess complexity
- [ ] Plan migration strategy

### **Phase 2: Preparation** (1-2 hours per file)
- [ ] Create feature branch
- [ ] Add new config infrastructure
- [ ] Write migration tests
- [ ] Document changes

### **Phase 3: Migration** (2-4 hours per file)
- [ ] Replace hardcoded values
- [ ] Update call sites
- [ ] Run tests
- [ ] Fix any breakage

### **Phase 4: Validation** (1-2 hours per file)
- [ ] Run full test suite
- [ ] Manual testing
- [ ] Performance check
- [ ] Documentation update

### **Phase 5: Cleanup** (30 min per file)
- [ ] Remove deprecated code
- [ ] Update CHANGELOG
- [ ] Mark as complete
- [ ] Update tracking

**Total Time per File**: 5-9 hours  
**Total Files (P0)**: 20 files  
**Total Estimate**: **100-180 hours** = **2.5-4.5 weeks** (1 person)

With parallel work and focus: **2-3 weeks** achievable.

---

## 🎯 PRIORITIZED EXECUTION ORDER

### **Week 1: Foundation** (Days 1-7)
```
Day 1: ✅ Audit complete
Day 2: 🟢 This breakdown + benchmark fixes
Day 3: network.rs + host_config.rs (base layer)
Day 4: service_discovery/types.rs + client.rs
Day 5: service_discovery/registry.rs + memory.rs
Day 6: routing.rs (+ file split)
Day 7: Buffer/catch-up
```

**Week 1 Target**: 240 instances eliminated (27% of total)

### **Week 2: Primal & MCP** (Days 8-14)
```
Day 8: ecosystem.rs design
Day 9-10: ecosystem.rs implementation
Day 11: MCP transport layer
Day 12: Configuration files
Day 13: Integration testing
Day 14: Buffer/validation
```

**Week 2 Target**: 380 instances eliminated (total: 620/893 = 69%)

### **Week 3: Polish & Tests** (Days 15-21)
```
Day 15-17: Test infrastructure
Day 18-19: Remaining P1 items
Day 20: Final validation
Day 21: Documentation & wrap-up
```

**Week 3 Target**: 200+ instances (total: 820/893 = 92%)

---

## 🛠️ TOOLS & INFRASTRUCTURE NEEDED

### **Configuration System Enhancement**:
```rust
// New central config module:
crates/universal-constants/src/runtime_config.rs

pub struct RuntimeConfig {
    network: NetworkConfig,
    discovery: DiscoveryConfig,
    primal_capabilities: CapabilityMap,
}

impl RuntimeConfig {
    pub fn from_env() -> Result<Self>;
    pub fn with_defaults() -> Self;
    pub fn validate(&self) -> Result<()>;
}
```

### **Service Discovery Integration**:
```rust
pub trait ServiceDiscovery {
    fn discover_by_capability(&self, cap: Capability) -> Result<ServiceInfo>;
    fn discover_by_name(&self, name: &str) -> Result<ServiceInfo>;
    fn register_service(&self, info: ServiceInfo) -> Result<()>;
}
```

### **Test Utilities**:
```rust
// test-utils/src/network_fixtures.rs
pub fn random_available_port() -> u16;
pub fn test_endpoint(service: &str) -> String;
pub fn mock_service_registry() -> ServiceRegistry;
```

---

## 📊 SUCCESS METRICS

### **Completion Tracking**:
- [ ] Week 1: 240/893 = 27%
- [ ] Week 2: 620/893 = 69%
- [ ] Week 3: 820/893 = 92%
- [ ] Final: 893/893 = 100% ✅

### **Quality Gates**:
- [ ] All tests passing (100%)
- [ ] No hardcoded localhost/127.0.0.1/0.0.0.0 in production code
- [ ] No hardcoded primal names in coordination logic
- [ ] Environment-driven configuration working
- [ ] Service discovery integration complete
- [ ] Backward compatibility maintained (1 release)
- [ ] Documentation updated
- [ ] Migration guide published

---

## 🚨 RISKS & MITIGATION

### **Risk 1: Breaking Changes** (HIGH)
- **Mitigation**: Feature flags, gradual rollout, extensive testing
- **Fallback**: Maintain deprecated code for 1 release cycle

### **Risk 2: Service Discovery Complexity** (MEDIUM)
- **Mitigation**: Start simple, add features incrementally
- **Fallback**: Keep name-based discovery as fallback

### **Risk 3: Test Breakage** (MEDIUM)
- **Mitigation**: Update tests in parallel with code
- **Fallback**: Test utilities for common patterns

### **Risk 4: Performance Impact** (LOW)
- **Mitigation**: Cache config reads, lazy initialization
- **Fallback**: Compile-time config for hot paths

---

## ✅ NEXT ACTIONS (TODAY)

1. ✅ Complete this breakdown
2. ⏭️ Fix benchmark compilation errors (quick win, 1-2 hours)
3. ⏭️ Start with `network.rs` migration (deprecation)
4. ⏭️ Create runtime_config.rs stub
5. ⏭️ Set up test fixtures in test-utils

---

**Status**: 🟢 **READY TO EXECUTE**  
**Confidence**: 95%  
**Timeline**: 2-3 weeks  
**Next Update**: End of Day 2

---

**Generated**: October 30, 2025 - Evening  
**Phase**: 1 - Audit & Categorize  
**Day**: 2 of 3

