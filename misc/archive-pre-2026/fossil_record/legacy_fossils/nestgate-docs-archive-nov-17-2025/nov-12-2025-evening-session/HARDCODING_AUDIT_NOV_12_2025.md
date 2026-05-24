# Hardcoding Audit Report
**Date**: November 12, 2025  
**Status**: Initial Audit Complete

---

## Executive Summary

**Total Potential Hardcoding**: ~1,031 occurrences detected
- **Hardcoded Paths**: 370
- **Hardcoded URLs**: 218
- **String Constants**: 206
- **Localhost References**: 145
- **Loopback IPs**: 92

### Assessment Status
🟡 **Needs Further Analysis**: Many of these may be:
1. Test code (acceptable)
2. Const definitions (acceptable)
3. Documentation/examples (acceptable)
4. Actual hardcoding (needs migration)

---

## Hardcoding Categories

### 1. Hardcoded Paths (370 occurrences)
**Pattern**: `"/[a-z/]+"`

**Top Files**:
- nestgate-network/src/smb.rs
- nestgate-network/src/handlers.rs
- Multiple occurrences across network and installer crates

**Risk**: 🟡 Medium
- Many paths should come from config
- Some are valid defaults (e.g., `/tmp`, `/var`)
- Need to identify config-dependent vs system paths

**Examples**:
```rust
// BAD - Should be configurable
let data_dir = "/opt/nestgate/data";

// OK - System path constant
const TMP_DIR: &str = "/tmp";

// BETTER - From config
let data_dir = config.storage.data_directory;
```

### 2. Hardcoded URLs (218 occurrences)
**Pattern**: `"http[s]?://[^"]*"`

**Top Files**:
- nestgate-bin/src/commands/zfs.rs
- nestgate-network/src/api.rs
- nestgate-installer/src/lib.rs

