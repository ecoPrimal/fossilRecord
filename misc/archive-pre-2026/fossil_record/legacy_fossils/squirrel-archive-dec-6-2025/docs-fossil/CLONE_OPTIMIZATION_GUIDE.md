# Clone Optimization Guide

## Overview

The codebase currently has 3,381 `.clone()` calls. While not all clones are problematic, systematic optimization can improve performance, especially in hot paths.

## Strategy

### 1. Identify Clone Patterns

**Good Clones** (Keep):
- Arc/Rc cloning (cheap reference count increment)
- Small Copy types (primitives, small structs with Copy)
- Boundary clones (at API boundaries)
- Error cloning for propagation

**Bad Clones** (Optimize):
- Large String/Vec clones in loops
- Unnecessary clones where references would work
- Double cloning (clone of a clone)
- Clones in hot paths

### 2. Optimization Techniques

#### Use Arc<str> Instead of String
```rust
// Before: Expensive
fn process(name: String) -> String {
    name.clone() // Clones entire string
}

// After: Cheap
use std::sync::Arc;
fn process(name: Arc<str>) -> Arc<str> {
    Arc::clone(&name) // Only clones pointer
}
```

#### Use References Where Possible
```rust
// Before
fn validate(config: Config) -> bool {
    // config is moved
}
let c = config.clone();
validate(c);

// After
fn validate(config: &Config) -> bool {
    // config is borrowed
}
validate(&config);
```

#### Use Cow for Conditional Cloning
```rust
use std::borrow::Cow;

fn maybe_modify(s: &str) -> Cow<str> {
    if needs_modification(s) {
        Cow::Owned(modify(s))
    } else {
        Cow::Borrowed(s)
    }
}
```

### 3. Hot Path Analysis

**Priority Areas** (profile-guided):
1. Request handling loops
2. Message serialization/deserialization
3. State updates
4. Metric collection
5. Logging/tracing

**Tools**:
```bash
# Profile to find hot paths
cargo flamegraph --bin squirrel

# Benchmark before/after
cargo bench --bench clone_performance
```

### 4. Migration Path

**Phase 1**: Identify (This document)
**Phase 2**: Profile (Find actual hot paths)
**Phase 3**: Optimize (Systematic replacement)
**Phase 4**: Validate (Benchmark improvements)

## Current Status

- **Total Clones**: 3,381
- **Analyzed**: ~50 in main/src
- **Zero-Copy Module**: Created (Arc<str> utilities)
- **Priority**: P2 (performance optimization)

## Implementation

See `crates/main/src/zero_copy_strings.rs` for zero-copy utilities.

## Benchmarking

```bash
# Run clone benchmarks (when created)
cargo bench --bench arc_str_performance_suite
```

## Next Steps

1. Profile production workload
2. Identify top 10 hot paths with clones
3. Systematically optimize using techniques above
4. Benchmark each optimization
5. Track improvements in metrics

## References

- Rust Performance Book: https://nnethercote.github.io/perf-book/
- Arc<str> discussion: Rust forums
- Zero-copy patterns: See `zero_copy_strings.rs`

