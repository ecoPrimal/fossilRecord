# 🔧 HARDCODING MIGRATION CHECKLIST
## File-by-File Execution Tracking

**Date**: October 30, 2025 - Evening  
**Phase**: 1 - Audit & Categorize → 2 - Implementation  
**Status**: 🟢 Ready to Execute

---

## 📊 PROGRESS TRACKER

```
Total Files: 20 critical files
Completed: 0
In Progress: 0
Remaining: 20

Total Instances: 893
Eliminated: 0
Remaining: 893
Progress: 0%
```

---

## 🎯 TIER 1: CRITICAL FILES (Week 1)

### ✅ **FILE 1: crates/universal-constants/src/network.rs**

**Priority**: P0 🔴  
**Instances**: ~100  
**Complexity**: LOW  
**Time Estimate**: 1-2 days  
**Status**: ⏭️ NEXT UP

#### **Pre-Migration Checklist**:
- [ ] Read current file completely
- [ ] Count exact hardcoded instances
- [ ] Identify all call sites
- [ ] Create feature branch: `refactor/network-constants`
- [ ] Write migration tests
- [ ] Document breaking changes

#### **Migration Steps**:
- [ ] Deprecate `DEFAULT_HOST` constant
- [ ] Deprecate `PRODUCTION_HOST` constant
- [ ] Update all usages to use `runtime_config::config().network()`
- [ ] Add deprecation warnings with migration path
- [ ] Update documentation
- [ ] Run full test suite

#### **Post-Migration Validation**:
- [ ] All tests passing
- [ ] No new hardcoded values
- [ ] Deprecation warnings present
- [ ] Documentation updated
- [ ] CHANGELOG entry added
- [ ] Instances eliminated: 0/~100

**Notes**: Already partially migrated (ports done). Focus on host constants.

---

### ✅ **FILE 2: crates/universal-constants/src/host_config.rs**

**Priority**: P0 🔴  
**Instances**: ~120  
**Complexity**: MEDIUM  
**Time Estimate**: 2-3 days  
**Status**: ⏭️ POC READY

#### **Pre-Migration Checklist**:
- [ ] Read current file completely
- [ ] Count exact hardcoded instances
- [ ] Identify service discovery integration points
- [ ] Create feature branch: `refactor/host-config-runtime`
- [ ] Write comprehensive tests
- [ ] Design backward compatibility layer

#### **Migration Steps**:
- [ ] Replace hardcoded fallback values with runtime_config
- [ ] Integrate with service discovery (if available)
- [ ] Add `SQUIRREL_DEFAULT_HOST` environment variable
- [ ] Update primal service host resolution
- [ ] Add validation for all host addresses
- [ ] Update all call sites
- [ ] Comprehensive testing

#### **Post-Migration Validation**:
- [ ] All tests passing
- [ ] Service discovery integration working
- [ ] Environment variables respected
- [ ] Fallbacks work correctly
- [ ] No regressions in dependent code
- [ ] Instances eliminated: 0/~120

**Notes**: Framework exists, needs enhancement to eliminate fallback hardcoding.

---

### ✅ **FILE 3: crates/core/core/src/service_discovery/registry.rs**

**Priority**: P0 🔴  
**Instances**: 44  
**Complexity**: HIGH  
**Time Estimate**: 3-4 days  
**Status**: PENDING

#### **Pre-Migration Checklist**:
- [ ] Read current file completely (1725 lines)
- [ ] Audit all endpoint constructions
- [ ] Map dependencies
- [ ] Create feature branch: `refactor/service-registry`
- [ ] Design endpoint builder pattern
- [ ] Write extensive integration tests

#### **Migration Steps**:
- [ ] Create endpoint builder helper
- [ ] Replace hardcoded endpoint construction
- [ ] Update service registration logic
- [ ] Add endpoint validation
- [ ] Integrate with runtime_config
- [ ] Update all registration call sites
- [ ] Add metrics for endpoint health

#### **Post-Migration Validation**:
- [ ] All service registrations working
- [ ] Endpoints validated correctly
- [ ] No hardcoded values remain
- [ ] Integration tests passing
- [ ] Performance acceptable
- [ ] Instances eliminated: 0/44

**Notes**: Core infrastructure, needs careful testing.

---

### ✅ **FILE 4: crates/core/core/src/service_discovery/memory.rs**

**Priority**: P0 🔴  
**Instances**: 34  
**Complexity**: MEDIUM  
**Time Estimate**: 2 days  
**Status**: PENDING

#### **Pre-Migration Checklist**:
- [ ] Read current file completely
- [ ] Identify test fixtures
- [ ] Extract fixtures to test_utils
- [ ] Create feature branch: `refactor/memory-registry`
- [ ] Write builder pattern for test data

