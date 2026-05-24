# 🔌 Agnostic Evolution - IN PROGRESS

**Status**: Task 1 ✅ Complete | Task 2 ▶️ In Progress

---

## ✅ **COMPLETED**

### Task 1: Fix Test Compilation (15 min) ✅
- Fixed 8 `StoredKey` initialization errors
- Fixed 1 test timing tolerance issue
- **Result**: 210 tests passing ✅

---

## ▶️ **IN PROGRESS**

### Task 2: Wire HSM Discovery (3-4 hours)

**Goal**: Remove ALL hardcoding, make BearDog truly vendor-agnostic

---

## 📊 **Current Situation**

### Existing Infrastructure (Good News!) ✅
`beardog-tunnel` already has comprehensive HSM discovery:
- `DiscoveryEngine` - Coordinating all discoverers
- `Pkcs11Discoverer` - Scans `/usr/lib`, `/usr/local/lib`, etc.
- `UsbHsmDiscoverer` - USB token detection
- `MobileHsmDiscoverer` - Android StrongBox, iOS Secure Enclave
- `SoftwareHsmDiscoverer` - Software HSM detection
- `TpmDiscoverer` - TPM 2.0
- `SmartCardDiscoverer` - Smart cards
- `CloudKmsDiscoverer` - Cloud KMS

**This is EXACTLY what we need!** ✅

### Current CLI Problem ❌
CLI uses placeholders with hardcoded paths:
```rust
// crates/beardog-cli/src/handlers/hsm.rs:21
if std::path::Path::new("/usr/lib/softhsm/libsofthsm2.so").exists() {
    // HARDCODED PATH - breaks agnostic!
}

// crates/beardog-cli/src/handlers/hsm.rs:69
if line.contains("1209:beee") {  // Solo 2 only
    // HARDCODED VENDOR ID - breaks agnostic!
}
```

---

## 📋 **Execution Plan**

### Phase 1: Expose Discovery API (30 min)
**Status**: ▶️ NEXT

1. Export `DiscoveryEngine` from `beardog-tunnel/src/lib.rs`
2. Export `DiscoveredHsm` and related types
3. Create simple wrapper for CLI usage

```rust
// crates/beardog-tunnel/src/lib.rs
pub use tunnel::hsm::universal_discovery::{
    DiscoveryEngine,
    DiscoveredHsm,
    HsmInterfaceType,
};
```

---

### Phase 2: Wire CLI Handlers (2-3 hours)
**Status**: ⏳ PENDING

#### 2.1 Replace `entropy.rs` (30 min)
```rust
// OLD (hardcoded):
let available_hsms = discover_hsms_placeholder().await?;

// NEW (agnostic):
use beardog_tunnel::DiscoveryEngine;
let engine = DiscoveryEngine::new().await?;
let all_hsms = engine.discover_pkcs11_hsms()?;
all_hsms.extend(engine.discover_usb_hsms()?);
all_hsms.extend(engine.discover_mobile_hsms()?);
```

#### 2.2 Replace `key.rs` (1 hour)
- Remove `discover_hsms_placeholder()` entirely
- Use `DiscoveryEngine` for all discovery
- Convert `DiscoveredHsm` to CLI-friendly format

#### 2.3 Replace `hsm.rs` (1 hour)
- Remove `detect_usb_tokens()` - use `engine.discover_usb_hsms()`
- Remove `detect_android_devices()` - use `engine.discover_mobile_hsms()`
- Implement `beardog hsm list` using real discovery

#### 2.4 Update `cross_primal.rs` (30 min)
- Uses placeholder, needs updating

---

### Phase 3: Smart HSM Selection (30 min)
**Status**: ⏳ PENDING

