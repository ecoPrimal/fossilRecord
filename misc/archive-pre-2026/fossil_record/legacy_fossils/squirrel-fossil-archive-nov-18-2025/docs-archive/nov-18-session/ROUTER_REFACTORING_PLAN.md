# 📋 ROUTER REFACTORING PLAN
## protocol/handler/router.rs (1267 lines)

---

## 📊 CURRENT STATUS

**File**: `crates/core/mcp/src/protocol/handler/router.rs`  
**Lines**: 1,267 total  
**Target**: < 1000 lines per file  
**Overage**: 267 lines (21% over target)  
**Production Unwraps**: **0** ✅ (all 38 unwraps in test code)  
**Test Status**: ✅ All passing  
**Priority**: 🟡 LOW (code is clean, just large)

---

## 🔍 CURRENT STRUCTURE

### Section 1: Domain Types (Lines 18-200, ~180 lines)
**Types Defined**:
- `TeamMessageType` enum (lines 18-49)
- `ReviewSeverity` enum (lines 52-57)
- `DocType` enum (lines 60-70)
- `Priority` enum (lines 73-79)
- `ProcessErrorType` enum (lines 82-88)
- `BuildStatus` enum (lines 91-96)
- `BuildMetrics` struct (lines 99-104)
- `TeamWorkflow` struct (lines 107-115)
- `WorkflowStatus` enum (lines 118-123)
- `TeamMessage` struct (lines 126-134)
- `ReviewRequest` struct (lines 137-146)
- `WorkflowMetrics` struct (lines 149-156)
- `StateTransition` struct (lines 158-165)
- `Task` struct (lines 167-179)
- `TaskStatus` enum (lines 181-189)
- `WorkflowFilter` struct (lines 191-198)

### Section 2: Workflow Manager (Lines 199-661, ~460 lines)
**Component**: `TeamWorkflowManager`  
**Methods**:
- Workflow creation and management
- Task handling
- Team messaging
- Metrics collection
- State transitions

### Section 3: Message Router (Lines 662-680, ~18 lines)
**Component**: `MessageRouter`  
**Methods**:
- Basic message routing
- Core routing logic

### Section 4: Tests (Lines 681-1267, ~586 lines)
**Module**: `#[cfg(test)]`  
**Content**: Comprehensive test suite

---

## 🎯 PROPOSED REFACTORING

### Plan A: Three-Module Split (RECOMMENDED)

#### Module 1: `types.rs` (~200 lines)
**Location**: `crates/core/mcp/src/protocol/handler/types.rs`  
**Contains**:
- All enum definitions (TeamMessageType, ReviewSeverity, etc.)
- All struct definitions (BuildMetrics, TeamWorkflow, etc.)
- Basic trait implementations (Clone, Debug, Serialize)

**Benefit**: Separates data models from business logic

#### Module 2: `workflow.rs` (~500 lines)
**Location**: `crates/core/mcp/src/protocol/handler/workflow.rs`  
**Contains**:
- `TeamWorkflowManager` struct and implementation
- Workflow business logic
- Task management
- Team messaging

**Benefit**: Isolates workflow management logic

#### Module 3: `router.rs` (~50 lines + tests)
**Location**: `crates/core/mcp/src/protocol/handler/router.rs`  
**Contains**:
- `MessageRouter` struct and implementation
- Core routing logic
- Re-exports from types and workflow modules
- Tests

**Benefit**: Keeps routing logic focused and small

#### Module 4: `mod.rs` (~20 lines)
**Location**: `crates/core/mcp/src/protocol/handler/mod.rs`  
**Contains**:
- Module declarations
- Public re-exports
- Module-level documentation

**Result**: 4 files, all < 600 lines each ✅

---

### Plan B: Two-Module Split (ALTERNATIVE)

#### Module 1: `types.rs` (~200 lines)
**Contains**: All type definitions

#### Module 2: `router.rs` (~500 lines + tests)
**Contains**: All business logic and routing

