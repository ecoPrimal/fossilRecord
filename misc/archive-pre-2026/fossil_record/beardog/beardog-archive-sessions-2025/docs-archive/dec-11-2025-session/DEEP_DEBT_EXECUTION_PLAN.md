# 🎯 Deep Debt Execution Plan - BearDog CLI

## Goal
Wire all unwired systems and implement missing features to make demos fully live.
**Principles**: Modern idiomatic Rust, safe AND fast, no unsafe in new code.

---

## Phase 1: Wire Existing Systems (Priority: HIGH)

### 1.1 Add `beardog key derive` Command ⏳ IN PROGRESS

**What**: Expose existing `derive_key_from_root` to CLI

**Location**: 
- Existing impl: `crates/beardog-tunnel/src/tunnel/hsm/software_hsm/core.rs:278-323`
- Add CLI: `crates/beardog-cli/src/main.rs` + handler

**API**:
```bash
beardog key derive \
    --master-key master-123 \
    --purpose "daily-ops" \
    --output daily-ops-key \
    --expires-in 24h
```

**Implementation**:
```rust
// Add to KeyCommands enum
Derive {
    #[arg(long)]
    master_key: String,
    
    #[arg(long)]
    purpose: String,
    
    #[arg(long)]
    output: String,
    
    #[arg(long)]
    expires_in: Option<String>, // "24h", "30d", etc.
}
```

**Handler**: Create `handlers/key_derive.rs`
- Call existing `derive_key_from_root`
- Use purpose as derivation_data
- Store with metadata (parent, generation, expiry)

**Tests**:
- Derive from master key
- Verify derived key is different
- Verify can decrypt with derived key
- Verify lineage tracked

**Time**: 4-6 hours

---

### 1.2 Add KDF Options to `key generate`

**What**: Expose PBKDF2/Argon2/HKDF options

**Location**:
- Existing impl: `crates/beardog-security/src/crypto_utils/unified.rs:248-271`
- Types: `crates/beardog-types/src/canonical/crypto.rs:51-81`
- Modify: `crates/beardog-cli/src/handlers/key.rs`

**API**:
```bash
beardog key generate \
    --key-id my-key \
    --kdf pbkdf2 \
    --kdf-iterations 100000 \
    --seed my-seed.json
```

**Implementation**:
```rust
// Add to Generate command
#[arg(long, default_value = "argon2")]
kdf: String, // "pbkdf2", "argon2", "hkdf"

#[arg(long)]
kdf_iterations: Option<u32>, // For PBKDF2

#[arg(long)]
kdf_memory: Option<u32>, // For Argon2

#[arg(long)]
kdf_time: Option<u32>, // For Argon2
```

**Handler Updates**:
- Parse KDF type
- Call appropriate derivation function
- Store KDF params in key metadata

**Tests**:
- Generate with PBKDF2
- Generate with Argon2
- Verify different KDFs produce different keys
- Verify keys work for encryption

**Time**: 3-4 hours

---

### 1.3 Add Key Usage Restrictions

**What**: Add expiry, purpose, usage restrictions

**Location**:
- Types: `crates/beardog-types/src/canonical/crypto.rs:131+`
- Modify: `crates/beardog-cli/src/handlers/key.rs`

**API**:
```bash
beardog key generate \
    --key-id limited-key \
    --usage encrypt-only \
    --expires-in 30d \
    --purpose "backup-encryption"
```

**Implementation**:
```rust
// Add to Generate command
#[arg(long)]
usage: Option<String>, // "encrypt-only", "decrypt-only", "sign-only", "all"

#[arg(long)]
expires_in: Option<String>, // "24h", "30d", "1y"

#[arg(long)]
purpose: Option<String>, // Freeform description
```

**Handler Updates**:
- Parse expiry duration
- Store usage restrictions in metadata
- Validate on key load (in encrypt/decrypt handlers)

**Validation Logic**:
```rust
// In encrypt handler
fn validate_key_usage(key: &StoredKey, operation: &str) -> Result<(), BearDogError> {
    // Check expiry
    if let Some(expires_at) = key.expires_at {
        if Utc::now() > expires_at {
            return Err(BearDogError::validation("Key has expired"));
        }
    }
    
    // Check usage restrictions
    if let Some(usage) = &key.usage {
        if !usage_allows(usage, operation) {
            return Err(BearDogError::validation("Key usage not permitted"));
        }
    }
    
    Ok(())
}
```

**Tests**:
- Generate key with expiry, verify expires
- Generate encrypt-only key, verify decrypt fails
- Generate with purpose, verify stored

**Time**: 3-4 hours

