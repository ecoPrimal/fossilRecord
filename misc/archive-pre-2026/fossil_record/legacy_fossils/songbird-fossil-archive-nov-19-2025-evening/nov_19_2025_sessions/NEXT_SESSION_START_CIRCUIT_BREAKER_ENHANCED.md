# Next Session: circuit_breaker_enhanced_tests.rs

**File**: `crates/songbird-universal/tests/circuit_breaker_enhanced_tests.rs`  
**Current Status**: Has compilation errors (same as edge_cases before fix)  
**Sleeps to Convert**: 11 instances

---

## Quick Start Command

```bash
cd /home/eastgate/Development/ecoPrimals/songbird

# Check current errors
cargo test --package songbird-universal --test circuit_breaker_enhanced_tests 2>&1 | grep "error\[" | wc -l

# After fixes, run tests
cargo test --package songbird-universal --test circuit_breaker_enhanced_tests
```

---

## Step 1: Bulk API Conversion (Same as edge_cases)

Apply these bulk replacements to convert async API to sync:

```bash
# These commands work on Linux/Mac
cd crates/songbird-universal/tests/

# Replace all .await calls on sync methods
sed -i 's/\.get_state()\.await/.get_state()/g' circuit_breaker_enhanced_tests.rs
sed -i 's/\.record_failure()\.await/.record_failure()/g' circuit_breaker_enhanced_tests.rs
sed -i 's/\.record_success()\.await/.record_success()/g' circuit_breaker_enhanced_tests.rs
sed -i 's/\.is_request_allowed()\.await/.is_request_allowed()/g' circuit_breaker_enhanced_tests.rs
```

Or use the `search_replace` tool with `replace_all: true` as done in edge_cases.

---

## Step 2: Convert Sleep Calls to Event-Driven Patterns

### Sleep Locations (11 instances)
1. Line 62: `tokio::time::sleep(Duration::from_millis(150)).await;`
2. Line 83: `tokio::time::sleep(Duration::from_millis(100)).await;`
3. Line 109: `tokio::time::sleep(Duration::from_millis(100)).await;`
4. Line 192: `tokio::time::sleep(Duration::from_millis(100)).await;`
5. Line 228: `tokio::time::sleep(Duration::from_millis(250)).await;`
6. Line 249: `tokio::time::sleep(Duration::from_millis(10)).await;`
7. Line 296: `tokio::time::sleep(Duration::from_millis(100)).await;`
8. Line 334: `tokio::time::sleep(Duration::from_millis(100)).await;`
9. Line 393: `tokio::time::sleep(Duration::from_millis(100)).await;`
10. Line 478: `tokio::time::sleep(Duration::from_millis(20)).await;` (in loop)
11. Line 511: `tokio::time::sleep(Duration::from_millis(150)).await;`

### Conversion Pattern for Each

**Pattern A: Timeout-based tests** (Lines 62, 83, 109, 192, 228, 296, 334, 393, 511)

Before:
```rust
#[tokio::test]
async fn test_transition_open_to_half_open() {
    let cb = CircuitBreaker::with_config(config);
    
    // Open the circuit
    cb.record_failure();
    assert_eq!(cb.get_state(), CircuitState::Open);
    
    // Wait for timeout
    tokio::time::sleep(Duration::from_millis(150)).await;
    
    // Next request check should transition to half-open
    assert!(cb.is_request_allowed());
    assert_eq!(cb.get_state(), CircuitState::HalfOpen);
}
```

After:
```rust
#[tokio::test(start_paused = true)]
async fn test_transition_open_to_half_open() {
    let cb = CircuitBreaker::with_config(config);
    let mut state_rx = cb.subscribe_state_changes();
    
    // Open the circuit
    cb.record_failure();
    
    // Wait for state change event (deterministic!)
    let new_state = state_rx.recv().await.unwrap();
    assert_eq!(new_state, CircuitState::Open);
    
    // Advance time deterministically
    tokio::time::advance(Duration::from_millis(150)).await;
    
    // Next request check should transition to half-open
    assert!(cb.is_request_allowed());
    assert_eq!(cb.get_state(), CircuitState::HalfOpen);
}
```

**Pattern B: State transition tests** (Lines 249, 478)

Before:
```rust
tokio::time::sleep(Duration::from_millis(10)).await;
assert_eq!(cb.get_state(), CircuitState::HalfOpen);
```

After:
```rust
let mut state_rx = cb.subscribe_state_changes();
// ... record failures/successes ...
let new_state = state_rx.recv().await.unwrap();
assert_eq!(new_state, CircuitState::HalfOpen);
```

---

## Step 3: Test and Iterate

After each batch of conversions:

```bash
cargo test --package songbird-universal --test circuit_breaker_enhanced_tests 2>&1 | tail -20
```

Look for:
- Compilation errors (continue fixing `.await` issues)
- Test failures (adjust event-driven logic)
- Success!

---

## Reference Files

1. **`circuit_breaker_edge_cases_tests.rs`** - Successfully converted (use as template)
2. **`security_concurrent_tests.rs`** - Event-driven patterns
3. **`circuit_breaker.rs`** - Lock-free API (reference for methods)

---

## Expected Outcome

- **Before**: ~80+ compilation errors, 11 sleeps
- **After**: 0 errors, 0 sleeps, all tests passing

---

## Estimated Time

- **API Conversion**: 15-20 minutes (bulk replacements)
- **Sleep Conversion**: 1.5-2 hours (11 sleeps, event-driven patterns)
- **Testing & Fixes**: 30 minutes
- **Total**: **2-3 hours**

---

## Next File After This

`circuit_breaker_async_integration_tests.rs` (10 sleeps)

---

**Status**: Ready to start immediately!  
**Tools needed**: search_replace, read_file, run_terminal_cmd

