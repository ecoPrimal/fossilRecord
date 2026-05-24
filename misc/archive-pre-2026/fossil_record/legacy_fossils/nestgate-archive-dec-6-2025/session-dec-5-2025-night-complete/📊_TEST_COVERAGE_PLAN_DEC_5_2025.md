# 📊 TEST COVERAGE EXPANSION PLAN

**Date**: December 5, 2025 (Evening)  
**Status**: 🔄 **IN PROGRESS**  
**Goal**: Expand from 72% → 90% coverage (add 300+ tests)  
**Current**: 1,243 tests passing in nestgate-core

---

## 🎯 STRATEGY

### Phase 1: Temporal Storage (THIS SESSION)
**Target**: 30-50 new tests  
**Focus**: Newly refactored modules (high value)

**Priority Areas**:
1. ✅ device.rs - Edge cases, error paths
2. ✅ connection.rs - Connection failures, retries
3. ✅ data_types.rs - Type validation, parsing
4. ✅ access_control.rs - Authentication edge cases
5. ✅ ingestion.rs - Validation failures
6. ✅ classification.rs - Strategy selection
7. ✅ sources.rs - Stream handling
8. ✅ system.rs - System orchestration

### Phase 2: Capability Discovery (NEXT SESSION)
**Target**: 40-60 new tests  
**Focus**: Error paths, edge cases, concurrency

### Phase 3: Error Handling (WEEK 2)
**Target**: 50-70 new tests  
**Focus**: All error variants, recovery paths

---

## 📊 CURRENT COVERAGE ANALYSIS

### temporal_storage Module

**Current Tests** (in mod.rs):
- ✅ Basic device creation
- ✅ Storage era classification
- ✅ System add/remove devices
- ✅ Basic classification
- ✅ Basic access control

**Missing Coverage**:
- ❌ Error paths (device detection failures)
- ❌ Edge cases (zero capacity, invalid dimensions)
- ❌ Concurrent access patterns
- ❌ Performance tier comparisons
- ❌ Connection retry logic
- ❌ Authentication failures
- ❌ Rate limit enforcement
- ❌ Data validation errors
- ❌ Classification strategy selection
- ❌ Stream interruption handling

**Estimated Gap**: ~40-50 tests

---

## 🎯 TEST CATEGORIES TO ADD

### 1. Edge Cases (High Priority)
**Examples**:
- Zero/negative capacity
- Empty/invalid formats
- Null/missing metadata
- Boundary values
- Invalid enums

**Target**: 15-20 tests

---

### 2. Error Paths (High Priority)
**Examples**:
- Connection failures
- Authentication errors
- Rate limit exceeded
- Validation failures
- Network timeouts
- Resource exhaustion

**Target**: 15-20 tests

---

### 3. Integration Scenarios (Medium Priority)
**Examples**:
- Multi-device systems
- Cross-era compatibility
- Data migration flows
- Concurrent operations
- Transaction semantics

**Target**: 10-15 tests

---

### 4. Performance/Stress (Medium Priority)
**Examples**:
- Large datasets
- Many devices
- High concurrency
- Memory pressure
- Long-running operations

**Target**: 5-10 tests

---

## 🚀 EXECUTION PLAN

### This Session (2-3 hours)

**Hour 1**: temporal_storage Edge Cases (15-20 tests)
- Device edge cases (5 tests)
- Data type validation (5 tests)
- Access control edge cases (5 tests)
- Classification edge cases (5 tests)

**Hour 2**: temporal_storage Error Paths (15-20 tests)
- Connection errors (5 tests)
- Ingestion errors (5 tests)
- Authentication errors (3 tests)
- Rate limiting (3 tests)
- System errors (4 tests)

**Hour 3**: Integration & Verification (5-10 tests)
- Multi-device scenarios (3 tests)
- End-to-end flows (3 tests)
- Verify all tests pass
- Update coverage metrics

**Total This Session**: 35-50 new tests

---

## 📋 TEST TEMPLATES

### Edge Case Test Template
```rust
#[test]
fn test_device_zero_capacity() {
    let device = TemporalDevice {
        capacity_mb: 0,  // Edge case
        ..default_device()
    };
    
    // Should handle gracefully or return error
    assert!(device.is_valid().is_err());
}
```

### Error Path Test Template
```rust
#[tokio::test]
async fn test_connection_timeout() {
    let source = UniversalDataSource::unreachable();
    let result = source.connect().await;
    
    assert!(result.is_err());
    assert!(matches!(result.unwrap_err(), Error::Timeout(_)));
}
```

### Integration Test Template
```rust
#[tokio::test]
async fn test_multi_device_discovery() {
    let mut system = TemporalStorageSystem::new();
    
    // Add devices from different eras
    system.add_device(modern_nvme());
    system.add_device(digital_ssd());
    system.add_device(magnetic_tape());
    
    assert_eq!(system.device_count(), 3);
    assert!(system.total_capacity_mb() > 0);
    
    // Test cross-era queries
    let modern_devices = system.devices_by_era(StorageEra::Modern);
    assert_eq!(modern_devices.len(), 1);
}
```

---

## ✅ SUCCESS CRITERIA

### Quantitative
- ✅ 35-50 new tests added
- ✅ All tests passing
- ✅ Coverage increase measured
- ✅ Zero regressions

### Qualitative
- ✅ Edge cases covered
- ✅ Error paths tested
- ✅ Integration scenarios validated
- ✅ Clear test names and assertions

---

## 📊 TRACKING

### Phase 1 Progress (temporal_storage)
- [ ] device.rs edge cases (0/5)
- [ ] data_types.rs validation (0/5)
- [ ] access_control.rs auth (0/5)
- [ ] classification.rs strategies (0/5)
- [ ] connection.rs errors (0/5)
- [ ] ingestion.rs validation (0/5)
- [ ] system.rs orchestration (0/5)
- [ ] Integration tests (0/5)

**Total**: 0/40 tests added

---

## 🎯 IMMEDIATE NEXT STEPS

1. **Start with device.rs edge cases** (5 tests)
   - Zero capacity
   - Invalid dimensions
   - Empty formats list
   - Unknown technology
   - Metadata edge cases

2. **Add data validation tests** (5 tests)
   - Invalid data types
   - Missing required fields
   - Type conversions
   - Parsing errors
   - Boundary values

3. **Test authentication flows** (5 tests)
   - Failed authentication
   - Token expiration
   - Invalid credentials
   - Multiple auth methods
   - Permission denied

---

**Status**: ✅ Plan complete, ready to add tests  
**Target**: 35-50 tests this session  
**Goal**: Boost coverage 72% → 75-80%