---

## Phase 2: Implement Core Missing Features (Priority: HIGH)

### 2.1 Implement Key Mixing

**What**: Combine two keys cryptographically

**API**:
```bash
beardog key mix \
    --key-1 person-a-key \
    --key-2 person-b-key \
    --output household-key \
    --threshold 2-of-2
```

**Implementation**:
```rust
// crates/beardog-security/src/key_ops/mixing.rs (NEW)

/// Mix two keys using XOR + KDF
pub fn mix_keys(
    key1: &[u8],
    key2: &[u8],
    salt: &[u8],
) -> Result<Vec<u8>, BearDogError> {
    // XOR the keys
    let xored: Vec<u8> = key1.iter()
        .zip(key2.iter())
        .map(|(a, b)| a ^ b)
        .collect();
    
    // Derive final key with HKDF
    use hkdf::Hkdf;
    use sha2::Sha256;
    
    let hk = Hkdf::<Sha256>::new(Some(salt), &xored);
    let mut okm = vec![0u8; 32];
    hk.expand(b"beardog_key_mixing", &mut okm)
        .map_err(|e| BearDogError::crypto(&format!("HKDF expand failed: {e}")))?;
    
    Ok(okm)
}
```

**Handler**: `handlers/key_mix.rs`
- Load both keys
- Extract key material
- Mix with `mix_keys()`
- Store result with metadata (parents, threshold)

**Tests**:
- Mix two keys
- Verify result is different from both
- Verify deterministic (same keys → same result)
- Verify encrypt/decrypt works with mixed key

**Time**: 5-6 hours

---

### 2.2 Implement Delegation with Constraints

**What**: Create delegated key with time/resource limits

**API**:
```bash
beardog key delegate \
    --master-key my-tower \
    --delegate-to friend-key \
    --time-range "9:00-17:00" \
    --weekdays "mon-fri" \
    --cpu-quota 50 \
    --memory-quota 8GB \
    --expires-in 30d \
    --output friend-delegated
```

**Implementation**:
```rust
// crates/beardog-types/src/delegation.rs (NEW)

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DelegationConstraints {
    /// Time range (HH:MM-HH:MM in local time)
    pub time_range: Option<(String, String)>,
    
    /// Allowed weekdays
    pub weekdays: Option<Vec<String>>,
    
    /// CPU quota (0-100%)
    pub cpu_quota: Option<u8>,
    
    /// Memory quota in bytes
    pub memory_quota: Option<u64>,
    
    /// Expiry timestamp
    pub expires_at: DateTime<Utc>,
    
    /// Delegated to (key ID or identity)
    pub delegated_to: String,
}

impl DelegationConstraints {
    /// Check if constraints are currently satisfied
    pub fn is_satisfied(&self) -> Result<bool, BearDogError> {
        let now = Utc::now();
        
        // Check expiry
        if now > self.expires_at {
            return Ok(false);
        }
        
        // Check time range
        if let Some((start, end)) = &self.time_range {
            let local_time = Local::now().format("%H:%M").to_string();
            if local_time < *start || local_time > *end {
                return Ok(false);
            }
        }
        
        // Check weekday
        if let Some(weekdays) = &self.weekdays {
            let today = Local::now().format("%a").to_string().to_lowercase();
            if !weekdays.contains(&today) {
                return Ok(false);
            }
        }
        
        Ok(true)
    }
}
```

**Handler**: `handlers/key_delegate.rs`
- Load master key
- Derive delegated key (HKDF with delegation context)
- Store with constraints metadata
- Validation checked on every use

**Tests**:
- Create delegated key
- Verify constraints enforced (time, weekday)
- Verify expires after duration
- Verify can use within constraints

**Time**: 6-8 hours

---

### 2.3 Implement Key Lineage Tracking

**What**: Track parent→child relationships and generations

**Implementation**:
```rust
// Update StoredKey in key_store.rs

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StoredKey {
    pub key_id: String,
    pub algorithm: String,
    pub hsm_name: String,
    pub key_material_b64: String,
    pub created_at: DateTime<Utc>,
    
    // NEW: Lineage tracking
    pub generation: u32,           // Gen 0 = root, Gen 1 = derived, etc.
    pub parent_key_id: Option<String>,  // Parent key if derived
    pub derivation_purpose: Option<String>,
    pub children: Vec<String>,     // Child key IDs
}
```

**API**:
```bash
beardog key lineage --key-id some-key

# Output:
# Gen 0: master-key (root)
#   ├─ Gen 1: daily-ops (derived, purpose: daily-ops)
#   │   └─ Gen 2: hourly-temp (derived, purpose: temp)
#   └─ Gen 1: backup-key (derived, purpose: backup)
```

