# 🔨 BYOB Implementation Refactoring Plan

**File**: `crates/core/toadstool/src/byob/byob_impl.rs`  
**Current Size**: 1,138 lines  
**Target**: Split into logical modules ≤ 400 lines each

---

## 📊 Current Structure Analysis

```
Lines    Content
─────    ───────────────────────────────────────────────────
1-17     Imports
18-25    ByobComputeExecutor struct (8 lines)
28-45    ActiveDeployment struct (18 lines)
48-87    ByobExecutorConfig struct + Default impl (40 lines)
90-112   ByobExecutor trait definition (23 lines)
114-620  ByobComputeExecutor impl (private methods) (~506 lines) ⚠️
621-883  ByobExecutor trait impl (public API) (~262 lines) ⚠️
884-888  Factory function (5 lines)
─────────────────────────────────────────────────────────────
Total: 1,138 lines
```

## 🎯 Refactoring Strategy

Split into 4 focused modules by responsibility:

###  1. **config.rs** (~60 lines)
**Responsibility**: Configuration and settings
- `ByobExecutorConfig` struct
- `Default` implementation  
- Configuration validation
- Environment loading

### 2. **deployment.rs** (~150 lines)
**Responsibility**: Deployment state and lifecycle
- `ActiveDeployment` struct
- Deployment status management
- Resource tracking
- Network management helpers

### 3. **executor.rs** (~550 lines) 
**Responsibility**: Core execution logic (private methods)
- `ByobComputeExecutor` struct
- Private helper methods:
  - `validate_deployment_request()`
  - `create_deployment_network()`
  - `execute_services()`
  - `monitor_service_health()`
  - `allocate_resources()`
  - `handle_service_dependencies()`
  - etc.

### 4. **trait_impl.rs** (~300 lines)
**Responsibility**: Public API implementation
- `ByobExecutor` trait definition
- Trait implementation for `ByobComputeExecutor`:
  - `deploy_biome()`
  - `get_deployment_status()`
  - `stop_deployment()`
  - `list_deployments()`
  - `get_resource_usage()`
- Factory function: `create_byob_executor()`

### 5. **mod.rs** (~40 lines) - UPDATE
**Responsibility**: Module orchestration
- Module declarations
- Re-exports
- Module-level documentation

---

## 📁 New Directory Structure

```
crates/core/toadstool/src/byob/
├── mod.rs                  (~40 lines)   ✅ Module organization
├── byob_types.rs           (existing)    ✅ Type definitions
├── config.rs               (~60 lines)   ⭐ NEW - Configuration
├── deployment.rs           (~150 lines)  ⭐ NEW - Deployment management
├── executor.rs             (~550 lines)  ⭐ NEW - Core execution logic
└── trait_impl.rs           (~300 lines)  ⭐ NEW - Public API
```

**Total lines**: ~1,100 lines (same logic, better organized)  
**Largest file**: executor.rs (550 lines) ✅ Under 1000 limit  
**Average file size**: ~220 lines per file

---

## 🔧 Implementation Steps

### Step 1: Create config.rs
1. Extract `ByobExecutorConfig` struct
2. Extract `Default` impl
3. Add environment loading helpers
4. Add validation methods

### Step 2: Create deployment.rs  
1. Extract `ActiveDeployment` struct
2. Add deployment lifecycle methods
3. Add resource tracking helpers
4. Add network management methods

### Step 3: Create executor.rs
1. Extract `ByobComputeExecutor` struct
2. Extract all private `impl` methods (lines 114-620)
3. Keep clear separation: private logic only

### Step 4: Create trait_impl.rs
1. Extract `ByobExecutor` trait definition
2. Extract trait implementation (lines 621-883)
3. Extract factory function
4. Public API only

### Step 5: Update mod.rs
1. Add new module declarations
2. Update re-exports
3. Clean up documentation

### Step 6: Delete byob_impl.rs
1. Verify all tests pass
2. Run clippy
3. Remove old file

---

## ✅ Success Criteria

- [ ] All 5 files ≤ 600 lines (target: ≤ 400 lines each)
- [ ] All tests pass (`cargo test`)
- [ ] Clippy clean (`cargo clippy`)
- [ ] Clear separation of concerns
- [ ] No duplicate code
- [ ] Improved testability (smaller units)

---

## 🧪 Testing Strategy

After each step:
```bash
# Verify compilation
cargo build --package toadstool-core

# Run tests
cargo test --package toadstool-core --lib byob

# Check linting
cargo clippy --package toadstool-core --lib
```

---

## 📝 Notes

- **Preserve all functionality**: Zero behavior changes
- **Maintain API compatibility**: Public interface unchanged
- **Improve testability**: Smaller units easier to test
- **Better organization**: Clear responsibility per file
- **Future maintainability**: Easier to understand and modify

---

## 🎯 Impact

**Before**:
- 1 monolithic file (1,138 lines)
- Mixed concerns (config, state, logic, API)
- Hard to test individual components
- Violates 1000-line guideline

**After**:
- 5 focused modules (~220 lines average)
- Clear separation of concerns
- Easy to test each component
- Complies with 1000-line guideline ✅
- Better cognitive load (smaller units)

---

**Status**: Ready to execute  
**Estimated Time**: 2-3 hours  
**Risk**: Low (preserving all behavior)  
**Benefit**: High (maintainability, testability, compliance)

