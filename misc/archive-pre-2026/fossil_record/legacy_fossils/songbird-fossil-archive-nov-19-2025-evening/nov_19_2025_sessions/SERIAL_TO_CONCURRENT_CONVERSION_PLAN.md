# Serial to Concurrent Test Conversion Plan

**Created**: November 19, 2025  
**Status**: ⏳ In Progress  
**Estimated Time**: 8-10 hours

---

## Overview

Found **51 `sleep()` instances** across **14 files** that indicate serial test patterns.

These tests need conversion to:
- Use event-driven state notifications (`subscribe_state_changes()`)
- Use deterministic time testing (`tokio::time::pause()`, `tokio::time::advance()`)
- Use proper sync primitives (`Barrier`, `Semaphore`, channels)
- Eliminate non-deterministic `sleep()` calls

---

## Files Requiring Conversion

### Priority 1: Circuit Breaker Tests (37 sleeps)
These tests are using the OLD async API and need updating for the new lock-free API:

1. **`circuit_breaker_edge_cases_tests.rs`** - 14 sleeps
   - Status: Needs updating for sync `get_state()` API
   - Lines: Multiple tests calling `.await` on `get_state()`
   - Pattern: Replace `cb.get_state().await` with `cb.get_state()`
   - Pattern: Replace `sleep` with event-driven `state_rx.recv().await`

2. **`circuit_breaker_enhanced_tests.rs`** - 11 sleeps
   - Status: Needs event-driven conversion
   - Pattern: Use `subscribe_state_changes()` for state transitions
   - Pattern: Use `tokio::time::pause()` for deterministic timeouts

3. **`circuit_breaker_async_integration_tests.rs`** - 10 sleeps
   - Status: Needs deterministic time testing
   - Pattern: Replace sleeps with `tokio::time::advance()`
   - Pattern: Add `#[tokio::test(start_paused = true)]`

4. **`circuit_breaker_correct_api_tests.rs`** - 2 sleeps
   - Status: Minor fixes needed
   - Pattern: Update for new sync API

### Priority 2: Adapter Integration Tests (4 sleeps)
These tests can benefit from concurrent patterns:

5. **`compute_adapter_async_integration_tests.rs`** - 1 sleep
   - Status: Needs concurrent request handling
   - Pattern: Use barriers for simultaneous requests

6. **`security_adapter_async_integration_tests.rs`** - 1 sleep
   - Status: Can use concurrent patterns from `security_concurrent_tests.rs`

7. **`storage_adapter_async_integration_tests.rs`** - 1 sleep
   - Pattern: Similar to security adapter patterns

8. **`ai_adapter_async_integration_tests.rs`** - 1 sleep
   - Pattern: Similar to security adapter patterns

### Priority 3: Other Tests (10 sleeps)
9. **`federation_aware_discovery_tests.rs`** - 2 sleeps
10. **`error_handling_comprehensive_tests.rs`** - 1 sleep
11. **`capability_registry_advanced_tests.rs`** - 1 sleep (uses `std::thread::sleep`)
12. **`integration_workflow_tests.rs`** - 1 sleep

### Non-Test Code (5 sleeps)
13. **`unified_agnostic_discovery.rs`** - 4 sleeps
14. **`network_effects_decoupling.rs`** - 1 sleep

---

## Conversion Patterns

### Pattern 1: Event-Driven State Changes
**Before** (serial with sleep):
```rust
cb.record_failure();
tokio::time::sleep(Duration::from_millis(100)).await;
assert_eq!(cb.get_state().await, CircuitState::Open);
```

**After** (event-driven):
```rust
let mut state_rx = cb.subscribe_state_changes();
cb.record_failure();
let new_state = state_rx.recv().await.unwrap();
assert_eq!(new_state, CircuitState::Open);
```

### Pattern 2: Deterministic Time Testing
**Before** (non-deterministic):
```rust
#[tokio::test]
async fn test_timeout() {
    cb.record_failure();
    tokio::time::sleep(Duration::from_millis(150)).await;
    assert!(cb.is_request_allowed());
}
```

**After** (deterministic):
```rust
#[tokio::test(start_paused = true)]
async fn test_timeout() {
    cb.record_failure();
    tokio::time::advance(Duration::from_millis(150)).await;
    assert!(cb.is_request_allowed());
}
```

### Pattern 3: Synchronous API Updates
**Before** (old async API):
```rust
assert_eq!(cb.get_state().await, CircuitState::Closed);
cb.record_failure().await;
```