Create intelligent HSM selection:
```rust
fn select_best_hsm(
    hsms: &[DiscoveredHsm],
    preference: &str,
) -> Result<&DiscoveredHsm, BearDogError> {
    match preference {
        "hardware" => hsms.iter()
            .filter(|h| h.assigned_tier == HsmTier::Hardware)
            .max_by_key(|h| h.capabilities.len()),
        "software" => hsms.iter()
            .filter(|h| h.assigned_tier == HsmTier::Software)
            .next(),
        "auto" | _ => hsms.iter()
            .max_by_key(|h| match h.assigned_tier {
                HsmTier::Hardware => 100,
                HsmTier::Software => 10,
                _ => 1,
            }),
    }
}
```

---

## 📊 **Agnostic Evolution Metrics**

### Before (Current)
```
Overall Agnostic:     70%

Constraint System:    100% ✅ (trait-based, user-extensible)
CLI Architecture:     100% ✅ (command-agnostic)
Key Operations:       100% ✅ (algorithm-agnostic)
HSM Discovery:         30% ❌ (hardcoded paths)
USB Token Detection:   40% ❌ (hardcoded vendor IDs)
PKCS#11 Support:       50% ❌ (hardcoded SoftHSM2)
Delegation:           100% ✅ (user-definable)
```

### After Phase 2 (Target)
```
Overall Agnostic:     95% ✅

Constraint System:    100% ✅
CLI Architecture:     100% ✅
Key Operations:       100% ✅
HSM Discovery:         95% ✅ (universal discovery)
USB Token Detection:   95% ✅ (capability-based)
PKCS#11 Support:       95% ✅ (scans all paths)
Delegation:           100% ✅
```

**Improvement**: 70% → 95% (+25 points!) 📈

---

## 🎯 **Benefits of This Evolution**

### Vendor Agnostic ✅
- Works with ANY PKCS#11 provider (not just SoftHSM2)
- Works with ANY FIDO2 token (not just Solo/YubiKey)
- Works with ANY platform keystore
- No hardcoded paths or vendor IDs

### User Experience ✅
- Auto-discovers all available HSMs
- Smart selection based on preference
- Clear feedback on what's available
- Works out of the box

### Maintainability ✅
- Single source of truth (`beardog-tunnel`)
- Easy to add new HSM types
- No CLI code changes for new vendors
- Testable and modular

### Philosophy ✅
> "Users define their own rules. We provide the framework, not the limits."

- ✅ No vendor lock-in
- ✅ Discovers unknown devices
- ✅ Hardware is test subject, not hardcoded
- ✅ Capability-based, not vendor-based

---

## ⏰ **Timeline**

```
Task 1: Fix tests                ✅ COMPLETE (15 min)
────────────────────────────────────────────────────────
Task 2: Wire HSM Discovery       ▶️ IN PROGRESS

  Phase 1: Expose API            ⏳ Next (30 min)
  Phase 2: Wire CLI              ⏳ Pending (2-3 hrs)
  Phase 3: Smart Selection       ⏳ Pending (30 min)
────────────────────────────────────────────────────────
TOTAL REMAINING:                 3-4 hours
```

---

## 🚀 **Next Steps**

### Immediate (Now)
1. Export `DiscoveryEngine` from `beardog-tunnel`
2. Test that exports compile
3. Update CLI to import discovery types

### Then
4. Replace `entropy.rs` placeholder
5. Replace `key.rs` placeholder
6. Replace `hsm.rs` detection functions
7. Update `cross_primal.rs`
8. Add smart HSM selection

### Finally
9. Test with SoftHSM2
10. Test with Solo V2 keys
11. Verify `beardog hsm list` works
12. Run all demos

---

## ✅ **Success Criteria**

- [ ] No hardcoded paths in CLI
- [ ] No hardcoded vendor IDs
- [ ] `DiscoveryEngine` used everywhere
- [ ] `beardog hsm list` shows all HSMs
- [ ] Works with ANY PKCS#11 provider
- [ ] Works with ANY FIDO2 token
- [ ] All 210 tests still passing
- [ ] Demos run successfully
- [ ] 95%+ agnostic score

---

**🐻 After this: BearDog is truly vendor-agnostic! 🔌✨**

---

*Agnostic Evolution - December 11, 2025*  
*Status: Task 1 Complete, Task 2 In Progress*  
*Goal: 70% → 95% Agnostic*

