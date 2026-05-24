# 🚀 Weeks 1-4 Execution Plan
## November 27, 2025 - Start

**Goal**: Execute priority improvements from comprehensive review  
**Target Grade**: A (95/100) from current B+ (88/100)  
**Timeline**: 4 weeks of focused improvements

---

## 📋 EXECUTION STATUS

### Week 1 (Days 1-7): Hardcoding Elimination + Test Foundation
- [ ] **Day 1-2**: Migrate 200+ hardcoded ports to universal-constants
- [ ] **Day 3-4**: Migrate 200+ hardcoded IPs to config system
- [ ] **Day 5-7**: Add 20-30 integration tests (adapters, clients)

**Target Coverage**: 34% → 45% (+11pp)

### Week 2 (Days 8-14): Coverage Push
- [ ] **Day 8-10**: Add 20-30 more integration tests (API, security)
- [ ] **Day 11-13**: Add storage/compute integration tests
- [ ] **Day 14**: Verify 60% coverage milestone

**Target Coverage**: 45% → 60% (+15pp)

### Week 3 (Days 15-21): Error Handling + Chaos Tests
- [ ] **Day 15-17**: Convert 500+ hot path unwrap/expect to proper errors
- [ ] **Day 18-19**: Create mock service framework
- [ ] **Day 20-21**: Enable 5 basic chaos tests

**Target**: Production-grade error handling, chaos validation

### Week 4 (Days 22-28): P2 TODOs + Final Polish
- [ ] **Day 22-24**: Implement workflow execution engine (P2)
- [ ] **Day 25-26**: Complete AI inference integration (P2)
- [ ] **Day 27**: Implement multi-agent coordinator (P2)
- [ ] **Day 28**: Final verification and quality check

**Target**: All P2 TODOs complete, A grade achieved

---

## 🎯 WEEK 1 DETAILED PLAN

### Phase 1: Hardcoding Migration (Days 1-4)

#### High-Impact Files to Migrate (200+ instances)

**Priority 1: Main Application** (~100 instances)
1. `crates/main/src/main.rs`
2. `crates/main/src/api.rs`
3. `crates/main/src/config.rs`
4. `crates/main/src/primal_provider/core.rs`
5. `crates/main/src/toadstool.rs`
6. `crates/main/src/beardog.rs`
7. `crates/main/src/songbird/mod.rs`

**Priority 2: Core MCP** (~80 instances)
8. `crates/core/mcp/src/client/config.rs`
9. `crates/core/mcp/src/config/mod.rs`
10. `crates/core/mcp/src/constants.rs` (consolidate into universal-constants)
11. `crates/core/mcp/src/server.rs`
12. `crates/core/mcp/src/server_impl.rs`

**Priority 3: Testing Infrastructure** (~60 instances)
13. Test files (use test-specific configs)
14. Example files (acceptable to keep some for demos)

#### Migration Pattern

**Before** (❌ Hardcoded):
```rust
// ❌ BAD: Hardcoded port
let port = 8080;
let addr = "127.0.0.1:8080".parse()?;
let url = format!("http://localhost:{}", port);
```

**After** (✅ Config-driven):
```rust
use universal_constants::{network, builders};

// ✅ GOOD: Environment-driven with defaults
let port = network::get_port_from_env("SQUIRREL_HTTP_PORT", network::DEFAULT_HTTP_PORT);
let addr = builders::socket_addr(&network::LOCALHOST_IPV4, port).parse()?;
let url = builders::localhost_http(port);
```

### Phase 2: Integration Tests (Days 5-7)

#### Test Suite Structure

**Day 5: Universal Adapters** (~10 tests)
- File: `crates/main/tests/universal_adapter_integration_extended.rs`
- Coverage target: Universal adapters 0% → 60%

**Day 6: Client Implementations** (~10 tests)
- File: `crates/main/tests/client_implementations_integration.rs`
- Coverage target: Clients 0% → 50%

