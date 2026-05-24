# 🔍 BearDog CLI Unwired Systems Audit

## What Works ✅

The demo showed these CLI commands work perfectly:
```bash
✅ beardog entropy collect    # Real entropy from SoftHSM2
✅ beardog key generate        # Real AES-256-GCM keys
✅ beardog encrypt             # Real encryption
✅ beardog decrypt             # Real decryption
✅ beardog hsm discover        # HSM discovery
```

## What Exists But Is NOT Wired to CLI ⚠️

### 1. **Key Derivation** - EXISTS, NOT WIRED
**Location**: `crates/beardog-tunnel/src/tunnel/hsm/software_hsm/core.rs:278-323`

```rust
async fn derive_key_from_root(
    &self,
    root_key_id: &str,
    derivation_data: &[u8],
) -> Result<HsmKey, BearDogError>
```

**Status**: ✅ Fully implemented with HKDF  
**CLI Exposure**: ❌ NO command to call it

**Should Be**:
```bash
beardog key derive \
    --master-key master-123 \
    --purpose "daily-ops" \
    --output daily-key
```

---

### 2. **Key Derivation Functions** - DEFINED, NOT USED
**Location**: `crates/beardog-types/src/canonical/crypto.rs:51-81`

```rust
pub enum KeyDerivationFunction {
    Pbkdf2 { iterations: u32 },
    Argon2 { variant, memory, time },
    Scrypt { n, r, p },
    Hkdf { hash: String },
}
```

**Status**: ✅ Fully defined types  
**CLI Exposure**: ❌ Not used in key generate

**Should Be**:
```bash
beardog key generate \
    --key-id my-key \
    --kdf pbkdf2 \
    --iterations 100000
```

---

### 3. **PBKDF2 Implementation** - EXISTS, NOT WIRED
**Location**: `crates/beardog-security/src/crypto_utils/unified.rs:248-271`

```rust
pub fn derive_key_pbkdf2(
    password: &[u8],
    salt: &[u8],
    iterations: u32,
    key_length: usize,
) -> Result<Vec<u8>, BearDogError>
```

**Status**: ✅ Fully implemented  
**CLI Exposure**: ❌ Not used anywhere

---

### 4. **Key Usage Restrictions** - DEFINED, NOT ENFORCED
**Location**: `crates/beardog-types/src/canonical/crypto.rs:131+`

```rust
pub struct KeyUsage {
    // Permissions and restrictions defined
}
```

**Status**: ✅ Types exist  
**CLI Exposure**: ❌ Can't set restrictions on keys

**Should Be**:
```bash
beardog key generate \
    --key-id limited-key \
    --usage encrypt-only \
    --expires-in 30d
```

---

### 5. **Key Rotation** - CONFIGURED, NOT IMPLEMENTED
**Location**: `crates/beardog-types/src/canonical/crypto.rs:112`

```rust
pub rotation_interval_seconds: Option<u32>,
```

**Status**: ⚠️ Field exists, no rotation logic  
**CLI Exposure**: ❌ No rotation command

**Should Be**:
```bash
beardog key rotate --key-id my-key
```

---

### 6. **Crypto Provider Traits** - DEFINED, PARTIALLY WIRED
**Location**: `crates/beardog-types/src/hsm/crypto.rs:164-190`

```rust
async fn derive_key(
    &self,
    root_key: &[u8],
    derivation_data: &[u8],
) -> Result<Vec<u8>, BearDogError>
```

**Status**: ✅ Trait defined, ⚠️ Default implementation is stub  
**CLI Exposure**: ❌ Not callable

---

## What Demos NEED But Doesn't Exist Anywhere

### 1. **Key Mixing** - NOT IMPLEMENTED
**Needed For**: Household shared keys, multi-party access

```bash
beardog key mix \
    --key-1 person-a-key \
    --key-2 person-b-key \
    --output household-key
```

**Status**: ❌ No implementation  
**Approach**: XOR + KDF or similar cryptographic mixing

---

### 2. **Delegation with Constraints** - NOT IMPLEMENTED
**Needed For**: Tower sharing, limited access

```bash
beardog key delegate \
    --master-key my-tower \
    --delegate-to friend-key \
    --time-range "9AM-5PM" \
    --cpu-quota 50% \
    --expires-in 30d
```

**Status**: ❌ No implementation  
**Approach**: Metadata + constraint checking + derived key

---

### 3. **Multi-Party Renewal** - NOT IMPLEMENTED
**Needed For**: Shared key trust maintenance