#### **Migration Steps**:
- [ ] Extract test fixtures to test-utils crate
- [ ] Use runtime_config for default entries
- [ ] Add builder pattern for test data
- [ ] Update all test usages
- [ ] Validate in-memory operations
- [ ] Comprehensive test coverage

#### **Post-Migration Validation**:
- [ ] All tests passing
- [ ] Test fixtures reusable
- [ ] No hardcoded test data in production paths
- [ ] Performance maintained
- [ ] Instances eliminated: 0/34

**Notes**: Focus on separating test from production concerns.

---

### ✅ **FILE 5: crates/core/core/src/service_discovery/types.rs**

**Priority**: P0 🔴  
**Instances**: 42  
**Complexity**: LOW  
**Time Estimate**: 1-2 days  
**Status**: PENDING

#### **Pre-Migration Checklist**:
- [ ] Read current file completely
- [ ] Identify all `Default` implementations
- [ ] Document breaking changes
- [ ] Create feature branch: `refactor/discovery-types`
- [ ] Design `from_env()` constructors

#### **Migration Steps**:
- [ ] Replace `Default` impl hardcodes
- [ ] Add `from_env()` constructors
- [ ] Add `with_config()` builders
- [ ] Update documentation examples
- [ ] Update all construction sites
- [ ] Comprehensive tests

#### **Post-Migration Validation**:
- [ ] All constructions working
- [ ] Environment variables respected
- [ ] Defaults sensible for dev
- [ ] Production configs correct
- [ ] Instances eliminated: 0/42

**Notes**: Type definitions, straightforward migration.

---

### ✅ **FILE 6: crates/core/core/src/service_discovery/client.rs**

**Priority**: P0 🔴  
**Instances**: 36  
**Complexity**: MEDIUM  
**Time Estimate**: 2-3 days  
**Status**: PENDING

#### **Pre-Migration Checklist**:
- [ ] Read current file completely
- [ ] Map connection logic flow
- [ ] Identify fallback strategies
- [ ] Create feature branch: `refactor/discovery-client`
- [ ] Design connection builder

#### **Migration Steps**:
- [ ] Replace hardcoded connection URLs
- [ ] Update fallback address logic
- [ ] Extract test client setup
- [ ] Add connection validation
- [ ] Integrate runtime_config
- [ ] Update error messages

#### **Post-Migration Validation**:
- [ ] All connections working
- [ ] Fallbacks functional
- [ ] Error handling improved
- [ ] Tests comprehensive
- [ ] Instances eliminated: 0/36

**Notes**: Client connection logic, needs careful testing.

---

### ✅ **FILE 7: crates/core/core/src/routing.rs**

**Priority**: P0 🔴  
**Instances**: 8  
**Complexity**: LOW (but file is 1725 lines)  
**Time Estimate**: 1 day + file split  
**Status**: PENDING

#### **Pre-Migration Checklist**:
- [ ] Read current file (1725 lines)
- [ ] Identify hardcoded routing logic
- [ ] Plan file split strategy
- [ ] Create feature branch: `refactor/routing-split`
- [ ] Design module structure

#### **Migration Steps**:
- [ ] Replace hardcoded route hosts
- [ ] Update test routing
- [ ] Split file into modules (< 1000 lines each)
- [ ] Maintain public API
- [ ] Comprehensive testing

#### **Post-Migration Validation**:
- [ ] All routing working
- [ ] File size compliant (< 1000 lines each)
- [ ] Public API unchanged
- [ ] Tests passing
- [ ] Instances eliminated: 0/8

**Notes**: Combine hardcoding fix with file size compliance.

---

### ✅ **FILE 8: crates/core/core/src/ecosystem.rs**

**Priority**: P0 🔴  
**Instances**: 40 (primal references)  
**Complexity**: HIGH  
**Time Estimate**: 4-5 days  
**Status**: PENDING

#### **Pre-Migration Checklist**:
- [ ] Read current file completely
- [ ] Design capability taxonomy
- [ ] Map all primal name usages
- [ ] Create feature branch: `feature/capability-discovery`
- [ ] Design backward compatibility
- [ ] Write comprehensive E2E tests

#### **Migration Steps**:
- [ ] Define Capability enum
- [ ] Implement capability-based discovery
- [ ] Replace name-based coordination
- [ ] Add fallback to name-based (compat)
- [ ] Update ecosystem integration
- [ ] Migration guide for users

#### **Post-Migration Validation**:
- [ ] All ecosystem operations working
- [ ] Capability discovery functional
- [ ] Backward compatibility maintained
- [ ] E2E tests comprehensive
- [ ] Documentation complete
- [ ] Instances eliminated: 0/40

**Notes**: Most complex migration, affects architecture.

---

## 🟡 TIER 2: HIGH PRIORITY (Week 2)

### **FILES 9-15: MCP Transport Layer** (~60 instances)