**After** (new sync API):
```rust
assert_eq!(cb.get_state(), CircuitState::Closed);
cb.record_failure();
```

### Pattern 4: Concurrent Request Testing
**Before** (serial):
```rust
for i in 0..10 {
    adapter.collect_metrics().await;
    tokio::time::sleep(Duration::from_millis(50)).await;
}
```

**After** (concurrent):
```rust
let handles: Vec<_> = (0..10)
    .map(|_| {
        let adapter = Arc::clone(&adapter);
        tokio::spawn(async move { adapter.collect_metrics().await })
    })
    .collect();
let results = futures::future::join_all(handles).await;
```

---

## Conversion Checklist

### Phase 1: Circuit Breaker Tests (4-5 hours)
- [ ] **circuit_breaker_edge_cases_tests.rs** (105 errors to fix)
  - [ ] Update all `get_state().await` to `get_state()` (sync)
  - [ ] Update all `record_failure().await` to `record_failure()` (sync)
  - [ ] Replace sleeps with event-driven patterns
  - [ ] Add `#[tokio::test(start_paused = true)]` where appropriate

- [ ] **circuit_breaker_enhanced_tests.rs**
  - [ ] Convert 11 sleep calls to event-driven
  - [ ] Use `subscribe_state_changes()`
  - [ ] Add deterministic time testing

- [ ] **circuit_breaker_async_integration_tests.rs**
  - [ ] Convert 10 sleep calls
  - [ ] Add `tokio::time::pause()` testing
  - [ ] Use `tokio::time::advance()`

- [ ] **circuit_breaker_correct_api_tests.rs**
  - [ ] Update for sync API
  - [ ] Remove 2 sleep calls

### Phase 2: Adapter Tests (2-3 hours)
- [ ] **compute_adapter_async_integration_tests.rs**
  - [ ] Apply concurrent patterns from `security_concurrent_tests.rs`
  - [ ] Use barriers for simultaneous requests

- [ ] **security_adapter_async_integration_tests.rs**
  - [ ] Update to use concurrent patterns

- [ ] **storage_adapter_async_integration_tests.rs**
  - [ ] Apply concurrent patterns

- [ ] **ai_adapter_async_integration_tests.rs**
  - [ ] Apply concurrent patterns

### Phase 3: Other Tests (1-2 hours)
- [ ] **federation_aware_discovery_tests.rs**
- [ ] **error_handling_comprehensive_tests.rs**
- [ ] **capability_registry_advanced_tests.rs**
- [ ] **integration_workflow_tests.rs**

### Phase 4: Production Code (1 hour)
- [ ] **unified_agnostic_discovery.rs** (4 sleeps in production!)
  - Critical: These are in production code, not tests
  - Need careful review for appropriate async patterns
- [ ] **network_effects_decoupling.rs** (1 sleep)

---

## Estimated Impact

### Test Reliability
- **Before**: Non-deterministic, can flake under load
- **After**: Deterministic, reliable regardless of system load

### Test Performance
- **Before**: ~3.5 seconds wasted on sleeps per test run
- **After**: Instant with `tokio::time::pause()`

### Test Coverage Quality
- **Before**: Serial tests may miss race conditions
- **After**: Concurrent tests expose race conditions

---

## Reference Implementation

See `security_concurrent_tests.rs` for examples of all patterns:
- ✅ Event-driven state changes
- ✅ Deterministic time testing
- ✅ Concurrent request handling
- ✅ Proper synchronization primitives
- ✅ Load testing patterns
- ✅ Stress testing patterns

---

## Next Steps

1. **Start with circuit_breaker_edge_cases_tests.rs** (105 compilation errors)
   - This file has the most errors and needs API updates
   - Will validate the new sync API thoroughly

2. **Convert remaining circuit breaker tests**
   - Apply event-driven patterns
   - Add deterministic time testing

3. **Expand to adapter tests**
   - Reuse security adapter concurrent patterns
   - Achieve consistent test quality across all adapters

4. **Review production code sleeps**
   - Critical: 5 sleeps in production code
   - Ensure these are intentional waits, not test artifacts

---

## Success Criteria

✅ Zero `sleep()` calls in test code  
✅ All tests use event-driven or deterministic patterns  
✅ Test reliability improved (no flakes)  
✅ Test performance improved (faster execution)  
✅ Concurrent test coverage expanded  

---

**Status**: Plan complete, execution pending
**Next Session**: Fix circuit_breaker_edge_cases_tests.rs compilation errors