**Result**: 2 files, both < 700 lines each ✅

---

## 📋 IMPLEMENTATION STEPS

### Phase 1: Preparation (30 minutes)
1. ✅ **Verify current tests pass** - Done
2. ✅ **Document current structure** - Done  
3. ✅ **Identify dependencies** - Done
4. ⏳ **Create git branch** - `refactor/router-split`
5. ⏳ **Backup current file** - Copy to `router.rs.backup`

### Phase 2: Create Type Module (30 minutes)
1. Create `types.rs`
2. Move all enum and struct definitions
3. Ensure all types are `pub`
4. Add module-level documentation
5. Verify compilation: `cargo check -p squirrel-mcp`

### Phase 3: Create Workflow Module (45 minutes)
1. Create `workflow.rs`
2. Move `TeamWorkflowManager` and implementation
3. Add `use crate::protocol::handler::types::*;`
4. Update imports
5. Verify compilation: `cargo check -p squirrel-mcp`

### Phase 4: Update Router (30 minutes)
1. Keep `MessageRouter` in `router.rs`
2. Add re-exports: `pub use types::*;` and `pub use workflow::*;`
3. Update imports
4. Move test module to stay in `router.rs`
5. Verify compilation: `cargo check -p squirrel-mcp`

### Phase 5: Create Module File (15 minutes)
1. Create or update `mod.rs`
2. Add module declarations
3. Add public re-exports
4. Add module documentation

### Phase 6: Testing & Validation (30 minutes)
1. Run full test suite: `cargo test -p squirrel-mcp`
2. Run clippy: `cargo clippy -p squirrel-mcp`
3. Run fmt: `cargo fmt --check`
4. Verify no regressions
5. Check coverage maintained

### Phase 7: Documentation (15 minutes)
1. Update module-level docs
2. Add migration notes
3. Update CHANGELOG.md
4. Create refactoring summary

**Total Estimated Time**: 3 hours 15 minutes

---

## 🚨 RISKS & MITIGATION

### Risk 1: Breaking Changes
**Risk**: Refactoring breaks existing code  
**Likelihood**: Medium  
**Impact**: High  
**Mitigation**:
- Work in feature branch
- Run tests after each step
- Keep backup of original
- Use git to revert if needed

### Risk 2: Import Path Changes
**Risk**: External code importing these types breaks  
**Likelihood**: Medium  
**Impact**: Medium  
**Mitigation**:
- Add re-exports in original location
- Deprecation warnings for old paths
- Update internal imports first

### Risk 3: Test Failures
**Risk**: Tests fail after refactor  
**Likelihood**: Low (tests are well-isolated)  
**Impact**: Medium  
**Mitigation**:
- Tests stay in router.rs initially
- Move tests only after logic works
- Test after each module creation

---

## ✅ VALIDATION CRITERIA

### Must Pass
- [ ] All 1,258 tests passing
- [ ] `cargo check --workspace` succeeds
- [ ] `cargo clippy --workspace` has no new warnings
- [ ] `cargo fmt --check` passes
- [ ] No changes to public API (re-exports maintain compatibility)
- [ ] Coverage maintained at 44.36% or better

### Should Pass
- [ ] Each file < 1000 lines
- [ ] Clear separation of concerns
- [ ] Improved readability
- [ ] Better navigation in IDE

### Nice to Have
- [ ] Reduced compile times (smaller modules)
- [ ] Easier to test individual components
- [ ] Better documentation structure

---

## 📊 EXPECTED RESULTS

### Before Refactoring
| File | Lines | Status |
|------|-------|--------|
| `router.rs` | 1,267 | ⚠️ Over limit |

### After Refactoring (Plan A)
| File | Lines | Status |
|------|-------|--------|
| `types.rs` | ~200 | ✅ Well under |
| `workflow.rs` | ~500 | ✅ Under limit |
| `router.rs` | ~50 | ✅ Well under |
| `mod.rs` | ~20 | ✅ Minimal |

