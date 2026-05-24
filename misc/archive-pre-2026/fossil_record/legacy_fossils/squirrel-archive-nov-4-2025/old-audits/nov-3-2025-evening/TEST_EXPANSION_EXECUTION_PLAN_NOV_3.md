# 🎯 Test Expansion Execution Plan - November 3, 2025

**Current Coverage**: 58.20%  
**Target Coverage**: 90%  
**Gap**: 31.8%  
**Estimated Tests Needed**: 250-350 tests

---

## 📊 **PRIORITY TARGETS** (0-50% Coverage)

### **🔴 CRITICAL - 0% Coverage** (Add tests first)

| File | Lines | Coverage | Priority | Est. Tests |
|------|-------|----------|----------|------------|
| `universal-patterns/src/lib.rs` | 81 | 0.00% | P0 | 5-10 |
| `universal-patterns/src/registry/mod.rs` | 502 | 0.00% | P0 | 30-40 |
| `universal-patterns/src/security/hardening/manager.rs` | 112 | 0.00% | P0 | 15-20 |
| `universal-patterns/src/security/traits.rs` | 12 | 0.00% | P0 | 5-8 |
| `universal-patterns/src/federation/cross_platform.rs` | 14 | 0.00% | P0 | 5-8 |

**Subtotal P0**: 65-86 tests

### **🟠 HIGH PRIORITY - <30% Coverage**

| File | Lines | Coverage | Priority | Est. Tests |
|------|-------|----------|----------|------------|
| `capabilities/taxonomy.rs` | 479 | 20.04% | P1 | 25-30 |
| `capability_discovery.rs` | 345 | 17.39% | P1 | 20-25 |
| `security/providers.rs` | 273 | 20.88% | P1 | 20-25 |
| `failsafe/operation_modes.rs` | 57 | 23.53% | P1 | 10-15 |
| `infant_discovery/http_discovery.rs` | 232 | 39.22% | P1 | 15-20 |

**Subtotal P1**: 90-115 tests

### **🟡 MEDIUM PRIORITY - 30-50% Coverage**

| File | Lines | Coverage | Priority | Est. Tests |
|------|-------|----------|----------|------------|
| `config/loader.rs` | 446 | 31.17% | P2 | 20-25 |
| `infant_discovery/protocol_clients.rs` | 234 | 37.14% | P2 | 15-20 |
| `federation/federation_network.rs` | 406 | 43.35% | P2 | 20-25 |
| `federation/consensus.rs` | 433 | 47.81% | P2 | 20-25 |
| `failsafe/capability_failsafe.rs` | 248 | 52.42% | P2 | 15-20 |
| `failsafe/mod.rs` | 176 | 49.43% | P2 | 10-15 |

**Subtotal P2**: 100-130 tests

---

## 🎯 **EXECUTION STRATEGY**

### **Phase 1: Quick Wins** (Target: 65-86 tests, ~2 hours)

Start with 0% coverage files - maximum impact per test:

1. **`universal-patterns/src/lib.rs`** (5-10 tests)
   - Module re-exports
   - Public API surface tests
   - Integration smoke tests

2. **`universal-patterns/src/security/traits.rs`** (5-8 tests)
   - Trait implementations
   - Default methods
   - Trait bounds

3. **`universal-patterns/src/federation/cross_platform.rs`** (5-8 tests)
   - Platform detection
   - Cross-platform compatibility

4. **`universal-patterns/src/security/hardening/manager.rs`** (15-20 tests)
   - Manager initialization
   - Security policy enforcement
   - Hardening operations

5. **`universal-patterns/src/registry/mod.rs`** (30-40 tests)
   - Registry operations
   - Service registration
   - Lookup and discovery

**Expected Coverage After Phase 1**: 58.20% → ~63-65%

### **Phase 2: High-Value Targets** (Target: 90-115 tests, ~3 hours)

Focus on low-coverage, high-impact modules:

1. **`capabilities/taxonomy.rs`** (25-30 tests)
   - Capability classification
   - Taxonomy traversal
   - Capability matching

2. **`capability_discovery.rs`** (20-25 tests)
   - Service discovery
   - Capability resolution
   - Discovery patterns