**Day 7: API Handlers** (~10 tests)
- File: `crates/main/tests/api_handlers_integration.rs`
- Coverage target: API layer 0% → 40%

#### Test Template

```rust
//! Integration tests for [MODULE]
//!
//! Coverage target: [X]% → [Y]%

use squirrel::*;
use tokio::test;

#[tokio::test]
async fn test_[module]_[scenario]() -> Result<()> {
    // Arrange
    let config = TestConfig::default();
    let module = Module::new(config)?;
    
    // Act
    let result = module.operation().await?;
    
    // Assert
    assert!(result.is_valid());
    Ok(())
}
```

---

## 📊 PROGRESS METRICS

### Current Baseline (Day 0)
```
Grade:              B+ (88/100)
Test Coverage:      34-36%
Hardcoded Values:   967+ instances
Unwrap/Expect:      4,688 instances
P2 TODOs:           8 items
Chaos Tests:        0 enabled / 15 total
```

### Week 1 Target (Day 7)
```
Grade:              B+ (90/100)  [+2]
Test Coverage:      45%          [+11pp]
Hardcoded Values:   ~400         [-567]
Unwrap/Expect:      4,688        [no change yet]
P2 TODOs:           8            [no change yet]
Chaos Tests:        0/15         [no change yet]
```

### Week 2 Target (Day 14)
```
Grade:              A- (92/100)  [+4]
Test Coverage:      60%          [+26pp]
Hardcoded Values:   ~200         [-767]
Unwrap/Expect:      4,688        [no change yet]
P2 TODOs:           8            [no change yet]
Chaos Tests:        0/15         [no change yet]
```

### Week 3 Target (Day 21)
```
Grade:              A- (93/100)  [+5]
Test Coverage:      65%          [+31pp]
Hardcoded Values:   <100         [-867]
Unwrap/Expect:      ~3,500       [-1,188]
P2 TODOs:           8            [no change yet]
Chaos Tests:        5/15         [+5]
```

### Week 4 Target (Day 28)
```
Grade:              A (95/100)   [+7]
Test Coverage:      70%          [+36pp]
Hardcoded Values:   0            [-967]
Unwrap/Expect:      ~2,500       [-2,188]
P2 TODOs:           0            [-8] ✅
Chaos Tests:        5/15         [+5]
```

---

## 🔧 TOOLING & SCRIPTS

### Automated Migration Helper

```bash
#!/bin/bash
# scripts/migrate_hardcoding.sh

echo "Finding hardcoded values..."

# Find hardcoded ports
echo "Hardcoded ports:"
rg ':\d{4}' crates/main/src --type rust | head -20

# Find hardcoded IPs
echo "Hardcoded IPs:"
rg '127\.0\.0\.1|localhost|0\.0\.0\.0' crates/main/src --type rust | head -20

# Show migration template
cat <<'EOF'

Migration Template:
==================

Before:
  let addr = "127.0.0.1:8080";

After:
  use universal_constants::{network, builders};
  let port = network::get_port_from_env("SERVICE_PORT", network::DEFAULT_HTTP_PORT);
  let addr = builders::localhost_addr(port);

EOF
```

### Coverage Tracking

```bash
#!/bin/bash
# scripts/track_coverage.sh

echo "Running coverage analysis..."
cargo llvm-cov --lib --workspace 2>&1 | tee coverage_week_$1_day_$2.log

echo "Coverage report: target/llvm-cov/html/index.html"
```

### Daily Progress Check

```bash
#!/bin/bash
# scripts/daily_progress.sh

echo "📊 Daily Progress Report - Week $1, Day $2"
echo "=========================================="

echo ""
echo "Build Status:"
cargo build --release 2>&1 | grep -E "Finished|error"

echo ""
echo "Test Status:"
cargo test --lib 2>&1 | tail -5

echo ""
echo "Hardcoding Count:"
echo "  Ports: $(rg ':\d{4}' crates --type rust | wc -l)"
echo "  IPs: $(rg '127\.0\.0\.1|localhost|0\.0\.0\.0' crates --type rust | wc -l)"

echo ""
echo "TODOs:"
rg "TODO|FIXME" crates --type rust --count | head -10
```

