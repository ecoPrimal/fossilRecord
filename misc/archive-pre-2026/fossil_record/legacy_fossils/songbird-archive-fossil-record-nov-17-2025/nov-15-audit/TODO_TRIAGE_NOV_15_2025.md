# 📋 TODO/FIXME TRIAGE REPORT

**Date**: November 15, 2025  
**Status**: Initial Triage Complete  
**Total Markers**: 2,104 across 275 files

---

## 🎯 EXECUTIVE SUMMARY

### Classification Results

| Category | Count | Priority | Action |
|----------|-------|----------|--------|
| **Production Code** | 7 | 🔴 HIGH | Fix in Week 1 |
| **Test Code** | ~2,000+ | 🟡 MEDIUM | Document/Track |
| **Documentation** | ~90+ | 🟢 LOW | Update docs |

### Quick Wins Identified

**Production TODOs (7 items - Fix First!)**

Located in `crates/songbird-orchestrator/src/server/`:

1. **tarpc_server.rs** (4 TODOs)
   - Line 201: Implement actual service registration
   - Line 218: Implement actual service discovery
   - Line 233: Get total_services from registry
   - Line 234: Get total_peers from federation state

2. **websocket_api.rs** (2 TODOs)
   - Line 302: Get total_services from service registry
   - Line 304: Calculate actual uptime

3. **jsonrpc_api.rs** (1 TODO)
   - Line 372: Track actual uptime

---

## 🔴 PRIORITY 1: PRODUCTION CODE TODOS

### Server Implementation Gaps (7 items)

#### **File: `crates/songbird-orchestrator/src/server/tarpc_server.rs`**

**Location**: Lines 201, 218, 233, 234

```rust
// TODO: Implement actual service registration
// TODO: Implement actual service discovery  
// TODO: Get from registry
// TODO: Get from federation state
```

**Impact**: 🔴 **HIGH** - Core server functionality incomplete

**Recommendation**:
1. Implement service registration endpoint
2. Connect to existing registry module
3. Wire up federation state queries
4. Estimated time: 4-6 hours

**Dependencies**:
- Registry module (exists: `src/core/registry/mod.rs`)
- Federation state (exists: `songbird-network-federation`)

---

#### **File: `crates/songbird-orchestrator/src/server/websocket_api.rs`**

**Location**: Lines 302, 304

```rust
// TODO: Get from service registry
// TODO: Calculate uptime
```

**Impact**: 🟡 **MEDIUM** - Metrics reporting incomplete

**Recommendation**:
1. Connect to service registry for accurate counts
2. Add uptime tracking (startup timestamp)
3. Estimated time: 2-3 hours

**Quick Fix**:
```rust
// Add to server initialization
let startup_time = Instant::now();

// In metrics endpoint
let uptime_seconds = startup_time.elapsed().as_secs();
```

---

#### **File: `crates/songbird-orchestrator/src/server/jsonrpc_api.rs`**

**Location**: Line 372

```rust
// TODO: Track actual uptime
```

**Impact**: 🟡 **MEDIUM** - Same as websocket_api

**Recommendation**: Share uptime tracker between APIs (1 hour)

---

## 🟡 PRIORITY 2: TEST CODE TODOS

### Summary
- **~2,000+ markers** in test files
- **Status**: Mostly acceptable placeholders
- **Action**: Document and track, but not urgent

### Common Patterns
```rust
// TODO: Add more test cases
// TODO: Test error conditions
// TODO: Expand coverage
// FIXME: Mock response needs updating
```

**Recommendation**: 
- Create test enhancement backlog
- Address as part of test coverage expansion (Month 1-2)
- Not blocking production deployment

---

## 🟢 PRIORITY 3: DOCUMENTATION TODOS

### Summary
- **~90+ documentation TODOs**
- **Status**: Missing API docs, examples
- **Action**: Document incrementally

### Common Patterns
```rust
/// TODO: Add usage examples
/// FIXME: Update documentation
```

**Recommendation**:
- Address with clippy missing_docs warnings
- Part of documentation enhancement (Week 2-3)
- Low priority

---

## 📊 DETAILED BREAKDOWN

### By Crate

| Crate | Production | Test | Docs | Total |
|-------|-----------|------|------|-------|
| songbird-orchestrator | 7 | ~600 | ~30 | ~637 |
| songbird-universal | 0 | ~500 | ~20 | ~520 |
| songbird-config | 0 | ~300 | ~15 | ~315 |
| songbird-types | 0 | ~200 | ~10 | ~210 |
| songbird-discovery | 0 | ~150 | ~8 | ~158 |
| songbird-test-utils | 0 | ~100 | ~3 | ~103 |
| Other crates | 0 | ~150 | ~4 | ~154 |
| **TOTAL** | **7** | **~2,000** | **~90** | **~2,097** |