3. **`security/providers.rs`** (20-25 tests)
   - Security provider implementations
   - Provider selection
   - Security operations

4. **`failsafe/operation_modes.rs`** (10-15 tests)
   - Mode transitions
   - Failsafe behaviors
   - Mode validation

5. **`infant_discovery/http_discovery.rs`** (15-20 tests)
   - HTTP-based discovery
   - Endpoint resolution
   - Discovery protocols

**Expected Coverage After Phase 2**: 65% → ~72-75%

### **Phase 3: Medium Coverage Improvements** (Target: 100-130 tests, ~4 hours)

Fill gaps in partially-covered modules:

1. **`config/loader.rs`** (20-25 tests)
   - Configuration loading
   - Environment parsing
   - Config validation

2. **`infant_discovery/protocol_clients.rs`** (15-20 tests)
   - Protocol client implementations
   - Client lifecycle
   - Protocol operations

3. **`federation/federation_network.rs`** (20-25 tests)
   - Federation networking
   - Peer discovery
   - Network operations

4. **`federation/consensus.rs`** (20-25 tests)
   - Consensus algorithms
   - Voting mechanisms
   - Quorum logic

5. **`failsafe` modules** (25-35 tests)
   - Failsafe patterns
   - Recovery operations
   - Degradation modes

**Expected Coverage After Phase 3**: 75% → ~82-85%

### **Phase 4: Final Push to 90%** (Target: 50-80 tests, ~2-3 hours)

Fill remaining gaps across all modules.

**Expected Coverage After Phase 4**: 85% → ~90%+

---

## 📋 **TEST TEMPLATE**

Use this template for all new tests:

```rust
#[cfg(test)]
mod tests {
    use super::*;
    
    // ========== Unit Tests ==========
    
    #[test]
    fn test_basic_functionality() {
        // Arrange
        let input = setup_test_data();
        
        // Act
        let result = function_under_test(input);
        
        // Assert
        assert!(result.is_ok());
        assert_eq!(result.unwrap(), expected_value);
    }
    
    #[tokio::test]
    async fn test_async_functionality() {
        // Arrange
        let mock = create_mock().await;
        
        // Act
        let result = async_function(&mock).await;
        
        // Assert
        assert!(result.is_ok());
    }
    
    // ========== Error Cases ==========
    
    #[test]
    fn test_error_handling() {
        // Arrange
        let invalid_input = create_invalid_data();
        
        // Act
        let result = function_under_test(invalid_input);
        
        // Assert
        assert!(result.is_err());
        assert!(matches!(result.unwrap_err(), ExpectedError::..));
    }
    
    // ========== Edge Cases ==========
    
    #[test]
    fn test_edge_case_empty_input() {
        let result = function_under_test(vec![]);
        assert!(result.is_ok());
    }
    
    #[test]
    fn test_edge_case_boundary_values() {
        assert!(validate(0).is_err());
        assert!(validate(1).is_ok());
        assert!(validate(u32::MAX).is_ok());
    }
}
```

---

## 📊 **PROGRESS TRACKING**

### **Coverage Milestones**

- [ ] **60%** - Phase 1 complete (~65 tests)
- [ ] **70%** - Phase 2 partial (~155 tests total)
- [ ] **80%** - Phase 3 partial (~220 tests total)
- [ ] **85%** - Phase 3 complete (~255 tests total)
- [ ] **90%** - Phase 4 complete (~305+ tests total)

### **Time Estimates**

- Phase 1: 2 hours (Quick wins)
- Phase 2: 3 hours (High value)
- Phase 3: 4 hours (Medium value)
- Phase 4: 2-3 hours (Final push)

**Total**: 11-12 hours of focused test writing

---

## 🎯 **STARTING NOW**

### **First Target: `universal-patterns/src/lib.rs`**

This is the main library entry point with 0% coverage. Adding tests here will:
1. Validate public API surface
2. Ensure re-exports work correctly
3. Test module integration
4. Quick win for coverage metrics

**Next**: `security/traits.rs` and `security/hardening/manager.rs`

---

**Let's begin!** 🚀