**Total Lines**: ~770 (down from 1,267 w/o tests)  
**Max File Size**: ~500 lines ✅  
**Benefit**: ✅ All files under 1000-line limit

---

## 🎓 PATTERNS TO APPLY

### Pattern 1: Clear Module Boundaries
```rust
// types.rs - Pure data definitions
pub struct TeamMessage {
    pub id: String,
    pub type_: TeamMessageType,
    // ...
}

// workflow.rs - Business logic
pub struct TeamWorkflowManager {
    // Uses types from types.rs
}

impl TeamWorkflowManager {
    pub fn new() -> Self {
        // ...
    }
}

// router.rs - Routing logic + re-exports
pub use types::*;  // Re-export for compatibility
pub use workflow::*;

pub struct MessageRouter {
    workflow_manager: TeamWorkflowManager,
}
```

### Pattern 2: Backward Compatibility
```rust
// mod.rs - Maintain public API
pub mod types;
pub mod workflow;
pub mod router;

// Re-export everything at module level
pub use types::*;
pub use workflow::*;
pub use router::*;
```

### Pattern 3: Progressive Migration
```rust
// Step 1: Create new modules
// Step 2: Add re-exports in old location
// Step 3: Update internal imports
// Step 4: Add deprecation warnings (optional)
// Step 5: Update external code (later)
```

---

## 📝 NOTES

### Why NOT Refactor Immediately?
1. ✅ **Code is clean** - 0 production unwraps, all in tests
2. ✅ **Tests are passing** - 1,258 tests, 100% pass rate
3. ⏰ **Time investment** - Requires 3+ hours + testing
4. 🎯 **Priority** - Nice-to-have, not critical
5. 📋 **Session length** - User already 3.5+ hours in

### When TO Refactor?
**Triggers for refactoring**:
- Before adding major new routing features
- When file approaches 1500 lines
- When adding new team/workflow capabilities
- During dedicated refactoring sprint
- When onboarding new developers (improved navigation)

### Alternative: Live With It
**Argument**: File is large but well-organized
- Clear sections (types, workflow, router, tests)
- Easy to navigate with IDE (jump to definition)
- All code is clean (0 production unwraps)
- Tests are comprehensive
- No actual problems, just size

**Counter**: Technical excellence demands adherence to limits
- 1000-line limit exists for good reasons
- Smaller files = easier review
- Better for IDE performance
- Easier to test in isolation

---

## 🎯 RECOMMENDATION

### Immediate Action: ✅ DOCUMENT & DEFER
**Status**: Document plan, defer actual refactoring

**Rationale**:
1. Code is clean and working
2. No functional issues
3. Significant time investment needed
4. Better as dedicated refactoring task
5. Session already productive (3.5 hours of critical work)

### Future Action: 📋 SCHEDULED REFACTORING
**When**: Next refactoring sprint or before major routing changes  
**Approach**: Follow Plan A (three-module split)  
**Time**: Allocate 4 hours (3h work + 1h testing)  
**Branch**: Create `refactor/router-split`

---

## ✅ COMPLETION CRITERIA

For this planning task:
- [x] Document current structure
- [x] Propose refactoring approach
- [x] Estimate time and effort
- [x] Identify risks and mitigation
- [x] Create implementation steps
- [x] Establish validation criteria
- [x] Make recommendation

**Planning Status**: ✅ **COMPLETE**  
**Implementation Status**: 📋 **DEFERRED** (by design)

---

## 🏁 SUMMARY

**Current State**: Large but clean file (1267 lines, 0 production unwraps)  
**Proposed Change**: Split into 3-4 modules (all < 600 lines)  
**Estimated Effort**: 3-4 hours  
**Priority**: 🟡 LOW (nice-to-have)  
**Recommendation**: ✅ **Document now, implement later**

**Confidence**: 🟢 HIGH (plan is solid, just deferring execution)

*"Code is clean and working. Refactoring plan documented. Ready when needed."* 📋✨

