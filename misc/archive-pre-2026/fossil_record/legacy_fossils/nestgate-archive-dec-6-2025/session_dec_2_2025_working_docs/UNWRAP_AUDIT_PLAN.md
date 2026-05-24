# Production unwrap/expect Audit Plan

**Created**: December 2, 2025  
**Status**: PLANNING PHASE  
**Priority**: HIGH (Week 2)

---

## 🎯 OBJECTIVE

Identify and migrate all production (non-test) `.unwrap()` and `.expect()` calls to proper `Result<T, E>` error handling.

---

## 📊 PRELIMINARY ANALYSIS

### Total Counts
- **Total unwrap/expect**: 3,285 calls across 466 files
- **Production estimate**: ~600-800 calls (18-24% of total)
- **Test code**: ~2,485-2,685 calls (appropriate)

### Sample Production Files with unwrap/expect
From preliminary scan (needs full audit):

1. **nestgate-api**:
   - `routes/storage/filesystem.rs`: TempDir creation
   - `handlers/performance_analyzer/analyzer.rs`: Serialization
   - `handlers/performance_analyzer/collectors.rs`: Metrics collection

2. **nestgate-core**:
   - `config/runtime.rs`: Configuration parsing
   - `network/client.rs`: Network operations
   - `utils/network.rs`: Network utilities
   - `performance/adaptive_caching.rs`: Cache operations

3. **nestgate-zfs**:
   - Production files (need detailed scan)

---

## 🔍 AUDIT METHODOLOGY

### Phase 1: Identification (Day 2-3)
```bash
# Find all production unwrap/expect (exclude tests)
grep -r "\.unwrap()\|\.expect(" code/crates/*/src/ \
  --include="*.rs" \
  | grep -v "_tests\|/tests/\|test_\|#\[cfg(test)\]" \
  > production_unwrap_expect.txt

# Categorize by severity
# - Critical: User-facing code paths
# - High: Core functionality
# - Medium: Background operations
# - Low: Startup/initialization
```

### Phase 2: Categorization (Day 3-4)
1. **Critical**: User request handlers, API endpoints
2. **High**: Core business logic, data operations
3. **Medium**: Background tasks, caching
4. **Low**: Configuration loading, startup

### Phase 3: Migration (Week 2)
Priority order:
1. Critical paths (Week 2, Days 1-2)
2. High severity (Week 2, Days 3-4)
3. Medium severity (Week 2, Day 5)
4. Low severity (Week 3, as needed)

---

## 🔧 MIGRATION PATTERNS

### Pattern 1: Configuration Loading
```rust
// ❌ BEFORE
let config = env::var("KEY").expect("Config missing");

// ✅ AFTER
let config = env::var("KEY")
    .map_err(|_| NestGateError::ConfigMissing("KEY"))?;
```

### Pattern 2: Serialization
```rust
// ❌ BEFORE
let json = serde_json::to_string(&data).expect("Serialization failed");

// ✅ AFTER
let json = serde_json::to_string(&data)
    .map_err(|e| NestGateError::SerializationError(e.to_string()))?;
```

### Pattern 3: Network Operations
```rust
// ❌ BEFORE  
let addr = "127.0.0.1:8080".parse().unwrap();

// ✅ AFTER
let addr = "127.0.0.1:8080"
    .parse()
    .map_err(|e| NestGateError::InvalidAddress(e.to_string()))?;
```

### Pattern 4: File Operations
```rust
// ❌ BEFORE
let temp_dir = TempDir::new().expect("Failed to create temp dir");

// ✅ AFTER
let temp_dir = TempDir::new()
    .map_err(|e| NestGateError::IoError(format!("Temp dir: {}", e)))?;
```

---

## 📋 ESTIMATED TIMELINE

### Week 2 Focus
- Days 1-2: Identify and categorize all (~600-800 instances)
- Days 3-5: Migrate critical and high severity (~400-500 instances)

### Week 3 Continuation
- Days 1-2: Migrate remaining medium/low severity (~200-300 instances)
- Day 3: Verification and testing

---

## ✅ SUCCESS CRITERIA

- [ ] All production unwrap/expect identified
- [ ] Categorized by severity
- [ ] Critical paths migrated (100%)
- [ ] High severity migrated (100%)
- [ ] Medium severity migrated (80%+)
- [ ] Low severity migrated or documented
- [ ] All tests passing
- [ ] No regressions introduced

---

## 🎯 NEXT STEPS

### Immediate (Week 2, Day 1)
1. Complete full scan of production code
2. Create categorized list
3. Start migrating critical paths

### This Task (Week 2)
- Complete identification
- Migrate critical/high severity
- Maintain test pass rate

---

**Status**: PLANNED  
**Start**: Week 2, Day 1  
**Completion**: Week 2-3  
**Priority**: HIGH


