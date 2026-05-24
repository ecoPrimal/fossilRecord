# Test Infrastructure Fix Plan

**Created**: October 14, 2025 (Evening)  
**Status**: Ready to implement  
**Priority**: CRITICAL - Blocks all test expansion

---

## 🎯 OBJECTIVE

Fix test compilation errors to enable:
1. Accurate test count verification
2. Coverage measurement
3. Test expansion to 90%

---

## 📊 ERROR ANALYSIS

### **Identified Issues from Audit**

From the compilation attempt, key errors found:

1. **ServiceInfo Structure Mismatch** (tests/performance_tests.rs)
   - Tests use old field names (`name`, `version`, `health_check_url`)
   - Actual struct has: `service_id`, `metadata`, `capabilities`, `endpoints`, `last_seen`
   
2. **Missing Trait Implementations**
   - `PerformanceMetrics::new()` not found
   - Clone not implemented for some types
   
3. **Type Mismatches**
   - ServiceMetadata vs HashMap mismatch
   - ServiceEndpoint vs String mismatch

---

## 🔧 FIX STRATEGY

### **Option A: Fix Tests to Match Current API** ✅ RECOMMENDED
- Update test code to use current struct definitions
- Less risk, maintains API stability
- Estimated: 2-4 hours

### **Option B: Update API to Match Tests** ❌ NOT RECOMMENDED
- Would break existing code
- Higher risk
- More extensive changes

**Decision**: Use Option A - Fix tests to match current API

---

## 📋 IMPLEMENTATION PLAN

### **Phase 1: Identify All Broken Tests** (30 min)
```bash
# Get full error list
cargo test --workspace 2>&1 > test_errors_full.log

# Count errors by file
grep "^error" test_errors_full.log | \
  awk -F'--> ' '{print $2}' | \
  awk -F':' '{print $1}' | \
  sort | uniq -c | sort -rn
```

### **Phase 2: Fix Core Test Files** (2-3 hours)

#### **File 1: tests/performance_tests.rs**
Issues: 30+ errors, ServiceInfo mismatches

**Current Code (Broken)**:
```rust
ServiceInfo {
    name: "service".to_string(),
    version: "1.0.0".to_string(),
    endpoints: vec!["http://localhost:8080"],
    health_check_url: None,
    metadata: HashMap::new(),
}
```

**Fixed Code**:
```rust
use uuid::Uuid;
use nestgate_core::service_discovery::types::*;

ServiceInfo {
    service_id: Uuid::new_v4(),
    metadata: ServiceMetadata::default(),
    capabilities: vec![],
    endpoints: vec![ServiceEndpoint {
        url: "http://localhost:8080".to_string(),
        protocol: "http".to_string(),
        health_status: HealthStatus::Unknown,
    }],
    last_seen: std::time::SystemTime::now(),
}
```

#### **File 2: tests/comprehensive_config_validation.rs**
Issues: 57 errors, likely similar ServiceInfo issues

**Action**: Apply same ServiceInfo fixes as File 1

#### **File 3: nestgate-zfs/tests/basic_functionality_tests.rs**
Issues: 22 errors

**Action**: Review and fix ZFS-specific test issues

### **Phase 3: Verify Fixes** (30 min)
```bash
# Test each module individually
cargo test -p nestgate-core
cargo test -p nestgate-api  
cargo test -p nestgate-zfs

# Full workspace
cargo test --workspace

# Should see: "test result: ok. X passed; 0 failed"
```

---

## 🚀 QUICK START

### **Step 1: Backup Current Tests** (5 min)
```bash
cd /home/eastgate/Development/ecoPrimals/nestgate
mkdir -p test_backups
cp tests/performance_tests.rs test_backups/
cp tests/comprehensive_config_validation.rs test_backups/
cp code/crates/nestgate-zfs/tests/basic_functionality_tests.rs test_backups/
```

### **Step 2: Fix performance_tests.rs** (1 hour)
Key changes needed:
- Update ServiceInfo instantiation (lines ~260, ~26)
- Add proper imports
- Fix metadata type (HashMap → ServiceMetadata)
- Fix endpoints type (Vec<String> → Vec<ServiceEndpoint>)

### **Step 3: Test and Iterate** (30 min)
```bash
# Test the fixed file
cargo test --test performance_tests

# If passes, move to next file
# If fails, review errors and iterate
```

---

## 📊 SUCCESS CRITERIA

### **Immediate** (Today)
- [ ] All test files compile without errors
- [ ] `cargo test --workspace` runs successfully
- [ ] Actual test count obtained

### **Short-term** (This Week)
- [ ] All existing tests passing
- [ ] Baseline metrics documented
- [ ] Ready for test expansion

---

## ⚠️ NOTES

1. **Don't Change APIs**: Fix tests to match current code, not vice versa
2. **Preserve Test Intent**: Keep testing the same functionality, just update syntax
3. **Document Changes**: Note what was changed and why
4. **Test Incrementally**: Fix one file at a time, test, then move to next

---

## 🔄 ALTERNATIVE APPROACH

If fixing all tests is taking too long:

### **Minimal Viable Fix**
1. Disable broken test files temporarily
2. Get baseline from working tests
3. Fix tests incrementally over time

```bash
# Rename to .disabled to skip
mv tests/performance_tests.rs tests/performance_tests.rs.disabled
mv tests/comprehensive_config_validation.rs tests/comprehensive_config_validation.rs.disabled

# Test remaining tests
cargo test --workspace
```

**Use only if needed** - Better to fix properly first

---

## 📅 TIMELINE

| Task | Duration | Status |
|------|----------|--------|
| Error analysis | 30 min | ⏳ Ready |
| Fix performance_tests.rs | 1 hour | ⏳ Ready |
| Fix comprehensive_config_validation.rs | 1 hour | ⏳ Ready |
| Fix ZFS tests | 1 hour | ⏳ Ready |
| Verify and test | 30 min | ⏳ Ready |
| **TOTAL** | **4 hours** | ⏳ Ready to start |

---

## 🎯 NEXT ACTION

**Immediate**: Start with fixing `tests/performance_tests.rs`

```bash
# Open file in editor
code tests/performance_tests.rs
# or
vim tests/performance_tests.rs

# Focus on lines with ServiceInfo
# Update to match current API (see examples above)
```

---

**Status**: Ready to implement  
**Estimated Time**: 2-4 hours  
**Confidence**: High - Clear fixes identified  
**Blocker Resolution**: Will unblock all test expansion work

---

*This plan gets test infrastructure working so we can proceed with the 30-week roadmap.*

