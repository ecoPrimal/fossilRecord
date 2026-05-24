# 📊 Test Coverage Sprint Plan
## Path from 44.36% → 60% → 90%

**Created**: November 18, 2025  
**Current Coverage**: 44.36%  
**Phase 1 Target**: 60% (+15.64pp)  
**Final Target**: 90% (+45.64pp)

---

## 🎯 Coverage Analysis

### Current State
```
Overall Coverage:    44.36%
Lines:              39,675 / 89,439
Functions:          3,606 / 9,026 (39.95%)
Regions:            28,522 / 66,975 (42.59%)
```

### Critical Areas with 0% Coverage

#### 1. Learning System (LARGEST GAP) 🔴
**Location**: `core/context/src/learning/`  
**Coverage**: 0-5%  
**Lines**: ~2,800 uncovered  
**Modules**:
- adaptive.rs (0%) - 306 lines
- engine.rs (0%) - 327 lines
- experience.rs (0%) - 365 lines
- integration.rs (0%) - 504 lines
- manager.rs (0%) - 429 lines
- metrics.rs (0%) - 291 lines
- policy.rs (0%) - 328 lines
- reward.rs (0%) - 326 lines
- mod.rs (4.78%) - 199 lines

**Impact**: HIGH - Core business logic  
**Priority**: 1 (Sprint 1-2)

#### 2. Visualization System 🟡
**Location**: `core/context/src/visualization/`  
**Coverage**: 0%  
**Lines**: ~762 uncovered  
**Impact**: MEDIUM - Nice to have, not critical  
**Priority**: 4 (Sprint 5-6)

#### 3. MCP Error Handling 🔴
**Location**: `core/mcp/src/error/`  
**Coverage**: 0%  
**Lines**: ~248 uncovered  
**Impact**: HIGH - Error handling is critical  
**Priority**: 2 (Sprint 3)

#### 4. Auth System 🟡
**Location**: `core/auth/src/`  
**Coverage**: 0%  
**Lines**: ~20 uncovered  
**Impact**: MEDIUM - Small module  
**Priority**: 3 (Sprint 4)

### Areas with Low Coverage

#### 5. Sync Module 🔴
**Location**: `core/context/src/sync.rs`  
**Coverage**: 5.36%  
**Lines**: 354/389 uncovered  
**Impact**: HIGH - Synchronization is critical  
**Priority**: 2 (Sprint 3)

#### 6. Config Loader 🟡
**Location**: `config/src/unified/loader.rs`  
**Coverage**: 32.40%  
**Lines**: 107/162 uncovered  
**Impact**: MEDIUM  
**Priority**: 3 (Sprint 4)

#### 7. Rules Core 🟡
**Location**: `core/context/src/rules/mod.rs`  
**Coverage**: 37.76%  
**Lines**: 91/142 uncovered  
**Impact**: MEDIUM  
**Priority**: 3 (Sprint 4)

---

## 🚀 Sprint Plan

### Sprint 1: Learning System Foundation (8-10 hours)
**Target**: +5% coverage  
**Focus**: Core learning modules

**Tasks**:
1. ✅ Test `learning/mod.rs` (4.78% → 80%)
   - Basic learning system initialization
   - Module integration
   - ~40 lines covered

2. ✅ Test `learning/engine.rs` (0% → 60%)
   - Learning engine basics
   - Training loops
   - ~200 lines covered

3. ✅ Test `learning/manager.rs` (0% → 60%)
   - Manager initialization
   - Basic operations
   - ~260 lines covered

**Expected**: 500 new lines covered = +0.56% overall

### Sprint 2: Learning System Advanced (8-10 hours)
**Target**: +5% coverage  
**Focus**: Advanced learning modules

**Tasks**:
1. ✅ Test `learning/adaptive.rs` (0% → 70%)
   - Adaptive learning
   - Algorithm tests
   - ~210 lines covered