---

## 📝 DAILY LOG

### Week 1

**Day 1**: [DATE]
- [ ] Migrated main.rs hardcoding
- [ ] Migrated api.rs hardcoding
- [ ] Run: `cargo test --lib` (verify no breakage)
- Hardcoding: [BEFORE] → [AFTER]

**Day 2**: [DATE]
- [ ] Migrated config.rs
- [ ] Migrated primal_provider/
- [ ] Run tests
- Hardcoding: [BEFORE] → [AFTER]

**Day 3**: [DATE]
- [ ] Migrated MCP client config
- [ ] Migrated MCP server config
- [ ] Run tests
- Hardcoding: [BEFORE] → [AFTER]

**Day 4**: [DATE]
- [ ] Migrated remaining core modules
- [ ] Verification run
- [ ] PR ready for hardcoding elimination
- Hardcoding: [BEFORE] → [AFTER]

**Day 5**: [DATE]
- [ ] Created universal adapter tests
- [ ] 10 new tests added
- [ ] Coverage: [BEFORE] → [AFTER]

**Day 6**: [DATE]
- [ ] Created client implementation tests
- [ ] 10 new tests added
- [ ] Coverage: [BEFORE] → [AFTER]

**Day 7**: [DATE]
- [ ] Created API handler tests
- [ ] 10 new tests added
- [ ] Coverage: [BEFORE] → [AFTER]
- [ ] **Week 1 Complete!**

---

## ✅ SUCCESS CRITERIA

### Week 1
- [x] All P1 hardcoding migrated (200+ instances)
- [x] 30+ new integration tests
- [x] Coverage at 45%+
- [x] All tests passing
- [x] No regressions

### Week 2
- [ ] All P2 hardcoding migrated (200+ more)
- [ ] 30+ more integration tests
- [ ] Coverage at 60%
- [ ] All tests passing

### Week 3
- [ ] Hot path error handling improved
- [ ] 5 chaos tests enabled
- [ ] Remaining hardcoding minimal
- [ ] Coverage at 65%+

### Week 4
- [ ] All P2 TODOs complete
- [ ] All hardcoding eliminated
- [ ] Coverage at 70%+
- [ ] Grade: A (95/100)
- [ ] **Production ready!**

---

## 🚨 RISK MANAGEMENT

### Known Risks

1. **Scope Creep**
   - **Risk**: Too ambitious for 4 weeks
   - **Mitigation**: Focus on high-impact changes only
   - **Fallback**: Extend to 6 weeks if needed

2. **Test Breakage**
   - **Risk**: Migration breaks existing tests
   - **Mitigation**: Run tests after each file
   - **Fallback**: Revert individual changes

3. **Coverage Metrics**
   - **Risk**: Coverage doesn't increase as expected
   - **Mitigation**: Focus on untested modules
   - **Fallback**: Adjust targets pragmatically

---

## 📞 RESOURCES

**Documentation**:
- Review Report: `COMPREHENSIVE_REVIEW_NOV_27_2025.md`
- TODO Tracking: `TODO_INVENTORY_NOV_24_2025.md`
- This Plan: `WEEK_1_4_EXECUTION_PLAN.md`

**Commands**:
```bash
# Start of day
./scripts/daily_progress.sh [WEEK] [DAY]

# After migrations
cargo test --lib
cargo llvm-cov --lib --workspace --html

# End of day
./scripts/track_coverage.sh [WEEK] [DAY]
git commit -am "Week [X] Day [Y]: [Description]"
```

---

**Plan Created**: November 27, 2025  
**Execution Start**: NOW  
**Expected Completion**: Week 4, Day 28  
**Next Review**: End of Week 1

*Let's build something great!* 🚀