**Risk**: 🔴 High
- URLs should ALWAYS come from config
- Hardcoded URLs prevent deployment flexibility
- Security risk (can't update endpoints without recompile)

**Examples**:
```rust
// BAD - Hardcoded API endpoint
let api_url = "https://api.example.com/v1";

// GOOD - From config
let api_url = config.api.base_url;
```

### 3. Localhost References (145 occurrences)
**Pattern**: `\blocalhost\b`

**Top Files**:
- nestgate-network/src/protocol.rs
- nestgate-canonical/src/error.rs

**Risk**: 🟡 Medium
- Many are likely test code or defaults
- Some may be in error messages (OK)
- Runtime use should be configurable

**Analysis Needed**: Separate test vs production usage

### 4. Loopback IPs (92 occurrences)
**Pattern**: `\b127\.0\.0\.1\b`

**Top Files**:
- nestgate-network/src/types.rs
- nestgate-performance/src/zero_copy_networking.rs

**Risk**: 🟡 Medium
- Often used as defaults (acceptable)
- Should have config override
- Test code usage is fine

### 5. String Constants (206 occurrences)
**Pattern**: `pub const \w+: &str = "`

**Top Files**:
- nestgate-canonical/src/lib.rs
- nestgate-mcp/src/lib.rs

**Risk**: 🟢 Low
- Constants are acceptable and expected
- Good practice for static strings
- No migration needed for most

---

## Acceptable vs Needs Migration

### ✅ Acceptable Hardcoding
1. **Constants for static values**
   ```rust
   pub const VERSION: &str = "0.1.0";
   pub const DEFAULT_TIMEOUT: u64 = 30;
   ```

2. **System paths**
   ```rust
   const PROC_DIR: &str = "/proc";
   const DEV_DIR: &str = "/dev";
   ```

3. **Test code**
   ```rust
   #[test]
   fn test_api() {
       let url = "http://localhost:8080";  // OK in tests
   }
   ```

4. **Error messages and documentation**
   ```rust
   format!("Expected format: https://example.com")
   ```

### ❌ Needs Migration
1. **Runtime configuration**
   ```rust
   // BAD
   let bind_addr = "0.0.0.0:8080";
   
   // GOOD
   let bind_addr = config.server.bind_address;
   ```

2. **Service endpoints**
   ```rust
   // BAD
   let api_url = "https://api.nestgate.com";
   
   // GOOD
   let api_url = config.external.api_base_url;
   ```

3. **Storage paths**
   ```rust
   // BAD
   let data_path = "/var/lib/nestgate";
   
   // GOOD
   let data_path = config.storage.data_directory;
   ```

4. **Network addresses**
   ```rust
   // BAD
   let db_host = "localhost:5432";
   
   // GOOD
   let db_host = config.database.connection_string;
   ```

---

## Detailed Analysis Required

### Phase 1: Separate Test vs Production
**Approach**:
1. Use file path analysis (`_test.rs`, `/tests/`)
2. Check for `#[test]` or `#[cfg(test)]` context
3. Classify each occurrence

**Estimated Breakdown**:
- Production: ~400 (40%)
- Test: ~600 (60%)
- Documentation/Examples: ~31 (3%)

### Phase 2: Classify Production Occurrences
**Categories**:
1. **Constants (OK)**: ~150 (37.5%)
2. **Defaults with override (OK)**: ~100 (25%)
3. **Needs config migration**: ~150 (37.5%)

**True Migration Needed**: ~150 occurrences

---

## Migration Strategy

### Phase 1: High Priority (Week 1)
**Target**: Hardcoded URLs and Service Endpoints (218 URLs)
- Identify production vs test
- Create config entries for each
- Migrate top 20 files
- Estimated production URLs: ~80

**Impact**: Critical for deployment flexibility

### Phase 2: Medium Priority (Week 2)
**Target**: Hardcoded Paths (370 paths)
- Separate system paths (keep) from data paths (migrate)
- Create storage config section
- Migrate configurable paths
- Estimated migration: ~50 paths

**Impact**: Important for multi-environment deployment

### Phase 3: Low Priority (Week 3)
**Target**: Localhost/Loopback (237 references)
- Identify runtime usage vs tests
- Ensure config overrides exist
- Document default behaviors
- Estimated migration: ~20 occurrences

**Impact**: Nice to have for flexibility

---

## Configuration System Review

### Current State ✅
NestGate has an **excellent configuration system**:
- Centralized config management
- Environment variable override
- Type-safe config structs
- Zero production hardcoding in config system itself

### Configuration Structure
```rust
pub struct CanonicalConfig {
    pub server: ServerConfig,     // bind_address, port, etc.
    pub storage: StorageConfig,   // data_dir, cache_dir, etc.
    pub network: NetworkConfig,   // timeouts, retries, etc.
    pub security: SecurityConfig, // certs, keys, etc.
    pub external: ExternalConfig, // API URLs, endpoints, etc.
}
```

### Gaps to Fill
1. **External API endpoints**: Add to `external` section
2. **Service URLs**: Add to `network` section
3. **Storage paths**: Enhance `storage` section
4. **Database connections**: Add `database` section if needed

---

## Recommendations

### Immediate Actions
1. ✅ **DONE**: Initial audit completed
2. **TODO**: Detailed production vs test separation
3. **TODO**: Identify top 20 files for migration

### Short-term (1-2 weeks)
1. Migrate hardcoded URLs (~80 production URLs)
2. Migrate configurable paths (~50 paths)
3. Update config documentation

### Medium-term (2-4 weeks)
1. Add CI check for new hardcoding
2. Document configuration best practices
3. Complete remaining migrations

---

## Tooling

### Detection Script
```bash
# Find hardcoded URLs in production code
grep -r --include='*.rs' -E '"http[s]?://[^"]*"' code/crates \
  --exclude='*test*' | wc -l

# Find hardcoded paths
grep -r --include='*.rs' -E '"/[a-z/]+"' code/crates \
  --exclude='*test*' | wc -l

# Find localhost references
grep -r --include='*.rs' -E '\blocalhost\b' code/crates \
  --exclude='*test*' | wc -l
```

### CI Integration (TODO)
```yaml
- name: Check for hardcoded URLs
  run: |
    URLS=$(grep -r '"http[s]?://' src --exclude='*test*' | wc -l)
    if [ "$URLS" -gt 80 ]; then
      echo "WARNING: Found $URLS hardcoded URLs (target: <80)"
    fi
```

---

## Estimated Effort

### Phase 1: URL Migration (Week 1)
- Audit: 1 day
- Config updates: 1 day
- Code migration: 2 days
- Testing: 1 day
- **Total**: 5 days

### Phase 2: Path Migration (Week 2)
- Audit: 1 day
- Config updates: 1 day
- Code migration: 2 days
- Testing: 1 day
- **Total**: 5 days

### Phase 3: Localhost Migration (Week 3)
- Audit: 0.5 days
- Config updates: 0.5 days
- Code migration: 1 day
- Testing: 0.5 days
- **Total**: 2.5 days

**Total Estimated Time**: 12.5 days (~2.5 weeks)

---

## Success Criteria

### Before Merging
1. ✅ All hardcoded URLs moved to config
2. ✅ All configurable paths moved to config
3. ✅ Config documentation updated
4. ✅ Tests passing
5. ✅ No new hardcoding in diff

### Final Goals
- **Production hardcoded URLs**: 218 → 0
- **Production hardcoded paths**: 370 → ~320 (50 migrated, rest are system paths)
- **Configuration coverage**: 100% of deployable values
- **CI enforcement**: Prevent new hardcoding

---

## Conclusion

**Current State**:
- ~1,031 potential hardcoding occurrences detected
- Most are likely acceptable (tests, constants, system paths)
- Estimated ~150 need migration (URLs, paths, endpoints)

**Action Plan**:
- Detailed audit to separate acceptable vs needs-migration
- Priority on URLs (deployment critical)
- 2.5 weeks to complete all migrations

**Expected Outcome**:
- Zero hardcoded deployment values
- Full configuration flexibility
- CI enforcement of standards
- +2 points to overall grade (A- → A territory)

---

**Next Step**: Detailed audit of top 20 files with most hardcoding