```bash
beardog key renew \
    --key-id shared-key \
    --party person-a \
    --party person-b
```

**Status**: ❌ No implementation  
**Approach**: Threshold signatures + consensus protocol

---

### 4. **Key Revocation** - NOT IMPLEMENTED
**Needed For**: Sovereign key management

```bash
beardog key revoke --key-id compromised-key
beardog key check-revocation --key-id some-key
```

**Status**: ❌ No implementation  
**Approach**: Revocation list + Songbird propagation

---

### 5. **Threshold Schemes (k-of-n)** - NOT IMPLEMENTED
**Needed For**: Family/business keys

```bash
beardog key threshold-create \
    --parties 5 \
    --threshold 3 \
    --output family-key
```

**Status**: ❌ No implementation  
**Approach**: Shamir's Secret Sharing or similar

---

### 6. **Key Lineage Tracking** - NOT IMPLEMENTED
**Needed For**: Key hierarchy and genealogy

```bash
beardog key lineage --key-id some-key
# Shows: Gen 0 → Gen 1 → Gen 2 ...
```

**Status**: ❌ No implementation  
**Approach**: Parent references + generation counter

---

## Summary

### Unwired (Code Exists, Not Exposed)
1. ✅ Key derivation (HKDF) - **READY TO WIRE**
2. ✅ PBKDF2 implementation - **READY TO WIRE**
3. ✅ KDF type definitions - **READY TO WIRE**
4. ⚠️ Key usage restrictions - **PARTIALLY READY**
5. ⚠️ Key rotation - **NEEDS IMPLEMENTATION**

### Not Yet Implemented (Design Exists, No Code)
6. ❌ Key mixing - **NEEDS IMPLEMENTATION**
7. ❌ Delegation with constraints - **NEEDS IMPLEMENTATION**
8. ❌ Multi-party renewal - **NEEDS IMPLEMENTATION**
9. ❌ Key revocation - **NEEDS IMPLEMENTATION**
10. ❌ Threshold schemes - **NEEDS IMPLEMENTATION**
11. ❌ Key lineage - **NEEDS IMPLEMENTATION**

---

## Deep Debt Opportunity 🎯

**Priority 1: Wire What Exists (Quick Wins)**
- [ ] Add `beardog key derive` command
- [ ] Add KDF options to `beardog key generate`
- [ ] Add key usage restrictions to `beardog key generate`
- [ ] Test with real demos

**Priority 2: Implement Core Missing Features**
- [ ] Key mixing (XOR + KDF)
- [ ] Delegation keys (metadata + constraints)
- [ ] Key lineage tracking (parent refs + generation)

**Priority 3: Advanced Features**
- [ ] Multi-party renewal (threshold signatures)
- [ ] Revocation (list + Songbird)
- [ ] Threshold schemes (Shamir)

---

## Execution Plan

### Week 1: Wire Existing Systems
```bash
# Day 1-2: Key Derivation
- Add CLI command for derive_key_from_root
- Test with showcase demos
- Generate receipts

# Day 3-4: KDF Options
- Expose PBKDF2/Argon2/HKDF in key generate
- Add --kdf flag with options
- Update demos to use new flags

# Day 5: Key Usage Restrictions
- Add --usage, --expires-in, --purpose flags
- Store metadata with keys
- Validate on use
```

### Week 2: Implement Core Missing Features
```bash
# Day 1-2: Key Mixing
- Implement cryptographic key mixing
- Add CLI command
- Test with household demo

# Day 3-4: Delegation
- Implement delegation key creation
- Add constraint validation
- Test with tower sharing demo

# Day 5: Key Lineage
- Add parent references to keys
- Add generation tracking
- Add lineage query command
```

### Week 3: Polish & Integration
```bash
# Day 1-2: Update All Demos
- Replace OpenSSL fallbacks with BearDog CLI
- Add receipts for all operations
- Test end-to-end

# Day 3-4: Documentation
- Update CLI help
- Update showcase docs
- Add examples

# Day 5: Advanced Features Planning
- Design multi-party renewal protocol
- Design revocation system
- Design threshold schemes
```

---

## Benefits of This Approach

1. **Quick Wins**: Wire existing code first (days, not weeks)
2. **Progressive Enhancement**: Demos improve as we implement
3. **Real Use Cases**: Showcase drives implementation priorities
4. **Deep Debt**: Complete the CLI properly, not just patches
5. **Evolution**: Can evolve with real user feedback

---

*CLI Unwired Systems Audit - December 10, 2025*  
*Identified by: User observation during live testing*  
*Next: Wire existing systems, then implement missing features*