### By Type

| Type | Count | Notes |
|------|-------|-------|
| TODO | ~1,800 | Feature requests, enhancements |
| FIXME | ~250 | Known issues to fix |
| XXX | ~30 | Warnings, attention needed |
| HACK | ~20 | Temporary solutions |
| DEBT | ~4 | Technical debt markers |

---

## 🎯 RECOMMENDED ACTION PLAN

### Week 1: Fix Production TODOs (7 items, 8-12 hours)

**Day 1-2** (4-6 hours):
- [ ] Implement tarpc_server service registration
- [ ] Implement tarpc_server service discovery
- [ ] Connect to registry module
- [ ] Wire up federation state queries

**Day 3** (2-3 hours):
- [ ] Add uptime tracking to server
- [ ] Update websocket_api metrics
- [ ] Update jsonrpc_api metrics

**Day 4** (2-3 hours):
- [ ] Test all implementations
- [ ] Remove TODO markers
- [ ] Update documentation

### Week 2-3: Documentation TODOs (~90 items, 10-15 hours)
- [ ] Run `cargo doc` and fix warnings
- [ ] Add missing API documentation
- [ ] Add usage examples
- [ ] Update outdated docs

### Month 1-2: Test TODOs (~2,000 items, ongoing)
- [ ] Create test enhancement backlog
- [ ] Address as part of coverage expansion
- [ ] Remove completed TODOs
- [ ] Update test plans

---

## 📋 TRACKING TEMPLATE

### Production TODO Checklist

```markdown
## tarpc_server.rs (4 items)
- [ ] L201: Implement service registration
- [ ] L218: Implement service discovery  
- [ ] L233: Get total_services from registry
- [ ] L234: Get total_peers from federation

## websocket_api.rs (2 items)
- [ ] L302: Connect to service registry
- [ ] L304: Implement uptime tracking

## jsonrpc_api.rs (1 item)
- [ ] L372: Implement uptime tracking
```

---

## 📊 IMPACT ASSESSMENT

### Blocking Issues: **0**
- No TODOs block production deployment

### High Priority: **7 items**
- Server implementation gaps
- Should be completed before production

### Medium Priority: **~2,000 items**
- Test enhancements
- Address during normal development

### Low Priority: **~90 items**
- Documentation improvements
- Incremental enhancement

---

## ✅ QUICK WINS (2-3 hours)

### Uptime Tracking (1 hour)
```rust
// In main.rs or server initialization
use std::time::Instant;

pub struct ServerMetrics {
    startup_time: Instant,
}

impl ServerMetrics {
    pub fn new() -> Self {
        Self {
            startup_time: Instant::now(),
        }
    }
    
    pub fn uptime_seconds(&self) -> u64 {
        self.startup_time.elapsed().as_secs()
    }
}
```

### Registry Integration (1-2 hours)
```rust
// Already exists at crates/songbird-orchestrator/src/core/registry/mod.rs
// Just wire it up to the API endpoints

use crate::core::registry::ServiceRegistry;

// In endpoint handler
let total_services = registry.service_count().await?;
```

---

## 🎯 SUCCESS METRICS

### Week 1 Goals
- ✅ **7 production TODOs** → 0
- ✅ **Production code** has no TODO markers
- ✅ **All server APIs** fully implemented

### Month 1 Goals
- ✅ **90 documentation TODOs** → <50
- 🔄 **Test TODOs** tracked in backlog
- ✅ **All critical TODOs** resolved

### Month 3 Goals
- ✅ **All TODOs** documented or resolved
- ✅ **Test backlog** actively maintained
- ✅ **New TODOs** use issue tracker instead

---

## 📞 RESOURCES

### Code Locations
- Production TODOs: `crates/songbird-orchestrator/src/server/`
- Registry module: `crates/songbird-orchestrator/src/core/registry/mod.rs`
- Federation: `crates/songbird-network-federation/`

### Related Files
- `UNWRAP_TRIAGE_NOV_15_2025.md` - Error handling plan
- `COMPREHENSIVE_AUDIT_REPORT_NOV_15_2025_FRESH.md` - Full audit
- `AUDIT_COMPLETE_NEXT_STEPS.md` - Action plan

---

**Triage Complete**: November 15, 2025  
**Priority 1 Items**: 7 (8-12 hours to resolve)  
**Status**: ✅ **ACTIONABLE PLAN READY**  
**Next Step**: Begin Week 1 fixes

🎯 **7 Production TODOs → Clear Path to Zero** 🚀