**Handler**: `handlers/key_lineage.rs`
- Load key
- Recursively load parent (if exists)
- Load all children
- Display tree

**Tests**:
- Create master → derived → sub-derived
- Verify lineage query shows tree
- Verify generation numbers correct

**Time**: 4-5 hours

---

## Phase 3: Advanced Features (Priority: MEDIUM)

### 3.1 Implement Revocation System

**What**: Sovereign revocation (no phone home)

**Implementation**:
```rust
// crates/beardog-types/src/revocation.rs (NEW)

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RevocationList {
    pub revoked_keys: HashMap<String, RevocationEntry>,
    pub last_updated: DateTime<Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RevocationEntry {
    pub key_id: String,
    pub revoked_at: DateTime<Utc>,
    pub reason: Option<String>,
}

impl RevocationList {
    /// Check if key is revoked
    pub fn is_revoked(&self, key_id: &str) -> bool {
        self.revoked_keys.contains_key(key_id)
    }
    
    /// Add key to revocation list
    pub fn revoke(&mut self, key_id: String, reason: Option<String>) {
        self.revoked_keys.insert(
            key_id.clone(),
            RevocationEntry {
                key_id,
                revoked_at: Utc::now(),
                reason,
            }
        );
        self.last_updated = Utc::now();
    }
}
```

**API**:
```bash
beardog key revoke --key-id compromised-key --reason "Lost device"
beardog key check-revocation --key-id some-key
```

**Enforcement**:
- Check revocation before any crypto operation
- Refuse to mix with revoked keys
- Propagate via Songbird (future)

**Time**: 5-6 hours

---

### 3.2 Implement Multi-Party Renewal

**What**: Require multiple signatures to renew shared key

**Approach**: Threshold signatures or simpler consensus protocol

**Time**: 8-10 hours (complex, Phase 3)

---

### 3.3 Implement Threshold Schemes (k-of-n)

**What**: Shamir's Secret Sharing for key splitting

**Library**: Use `sharks` crate (Shamir's Secret Sharing in Rust)

**Time**: 8-10 hours (complex, Phase 3)

---

## Implementation Strategy

### Week 1: Phase 1 (Wire Existing)
- **Day 1-2**: `key derive` command (4-6h)
- **Day 3**: KDF options (3-4h)
- **Day 4**: Key restrictions (3-4h)
- **Day 5**: Testing & polish

### Week 2: Phase 2 (Core Missing)
- **Day 1**: Key mixing (5-6h)
- **Day 2-3**: Delegation (6-8h)
- **Day 4**: Key lineage (4-5h)
- **Day 5**: Testing & integration

### Week 3: Phase 3 (Advanced) + Demo Updates
- **Day 1-2**: Revocation system (5-6h)
- **Day 3**: Update all demos to use new CLI
- **Day 4**: Documentation
- **Day 5**: Advanced features planning

---

## Code Quality Standards

### Safety
- ✅ No `unsafe` blocks in new code
- ✅ Use `zeroize` for sensitive data
- ✅ No `unwrap()`/`expect()` in production paths
- ✅ Proper error handling with `BearDogError`

### Performance
- ✅ Use zero-copy where possible
- ✅ Async for I/O operations
- ✅ Efficient data structures (DashMap, etc.)
- ✅ Benchmark critical paths

### Idiomatic Rust
- ✅ Follow Rust API guidelines
- ✅ Use type system for safety
- ✅ Clear ownership and lifetimes
- ✅ Comprehensive documentation

### Testing
- ✅ Unit tests for all new functions
- ✅ Integration tests for CLI commands
- ✅ Test with real demos
- ✅ 90% coverage target

---

## Success Metrics

### Phase 1 Complete When:
- [ ] `beardog key derive` works
- [ ] Can specify KDF in key generate
- [ ] Key restrictions enforced
- [ ] All tests pass
- [ ] Demos can use new features

### Phase 2 Complete When:
- [ ] Can mix two keys
- [ ] Can delegate with constraints
- [ ] Lineage tracking works
- [ ] All tests pass
- [ ] Demos updated

### Phase 3 Complete When:
- [ ] Revocation system works
- [ ] Multi-party renewal implemented
- [ ] Threshold schemes work
- [ ] All demos fully live
- [ ] Documentation complete

---

*Deep Debt Execution Plan - December 10, 2025*  
*Goal: Wire all unwired, implement all missing, evolve CLI to completion*  
*Principles: Safe AND fast, modern idiomatic Rust*
