# ⚡ QUICK ACTION ITEMS - Priority Sorted
**ToadStool Audit Findings - November 18, 2025**

---

## 🚨 CRITICAL (P1) - Next 2 Weeks

### 1. Zero Coverage Files - 2 files, 1,581 lines 🚨
```
crates/cli/src/executor/executor_impl.rs    0% (938 lines)
crates/core/toadstool/src/ecosystem.rs      0% (643 lines)
```
**Action**: Create 70-90 tests  
**Timeline**: 1 week  
**Risk**: HIGH

### 2. Continue Test Coverage Sprint
**Current**: 53.08%  
**Target Week 2**: 60%  
**Remaining**: +75 tests needed

**Next Modules**:
- WebSocket integration (+50 tests)
- Runtime engines (+60 tests)

---

## ⚠️ HIGH (P2) - Weeks 3-6

### 3. Large Production Files - 5 files
```
crates/runtime/wasm/src/lib.rs             1,255 lines
crates/distributed/src/universal/substrate.rs  1,194 lines
crates/security/sandbox/src/manager.rs     1,033 lines
crates/runtime/container/src/lib.rs        1,016 lines
crates/management/monitoring/src/lib.rs    1,004 lines
```
**Action**: Split into logical submodules  
**Timeline**: 4-5 weeks  
**Plan**: `INTELLIGENT_REFACTORING_PLAN.md`

### 4. Hardcoded Production Values - 38 instances
**Key Files**:
- `server/src/lib.rs` (3 ports)
- `cli/src/ecosystem/mod.rs` (15 URLs)
- `api/src/constants.rs` (17 limits)

**Action**: Extract to `toadstool.toml` config  
**Timeline**: 3-4 weeks

### 5. Error Handling - 623 production unwrap/expect
**Action**: Migrate to Result<> with proper propagation  
**Timeline**: 4-6 weeks  
**Effort**: ~100 unwrap/expect per week

---

## 📋 MEDIUM (P3) - Weeks 7-12

### 6. Test Coverage to 90%
**Current**: 53%  
**Target**: 90%  
**Gap**: +37 percentage points  
**Tests Needed**: +500-700 tests

### 7. Zero-Copy Optimization
**Current**: 0 Cow<> usage, 1,766 .clone()  
**Target**: Strategic Cow<> in hot paths  
**Expected Gain**: 10-17% performance  
**Timeline**: 5-8 weeks

### 8. E2E/Chaos Test Expansion
**Current**: 28+ tests  
**Target**: 95+ tests  
**Gap**: 67 tests  
**Categories**:
- E2E: +40 tests
- Chaos: +13 tests
- Fault: +14 tests

---

## 🎯 LOW (P4) - Weeks 13+

### 9. Test File Refactoring - 12 large files
**Average Size**: 1,100 lines  
**Action**: Split by test category  
**Timeline**: 6-8 weeks

### 10. Scattered Constants - 174 instances
**Action**: Organize into proper modules  
**Timeline**: 2-3 weeks

---

## ✅ VERIFIED COMPLETE (No Action)

- ✅ **Linting**: 100% clippy passing
- ✅ **Formatting**: 100% rustfmt compliant  
- ✅ **Documentation**: cargo doc passing
- ✅ **Safety**: Zero unsafe blocks
- ✅ **Sovereignty**: 100/100 score
- ✅ **Build**: Clean, no warnings
- ✅ **Tests**: 329/329 passing

---

## 📅 TIMELINE SUMMARY

```
Week 1-2   (Now):      P1 - Zero coverage files + 60% target
Week 3-6   (Dec):      P2 - File refactoring + hardcoding
Week 7-12  (Jan-Feb):  P3 - 90% coverage + zero-copy
Week 13-16 (Mar):      P4 - Final polish + audit
```

**Production Target**: Q1 2026 (February-March)

---

## 🎯 SUCCESS METRICS

### Week 2 (P1 Complete)
- ✅ executor_impl.rs: 0% → 70%
- ✅ ecosystem.rs: 0% → 70%
- ✅ Workspace coverage: 53% → 60%
- ✅ Grade: B+ (87) → B+ (89)

### Week 6 (P2 Complete)
- ✅ 5 large files refactored
- ✅ 38 hardcoded values extracted
- ✅ Workspace coverage: 60% → 70%
- ✅ Grade: B+ (89) → A- (92)

### Week 12 (P3 Complete)
- ✅ Workspace coverage: 70% → 90%
- ✅ Zero-copy implemented
- ✅ E2E/Chaos expanded
- ✅ Grade: A- (92) → A (95)

### Week 16 (P4 Complete)
- ✅ External audit complete
- ✅ Production ready
- ✅ Grade: A (95) → A+ (98)

---

## 🔥 THIS WEEK (Nov 18-24)

**Priority Order**:

1. **Today**: Fix executor_impl.rs coverage (20 tests)
2. **Tomorrow**: Fix ecosystem.rs coverage (20 tests)
3. **Wed-Thu**: WebSocket tests (50 tests)
4. **Fri**: Runtime engine tests (30 tests)

**Goal**: 60% coverage by Friday ✅

---

## 📞 QUICK VERIFICATION COMMANDS

```bash
# Check coverage
cargo llvm-cov --workspace --html
open target/llvm-cov/html/index.html

# Check quality
cargo clippy --workspace -- -D warnings
cargo fmt --all -- --check

# Run tests
cargo test --workspace --lib

# Check file sizes
find crates -name "*.rs" -type f ! -path "*/target/*" -exec wc -l {} \; | awk '$1 > 1000'

# Check hardcoding
grep -rn "127.0.0.1\|localhost\|0.0.0.0" crates --include="*.rs" | grep -v test

# Check unwrap/expect
grep -rn "unwrap()\|expect(" crates --include="*.rs" | grep -v test | wc -l
```

---

## 💪 CONFIDENCE ASSESSMENT

| Phase | Confidence | Rationale |
|-------|-----------|-----------|
| P1 (Week 2) | 90% | Clear tasks, proven velocity |
| P2 (Week 6) | 85% | Straightforward refactoring |
| P3 (Week 12) | 80% | Systematic test expansion |
| P4 (Week 16) | 75% | External dependencies (audit) |

**Overall Confidence**: **HIGH (85%)**

---

## 🚀 BOTTOM LINE

**Today's Focus**:
1. Fix zero-coverage files (executor_impl.rs + ecosystem.rs)
2. Add 40-50 more tests
3. Measure progress with llvm-cov

**This Week's Goal**: 60% coverage ✅  
**Next Session**: Continue P1 sprint with WebSocket tests

**Status**: ✅ On track, clear priorities, high momentum

---

**Last Updated**: November 18, 2025  
**Next Update**: End of Week 2  
**Owner**: ToadStool Team

🍄 **One Priority at a Time, One Test at a Time** 🚀