**Files**:
- `crates/core/mcp/src/transport/tcp/connection.rs` (7)
- `crates/core/mcp/src/transport/websocket/mod.rs` (4)
- `crates/core/mcp/src/transport/tests/*.rs` (multiple)
- `crates/core/mcp/src/enhanced/*.rs` (various)

**Strategy**: Batch migration, use runtime_config throughout

**Checklist Template** (per file):
- [ ] Audit hardcoded values
- [ ] Replace with runtime_config
- [ ] Update tests
- [ ] Validate functionality
- [ ] Document changes

---

### **FILES 16-20: Configuration & Testing** (~150 instances)

**Files**:
- `canonical-config/src/unified/*.rs` (~50)
- Various test files (~100)

**Strategy**: Use test fixtures, dynamic port allocation

**Checklist Template** (per file):
- [ ] Extract to test-utils
- [ ] Use runtime_config
- [ ] Add dynamic ports
- [ ] Update docs

---

## 🟢 TIER 3: TEST CODE (Week 3+)

### **Test Infrastructure** (273 instances)

**Priority**: P2-P3  
**Strategy**: Create shared test fixtures

**Checklist**:
- [ ] Create test fixture module in test-utils
- [ ] Implement dynamic port allocation
- [ ] Environment-based test config
- [ ] Update all test files
- [ ] Validate parallel test execution

---

## 📋 UNIVERSAL MIGRATION TEMPLATE

Use this for each file:

### **Phase 1: Analysis** (30 min)
- [ ] Read entire file
- [ ] Count instances
- [ ] Map dependencies
- [ ] Assess complexity
- [ ] Plan approach

### **Phase 2: Preparation** (1-2 hours)
- [ ] Create feature branch
- [ ] Write migration tests
- [ ] Design new API
- [ ] Document changes

### **Phase 3: Migration** (2-4 hours)
- [ ] Replace hardcoded values
- [ ] Update call sites
- [ ] Run tests continuously
- [ ] Fix breakage

### **Phase 4: Validation** (1-2 hours)
- [ ] Full test suite
- [ ] Manual testing
- [ ] Performance check
- [ ] Documentation update

### **Phase 5: Cleanup** (30 min)
- [ ] Remove deprecated code (after 1 release)
- [ ] Update CHANGELOG
- [ ] Mark complete
- [ ] Update this checklist

---

## 🎯 DAILY TRACKING

### **Week 1: Foundation**

#### **Day 3** (Oct 31):
- [ ] Complete: network.rs (100 instances)
- [ ] Start: host_config.rs POC
- **Target**: 100 instances

#### **Day 4** (Nov 1):
- [ ] Complete: host_config.rs (120 instances)
- [ ] Start: service_discovery/types.rs
- **Target**: 220 instances

#### **Day 5** (Nov 2):
- [ ] Complete: types.rs + client.rs (78 instances)
- **Target**: 298 instances

#### **Day 6** (Nov 3):
- [ ] Complete: registry.rs + memory.rs (78 instances)
- **Target**: 376 instances

#### **Day 7** (Nov 4):
- [ ] Complete: routing.rs (8 instances)
- [ ] Buffer/catch-up
- **Target**: 384 instances

---

## 📊 SUCCESS METRICS

### **Completion Tracking**:
- [ ] Week 1: 240/893 = 27% ✅
- [ ] Week 2: 620/893 = 69% ✅
- [ ] Week 3: 820/893 = 92% ✅
- [ ] Final: 893/893 = 100% 🏆

### **Quality Gates**:
- [ ] All tests passing (100%)
- [ ] No new hardcoded values
- [ ] Environment-driven configuration working
- [ ] Service discovery integrated
- [ ] Backward compatibility maintained
- [ ] Documentation complete
- [ ] Migration guide published

---

## 🚨 RISK MONITORING

### **Active Risks**:
- [ ] Breaking changes (HIGH) - Mitigate with feature flags
- [ ] Service discovery complexity (MEDIUM) - Start simple
- [ ] Test breakage (MEDIUM) - Update in parallel
- [ ] Performance impact (LOW) - Cache config reads

### **Mitigation Actions**:
- [ ] Feature flags for gradual rollout
- [ ] Extensive testing at each step
- [ ] Backward compatibility for 1 release
- [ ] Performance benchmarks

---

## 📝 NOTES & LEARNINGS

### **Patterns That Work**:
- Environment-first configuration
- Lazy initialization with caching
- Backward compatibility during migration
- Comprehensive testing before changes

### **Patterns to Avoid**:
- Big-bang migrations
- Breaking public APIs without deprecation
- Insufficient testing
- Missing documentation updates

### **Tools Used**:
- `runtime_config` module (NEW)
- Feature branches per file
- Deprecation warnings
- Migration tests

---

**Status**: 🟢 **READY TO EXECUTE**  
**Updated**: October 30, 2025 - Evening  
**Next Update**: Daily during execution  
**Completion Target**: November 20, 2025

🚀 **Let's eliminate hardcoding systematically!**

