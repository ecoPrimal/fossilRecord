# Intelligent Test File Refactoring Plan

## Current Status
- **File**: `unified_adapter_core_tests.rs`
- **Size**: 1,231 lines (23% over 1,000 line limit)
- **Tests**: 77 tests total
- **Structure**: Already well-organized with clear section markers

## Analysis

### Current Sections (Line Distribution)
1. **Header + Basic Tests** (416 lines) - Imports, adapter creation, configuration
2. **Routing & Capability Discovery** (163 lines) - Capability routing tests  
3. **P1 Additional Coverage** (166 lines) - Registry and routing coverage
4. **P0 Error Path Tests** (159 lines) - High-value error scenarios
5. **Edge Case Tests** (140 lines) - Boundary conditions
6. **Stress & Load Tests** (62 lines) - Performance scenarios
7. **Configuration Validation** (64 lines) - Config validation
8. **Error Type Tests** (47 lines) - Error type validation

## Problems with Naive Split

❌ **Don't just split at line 600**:
- Would break logical groupings
- Would duplicate imports in every file
- Would lose semantic organization
- No reusability of test helpers

## Smart Refactoring Strategy

### Phase 1: Extract Common Utilities

Create `tests/helpers/unified_adapter_fixtures.rs`:
```rust
//! Shared test fixtures for unified adapter tests
//! 
//! Reduces duplication and provides consistent test setup

use songbird_test_utils::network_fixtures::*;
use songbird_universal::{UnifiedAdapterConfig, UnifiedUniversalAdapter};
use std::time::Duration;

/// Create adapter with test-friendly config
pub fn create_test_adapter() -> UnifiedUniversalAdapter {
    let config = UnifiedAdapterConfig {
        discovery_timeout: Duration::from_secs(5),
        health_check_interval: Duration::from_secs(30),
        max_concurrent_requests: 50,
        auto_discovery: false,
        discovery_endpoints: vec![format!("http://test:{}", test_orchestrator_port())],
    };
    UnifiedUniversalAdapter::with_config(config)
}

/// Create adapter with custom config override
pub fn create_test_adapter_with<F>(f: F) -> UnifiedUniversalAdapter
where
    F: FnOnce(&mut UnifiedAdapterConfig),
{
    let mut config = UnifiedAdapterConfig::default();
    f(&mut config);
    UnifiedUniversalAdapter::with_config(config)
}

/// Standard test endpoints
pub fn test_endpoints() -> Vec<String> {
    vec![
        format!("http://test:{}", test_orchestrator_port()),
        format!("http://test:{}", test_discovery_port()),
    ]
}
```

### Phase 2: Split by Semantic Concerns

#### File 1: `unified_adapter_config_tests.rs` (~300 lines)
**Purpose**: Configuration creation, validation, defaults
**Content**:
- Adapter creation tests (new, with_config, default)
- Config struct tests (default values, custom values)
- Config validation (timeouts, endpoints, max requests)
- Config edge cases (zero values, extreme values)

**Estimated**: ~25 tests, 300 lines

#### File 2: `unified_adapter_routing_tests.rs` (~400 lines)
**Purpose**: Routing logic, capability discovery, registry operations
**Content**:
- Routing & capability discovery section (163 lines)
- P1 additional coverage for routing/registry (166 lines)
- Registry operations
- Capability lookups

**Estimated**: ~30 tests, 400 lines

#### File 3: `unified_adapter_resilience_tests.rs` (~350 lines)
**Purpose**: Error handling, edge cases, failure scenarios
**Content**:
- P0 high-value error path tests (159 lines)
- Edge case tests (140 lines)
- Error type tests (47 lines)
- Failure recovery scenarios

**Estimated**: ~18 tests, 350 lines

#### File 4: `unified_adapter_performance_tests.rs` (~150 lines)
**Purpose**: Load, stress, concurrent operations
**Content**:
- Stress and load tests (62 lines)
- Concurrent request handling
- Performance characteristics
- Rate limiting scenarios

**Estimated**: ~4 tests, 150 lines

### Phase 3: Improve Test Quality

For each new file:
1. **DRY Principle**: Use shared fixtures instead of duplicating setup
2. **Clear Naming**: Each file's purpose is obvious from the name
3. **Focused Tests**: Each file tests one aspect of the adapter
4. **Maintainability**: Easier to find and update related tests

## Implementation Steps

### Step 1: Create Test Helpers Module
```bash
mkdir -p crates/songbird-universal/tests/helpers
touch crates/songbird-universal/tests/helpers/mod.rs
touch crates/songbird-universal/tests/helpers/unified_adapter_fixtures.rs
```

### Step 2: Extract Common Code
- Move repeated setup code to fixtures
- Create builder patterns for test configs
- Extract assertion helpers

### Step 3: Create New Test Files
- Copy relevant sections to new files
- Update imports to use shared fixtures
- Remove duplication
- Add file-level documentation

### Step 4: Verify
```bash
# Each file should pass independently
cargo test --test unified_adapter_config_tests
cargo test --test unified_adapter_routing_tests
cargo test --test unified_adapter_resilience_tests
cargo test --test unified_adapter_performance_tests

# All tests should still pass
cargo test unified_adapter
```

### Step 5: Remove Original
- Delete `unified_adapter_core_tests.rs`
- Update any documentation references

## Benefits

✅ **Maintainability**: Related tests grouped together
✅ **Discoverability**: Easy to find tests for specific functionality
✅ **Reusability**: Shared fixtures reduce duplication
✅ **Clarity**: Each file has clear purpose and scope
✅ **Compliance**: All files well under 1,000 line limit
✅ **Extensibility**: Easy to add new tests to appropriate file

## Risks & Mitigations

**Risk**: Breaking existing tests during refactor
**Mitigation**: Run tests after each file creation, keep git history

**Risk**: Import/dependency issues
**Mitigation**: Use shared fixtures module, test incrementally

**Risk**: Lost test coverage
**Mitigation**: Verify 77 tests before/after, check coverage metrics

## Alternative Considered: Module-Based Split

Could keep single file but use modules:
```rust
mod config_tests { /* tests */ }
mod routing_tests { /* tests */ }
mod error_tests { /* tests */ }
```

**Rejected because**:
- Still violates 1,000 line limit
- Modules don't reduce file size
- Separate files provide better organization

## Success Criteria

✅ No single file > 1,000 lines
✅ All 77 tests still pass
✅ No test coverage regression
✅ Reduced code duplication
✅ Clear semantic organization
✅ Easy to locate tests by functionality

---

**Status**: Ready to implement
**Estimated Time**: 30-45 minutes
**Risk Level**: LOW (incremental, testable)

