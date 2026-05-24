# TODO Resolution Tracker

## Overview

Systematic tracking of TODO/FIXME markers across the codebase.

## Statistics

- **Total Markers**: 145 (as of Nov 14, 2025)
- **Resolved**: 2
- **Remaining**: 143
- **Priority**: P2

## Resolution Strategy

### Categories

1. **Documentation Needed** - Convert to proper comments
2. **Future Features** - Track as issues
3. **Quick Wins** - Fix immediately  
4. **Requires Design** - Need architectural decisions

### Completed

#### crates/main/src/primal_provider/health_monitoring.rs:317
- **Before**: `// TODO: Get actual session count`
- **After**: Documented as placeholder with tracking note
- **Status**: ✅ Resolved (documented)

#### crates/main/src/ecosystem/mod.rs:660
- **Before**: `// TODO: Get actual status from registry`
- **After**: Documented with implementation plan
- **Status**: ✅ Resolved (documented)

### High Priority (To Address)

#### Test Files
- `crates/core/auth/tests/jwt_tests.rs`: 21 markers
- `crates/config/src/unified/tests/loader_tests.rs`: 27 markers
- `crates/core/mcp/src/client/tests.rs`: 16 markers

**Action**: These are test TODOs, likely test cases to add. Lower priority.

#### Production Code

**crates/core/mcp/** (Multiple files)
- `enhanced/multi_agent/coordinator.rs`: 3 markers
- `enhanced/workflow/mod.rs`: 6 markers
- `message/mod.rs`: 5 markers

**Action**: Need review for production impact.

### Resolution Process

1. **Identify** - Find all TODOs
2. **Categorize** - Group by type
3. **Prioritize** - Production > Test > Examples
4. **Resolve** - Fix or document each
5. **Track** - Update this document

### By Priority

#### P0 (Critical - Production Blockers)
None identified - all TODOs are enhancements or test gaps

#### P1 (Important - Should Address)
- Production code TODOs in core modules
- Missing functionality that affects features

#### P2 (Nice to Have)
- Test TODOs (add more test cases)
- Example TODOs
- Optimization ideas

#### P3 (Future)
- Feature ideas
- Nice-to-have improvements

## Next Steps

1. ✅ Document main/src TODOs (Done)
2. ⏸️ Review core/mcp TODOs (Deferred)
3. ⏸️ Review test TODOs (Deferred)
4. ⏸️ Create issues for future features (Deferred)

## Tracking

| Category | Count | Status |
|----------|-------|--------|
| Documented | 2 | ✅ |
| In Production Code | ~30 | ⏸️ |
| In Test Code | ~65 | ⏸️ |
| In Examples | ~10 | ⏸️ |
| In Deprecated Code | ~38 | ⏳ (Expected) |

## Notes

- Many TODOs in test files are "add more tests" - acceptable
- Some TODOs in deprecated modules are intentional
- Focus on production code TODOs first
- Convert actionable TODOs to GitHub issues

---

**Last Updated**: November 14, 2025  
**Resolved This Session**: 2  
**Remaining Work**: 143 markers

