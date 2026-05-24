# 🔧 Primal Hardcoding Fix Log
**Date**: December 2, 2025 (Evening Session)  
**Task**: Migrate from hardcoded primal names to capability-based discovery  
**Priority**: 🔴 CRITICAL (Spec Violation)

---

## 📊 STATUS SUMMARY

**Before**: 167 primal name hardcodings  
**After**: TBD (in progress)  
**Fixed**: 37+ references (E2E tests)  
**Remaining**: ~130 references  

---

## ✅ COMPLETED FIXES

### 1. E2E Test File - scenario_03_service_discovery_timeout.rs (37 refs fixed)
**File**: `code/tests/e2e/scenario_03_service_discovery_timeout.rs`  
**Changes**:
- ❌ "Songbird" → ✅ "orchestration" (capability name)
- ❌ "Squirrel" → ✅ "ai" (capability name)
- ❌ "ToadStool" → ✅ "compute" (capability name)
- ❌ "Weasel" → ✅ "security" (capability name)

**Impact**:
- All test function names updated
- All test assertions updated
- All log messages updated
- Documentation comments updated

**Pattern Used**:
```rust
// ❌ BEFORE (Hardcoded primal name)
discover_service_with_timeout("Songbird", timeout).await

// ✅ AFTER (Capability-based)
discover_service_with_timeout("orchestration", timeout).await
```

---

## 🔄 FILES ALREADY MIGRATED (Backward Compatible)

### 1. services.rs (45 refs - already migrated)
**File**: `code/crates/nestgate-core/src/config/external/services.rs`  
**Status**: ✅ **ALREADY MODERNIZED**
- Uses capability-based discovery with deprecated fallback
- Maintains backward compatibility via deprecated methods
- Proper deprecation warnings in place

### 2. services_config.rs (44 refs - already migrated)
**File**: `code/crates/nestgate-core/src/config/external/services_config.rs`  
**Status**: ✅ **ALREADY MODERNIZED**
- Capability-based configuration implemented
- Legacy env vars mapped to capabilities automatically
- Deprecation path documented

---

## 📋 REMAINING WORK

### Files Still Using Hardcoded Names (~130 refs)

#### 1. runtime.rs (20 refs) - Next Priority
**File**: `code/crates/nestgate-core/src/config/runtime.rs`  
**Status**: ⏳ PENDING
**Estimated Effort**: 1-2 hours

#### 2. Other Files (21+ refs total) - Lower Priority
**Files**:
- Production discovery modules
- Configuration helpers
- Test utilities
- Documentation examples

**Status**: ⏳ PENDING
**Estimated Effort**: 2-3 hours

---

## 🎯 MIGRATION STRATEGY

### Phase 1: Critical Test Code ✅ COMPLETE
- ✅ E2E scenario tests (37 refs)
- Result: Tests now use capability names

### Phase 2: Runtime Configuration ⏳ IN PROGRESS
- [ ] Update runtime.rs (20 refs)
- [ ] Update capability scanner
- [ ] Update discovery modules

### Phase 3: Remaining Code ⏳ PLANNED
- [ ] Fix remaining 21+ references
- [ ] Update documentation examples
- [ ] Clean up test utilities

### Phase 4: Verification ⏳ PLANNED
- [ ] Run full test suite
- [ ] Verify zero primal name hardcodings
- [ ] Update audit report

---

## 📝 MIGRATION PATTERNS

### Pattern 1: Service Discovery
```rust
// ❌ BEFORE
if service_name == "beardog" {
    connect_to_security();
}

// ✅ AFTER
if service.has_capability("security") {
    connect_to_service();
}
```

### Pattern 2: Configuration
```rust
// ❌ BEFORE
let url = env::var("NESTGATE_SONGBIRD_URL")?;

// ✅ AFTER
let url = config.get_capability_url("orchestration")?;
```

### Pattern 3: Test Setup
```rust
// ❌ BEFORE
discover_service("Songbird").await

// ✅ AFTER
discover_capability("orchestration").await
```

---

## ✅ VERIFICATION CHECKLIST

- [x] E2E tests updated to use capabilities
- [ ] Runtime config updated
- [ ] All tests still pass
- [ ] Zero primal name references remain (verify with grep)
- [ ] Documentation updated
- [ ] Audit report updated

---

## 📊 PROGRESS TRACKING

| Date | Refs Fixed | Remaining | Progress |
|------|-----------|-----------|----------|
| Dec 2 (Start) | 0 | 167 | 0% |
| Dec 2 (After E2E) | 37 | ~130 | 22% |
| Target | 167 | 0 | 100% |

---

## 🔍 VERIFICATION COMMANDS

```bash
# Count remaining hardcodings
rg -i "beardog|songbird|squirrel|toadstool" --type rust code/ | wc -l

# Find specific files
rg -i "beardog|songbird|squirrel|toadstool" --type rust code/ -l

# Show context
rg -i "beardog|songbird|squirrel|toadstool" --type rust code/ -C 2

# Verify tests pass
cargo test --workspace --lib
```

---

## 🎉 SUCCESS CRITERIA

- [ ] Zero primal name hardcodings (`rg` returns 0)
- [ ] All tests passing (100%)
- [ ] Capability-based discovery fully adopted
- [ ] Documentation updated
- [ ] Audit report shows compliance

**Target**: Complete by end of Week 1 (Dec 9, 2025)

---

**Log Started**: December 2, 2025 (Evening)  
**Last Updated**: December 2, 2025 23:00 UTC  
**Status**: 🔄 IN PROGRESS (22% complete)