2. ✅ Test `learning/experience.rs` (0% → 70%)
   - Experience replay
   - Memory management
   - ~255 lines covered

3. ✅ Test `learning/metrics.rs` (0% → 70%)
   - Metrics collection
   - Performance tracking
   - ~200 lines covered

**Expected**: 665 new lines covered = +0.74% overall

### Sprint 3: Critical Infrastructure (6-8 hours)
**Target**: +4% coverage  
**Focus**: Sync & error handling

**Tasks**:
1. ✅ Test `sync.rs` (5.36% → 70%)
   - Synchronization primitives
   - Thread safety
   - ~250 lines covered

2. ✅ Test `mcp/error/*.rs` (0% → 80%)
   - Error types
   - Error handling
   - Error conversion
   - ~200 lines covered

**Expected**: 450 new lines covered = +0.50% overall

### Sprint 4: Configuration & Rules (6-8 hours)
**Target**: +3% coverage  
**Focus**: Config and rules

**Tasks**:
1. ✅ Test `unified/loader.rs` (32.40% → 80%)
   - Config loading
   - Validation
   - ~75 lines covered

2. ✅ Test `rules/mod.rs` (37.76% → 80%)
   - Rule management
   - Rule execution
   - ~60 lines covered

3. ✅ Test `auth/src/*.rs` (0% → 80%)
   - Authentication
   - Authorization
   - ~16 lines covered

**Expected**: 151 new lines covered = +0.17% overall

### Sprint 5-6: Optional (Stretch Goals) (10-12 hours)
**Target**: +3% coverage  
**Focus**: Visualization & polish

**Tasks**:
1. ✅ Test visualization modules (if time allows)
2. ✅ Improve existing low-coverage areas
3. ✅ Edge cases and error paths

---

## 📊 Progress Tracking

### Phase 1 Target: 60% (+15.64pp)

| Sprint | Hours | Lines | Coverage Δ | Total Coverage |
|--------|-------|-------|------------|----------------|
| **Current** | 0 | 39,675 | - | 44.36% |
| Sprint 1 | 8-10 | +500 | +0.56% | 44.92% |
| Sprint 2 | 8-10 | +665 | +0.74% | 45.66% |
| Sprint 3 | 6-8 | +450 | +0.50% | 46.16% |
| Sprint 4 | 6-8 | +151 | +0.17% | 46.33% |
| **Sub-total** | **28-36** | **+1,766** | **+1.97%** | **46.33%** |

**Gap Analysis**:  
- Target: 60% (53,663 lines)  
- After Sprint 4: 46.33% (41,441 lines)  
- Still need: +13.67% (+12,222 lines)  
- Additional sprints needed: 6-8 more

### Realistic Timeline

**Conservative Estimate**:
- Sprints 1-4: 28-36 hours (achievable)
- Additional work: 40-50 hours
- **Total to 60%**: 68-86 hours (~3-4 weeks)

**Aggressive Estimate**:
- Focus on high-impact modules
- Parallel test writing
- **Total to 60%**: 50-60 hours (~2-3 weeks)

---

## 🎯 Sprint Execution Strategy

### Daily Sprint Routine
1. **Analyze** (30 min)
   - Review module structure
   - Identify critical paths
   - Plan test cases

2. **Write Tests** (3-4 hours)
   - Unit tests for core functions
   - Integration tests for workflows
   - Edge case coverage

3. **Verify** (30 min)
   - Run coverage report
   - Check improvement
   - Update tracking

### Test Writing Focus
1. **Happy Path** (60% of time)
   - Basic functionality
   - Normal workflows
   - Expected inputs

2. **Error Paths** (30% of time)
   - Error handling
   - Edge cases
   - Invalid inputs

3. **Integration** (10% of time)
   - Module interactions
   - End-to-end flows
   - System integration

---

## 📋 Quick Win Opportunities

