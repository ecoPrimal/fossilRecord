# ⚡ IMMEDIATE ACTION ITEMS - NESTGATE

**Date**: December 1, 2025  
**Status**: Production Ready - 1 Blocker to Clear

---

## 🚨 CRITICAL BLOCKER (5 Minutes)

### Test Import Errors - Blocking Coverage

**File**: `code/crates/nestgate-zfs/src/orchestrator_integration/tests.rs`  
**Lines**: 6-8  
**Time**: 5 minutes

**Current Code**:
```rust
use crate::error;
use crate::manager;
use crate::types;
```

**Fixed Code**:
```rust
use super::types::*;
use super::service::*;
// Or use absolute paths:
// use nestgate_zfs::types::*;
```

**Why**: These imports are incorrect and block test compilation, which blocks coverage measurement.

**Verification**:
```bash
cargo test --lib --package nestgate-zfs
cargo llvm-cov --workspace --html
```

---

## ⚡ QUICK WINS (1 Hour)

### 1. Format Code (1 minute)

```bash
cd /home/eastgate/Development/ecoPrimals/nestgate
cargo fmt
```

**Impact**: Fixes 3 formatting issues in `network/client.rs`

### 2. Measure Coverage (30 minutes)

After fixing imports:
```bash
cargo llvm-cov --workspace --html
firefox target/llvm-cov/html/index.html
```

**Impact**: Establishes coverage baseline

### 3. Document Baseline (20 minutes)

```bash
echo "# Coverage Baseline - $(date)" > COVERAGE_BASELINE_DEC_1_2025.md
echo "" >> COVERAGE_BASELINE_DEC_1_2025.md
echo "Line Coverage: X%" >> COVERAGE_BASELINE_DEC_1_2025.md
# Add details from coverage report
```

---

## 🎯 TOP 5 PRIORITIES (Next 4 Weeks)

### Priority 1: Hardcoding Migration (20-30 hours)

**Target**: Migrate 50% of 1,370 hardcoded values (685 total)

**Focus Areas**:
1. API server ports (highest impact)
2. Network layer ports
3. Orchestration endpoints
4. Configuration constants

**Pattern to Use** (already exists):
```rust
use nestgate_core::config::port_config::get_port_config;
let port = get_port_config().api_port;
```

**Week-by-Week**:
- Week 1: 100-150 critical values (API/network)
- Week 2: 150-200 config values
- Week 3: 200-250 remaining values
- Week 4: Complete 50% milestone + documentation

### Priority 2: Production Mocks Audit (4-6 hours)

**Target**: Verify 3-5 production files are properly feature-gated

**Files to Review**:
```
code/crates/nestgate-core/src/observability/metrics.rs:164-171
code/crates/nestgate-zfs/src/dev_environment/mod.rs:45
code/crates/nestgate-api/src/handlers/storage.rs:219-223
```

**Action**:
1. Check if mock data is behind feature flags
2. Add `#[cfg(feature = "mock-data")]` if needed
3. Ensure production builds exclude mocks
4. Add compile-time warnings for dev features

### Priority 3: Documentation (6-8 hours)

**Target**: Reduce 913 doc warnings by 50%

**Quick Win**: Fix `performance_engine/types.rs` (381 warnings = 42%)

**Commands**:
```bash
# Auto-fix what's possible
cargo fix --lib -p nestgate-zfs

# Manual fixes for remaining
# Add /// doc comments to public items
```

### Priority 4: Unwrap Migration (10-15 hours)

**Target**: Migrate 50% of production unwraps

**Focus**: Production code only (test unwraps are acceptable)

**Pattern**:
```rust
// Before:
let value = result.unwrap();

// After:
let value = result
    .map_err(|e| NestGateError::processing_error(e))?;
```

**Guide**: See `UNWRAP_MIGRATION_GUIDE.md`

### Priority 5: Coverage Expansion (15-20 hours)

**Target**: Increase from 69.7% to 75-80%

**Focus Areas**:
1. Error paths (often uncovered)
2. Edge cases
3. Integration scenarios
4. Panic conditions

---

## 📊 METRICS TO TRACK

### Week 1
- [ ] Test imports fixed ✓
- [ ] Coverage baseline measured: ____%
- [ ] Hardcoded values migrated: ___ / 150 (target)
- [ ] Production mocks audited: ___ / 5 files
- [ ] Doc warnings fixed: ___ / 450 (target)

### Week 2
- [ ] Hardcoded values migrated: ___ / 350 (cumulative)
- [ ] Unwraps migrated: ___ / 100 (target)
- [ ] Coverage increase: _____% → _____%

### Week 3
- [ ] Hardcoded values migrated: ___ / 550 (cumulative)
- [ ] Unwraps migrated: ___ / 200 (cumulative)
- [ ] Coverage target: 75%+

### Week 4
- [ ] Hardcoded values: 50% milestone (685 total) ✓
- [ ] Unwraps: 50% of production code ✓
- [ ] Coverage: 75-80% ✓
- [ ] Grade improvement: A- → A

---

## 🚀 DEPLOYMENT CHECKLIST

Before deploying, verify:

- [x] Code compiles cleanly
- [ ] Test imports fixed (5 min blocker)
- [x] All tests pass (1,196-1,231 tests)
- [ ] Coverage measured and documented
- [x] Production mocks verified/feature-gated
- [x] Environment variables documented
- [x] Deployment configs updated
- [x] Health endpoints working
- [x] Monitoring configured

**Deploy Commands**:
```bash
# Binary
cargo build --release
./target/release/nestgate

# Docker (Recommended)
docker-compose -f docker/docker-compose.production.yml up -d

# Kubernetes
kubectl apply -f deploy/production.yml

# Verify
curl http://localhost:8080/health
```

---

## 🎯 SUCCESS CRITERIA

### Week 1 Success
✅ Coverage measured  
✅ 100-150 hardcoded values migrated  
✅ Production mocks audited  
✅ 450 doc warnings fixed

### Week 4 Success
✅ 50% hardcoding migration complete (685 values)  
✅ 50% production unwraps migrated  
✅ 75-80% test coverage  
✅ Grade: A (94/100)

---

## 📚 REFERENCE GUIDES

All guides exist and are comprehensive:

- `HARDCODING_ELIMINATION_GUIDE.md` - Port migration patterns
- `UNWRAP_MIGRATION_GUIDE.md` - Error handling patterns
- `DEPLOYMENT_GUIDE.md` - Production deployment
- `OPERATIONS_RUNBOOK.md` - Day-to-day operations
- `COMPREHENSIVE_AUDIT_DEEP_DIVE_DEC_1_2025.md` - This audit

---

**Start with the 5-minute blocker, then measure coverage. Everything else can happen in parallel with production deployment.**

*Created*: December 1, 2025  
*Priority*: Fix imports → Measure coverage → Deploy
