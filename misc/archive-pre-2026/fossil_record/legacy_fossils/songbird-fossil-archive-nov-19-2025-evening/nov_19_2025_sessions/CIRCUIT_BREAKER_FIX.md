# Circuit Breaker Time Handling Fix

## Problem
The test `test_circuit_half_open_after_timeout` fails because:
1. Test uses `tokio::time::pause()` and `tokio::time::advance()`
2. Circuit breaker uses `SystemTime::now()` which doesn't respect paused time
3. Need to use `tokio::time::Instant` for testable time

## Solution
Replace time tracking with `tokio::time::Instant` which works with `tokio::time::pause()`

## Changes Needed

### 1. Update Struct
```rust
pub struct CircuitBreaker {
    // ... other fields ...
    /// Last failure time (Option<Instant>)
    last_failure_instant: Arc<parking_lot::Mutex<Option<tokio::time::Instant>>>,
}
```

### 2. Update is_request_allowed()
```rust
pub fn is_request_allowed(&self) -> bool {
    match state {
        CircuitState::Open => {
            if let Some(last_failure) = *self.last_failure_instant.lock() {
                if last_failure.elapsed() >= self.config.timeout {
                    self.try_transition_to_half_open();
                    return true;
                }
            }
            false
        }
        _ => true,
    }
}
```

### 3. Update try_transition_to_open()
```rust
fn try_transition_to_open(&self) {
    if result.is_ok() {
        *self.last_failure_instant.lock() = Some(tokio::time::Instant::now());
        // ...
    }
}
```

### 4. Update record_failure() in Open state
```rust
CircuitState::Open => {
    *self.last_failure_instant.lock() = Some(tokio::time::Instant::now());
}
```

## Why This Works
- `tokio::time::Instant::now()` returns an `Instant` that respects tokio's time control
- `tokio::time::pause()` pauses this clock
- `tokio::time::advance()` moves it forward
- `Instant::elapsed()` correctly calculates based on paused time
- Tests become **deterministic** and **instant**!