### Modules Close to Target (< 20pp needed)
1. `config/src/unified/types.rs` (79.51% → 90%) - 11pp, ~30 lines
2. `config/src/unified/validation.rs` (88.84% → 95%) - 6pp, ~20 lines
3. `adapter-pattern-tests/src/mcp.rs` (78.25% → 90%) - 12pp, ~35 lines

**Total Quick Wins**: ~85 lines = +0.09% for 2-3 hours work

### High-Impact Modules (Most lines uncovered)
1. Learning system: 2,800 lines (Sprints 1-2)
2. Visualization: 762 lines (Sprint 5-6, optional)
3. Sync module: 354 lines (Sprint 3)

---

## 🔧 Tools & Commands

### Generate Coverage Report
```bash
# HTML report
cargo llvm-cov --workspace --html -- --test-threads=1
open target/llvm-cov/html/index.html

# Summary only
cargo llvm-cov --workspace --summary-only -- --test-threads=1

# Specific crate
cargo llvm-cov -p squirrel-context --html -- --test-threads=1
```

### Check Specific Module
```bash
# Find uncovered lines
cargo llvm-cov --workspace --html -- --test-threads=1
# Look at HTML report for specific file
```

### Progress Tracking
```bash
# Quick coverage check
cargo llvm-cov --workspace --summary-only -- --test-threads=1 | grep "TOTAL"

# Line count
find crates -name "*.rs" -path "*/src/*" -not -path "*/target/*" | xargs wc -l | tail -1
```

---

## 💡 Testing Best Practices

### 1. Unit Tests
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_basic_functionality() {
        // Arrange
        let input = create_test_input();
        
        // Act
        let result = function_under_test(input);
        
        // Assert
        assert_eq!(result.status, Expected::Value);
    }
}
```

### 2. Integration Tests
```rust
#[tokio::test]
async fn test_integration_workflow() {
    // Setup
    let system = TestSystem::new().await;
    
    // Execute workflow
    let result = system.execute_workflow().await;
    
    // Verify
    assert!(result.is_ok());
}
```

### 3. Error Path Tests
```rust
#[test]
fn test_error_handling() {
    let result = function_with_error(invalid_input);
    assert!(matches!(result, Err(SpecificError::InvalidInput)));
}
```

---

## 🎓 Success Metrics

### Sprint Success Criteria
- ✅ All new tests passing
- ✅ Coverage increased by target amount
- ✅ No regressions in existing tests
- ✅ Code quality maintained (no new clippy warnings)

### Phase 1 Success (60% Coverage)
- ✅ Critical business logic covered (learning, sync, errors)
- ✅ Configuration well-tested
- ✅ Core workflows validated
- ✅ Error handling comprehensive

### Final Success (90% Coverage)
- ✅ All production code paths tested
- ✅ Edge cases covered
- ✅ Integration tests comprehensive
- ✅ Chaos and fault testing added

---

## 🚀 Getting Started

### Sprint 1 - First Session (Right Now!)

**Goal**: Test learning system foundation  
**Target**: +500 lines, +0.56% coverage  
**Time**: 3-4 hours

**Start Here**:
1. Read `crates/core/context/src/learning/mod.rs`
2. Understand the module structure
3. Write tests for initialization and basic ops
4. Move to `learning/engine.rs` for core engine tests

**Commands**:
```bash
# Start sprint
cd crates/core/context

# Check current test coverage
cargo test -p squirrel-context --lib

# Generate coverage before
cargo llvm-cov -p squirrel-context --html -- --test-threads=1

# Write tests in src/learning/mod.rs (in #[cfg(test)] section)
# Or create new test files

# Check coverage after
cargo llvm-cov -p squirrel-context --summary-only -- --test-threads=1
```

---

**Ready to start Sprint 1?** Let's begin with the learning system! 🚀

**Sprint Plan**: v1.0  
**Created**: November 18, 2025  
**Target**: 60% coverage in 3-4 weeks  
**Confidence**: 🟢 High

