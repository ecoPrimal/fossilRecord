# 🎯 Agnostic Architecture Plan

**BearDog = Vendor-Free Framework**  
**Solo V2 / Pixel 8a = Test Subjects (Not Dependencies)**

---

## 🎓 **Philosophy**

> **BearDog should be agnostic. Physical hardware is what we test ON, not what we build FOR.**

- ✅ BearDog = Works with ANY compatible device
- ✅ Solo V2 = Test subject to validate FIDO2/CTAP2 support
- ✅ Pixel 8a = Test subject to validate mobile HSM support
- ❌ No vendor lock-in
- ❌ No hardcoded vendor IDs
- ❌ No hardcoded paths

---

## 🎯 **Current Status**

### Framework Status:
- ✅ Universal discovery engine created (`DiscoveryEngine`)
- ✅ Capability-based detection (not vendor-based)
- ✅ Agnostic module created (`hsm_agnostic.rs`)
- ⏳ Handler wiring incomplete (key.rs still uses placeholders)

### Remaining Work:
1. **Complete Handler Wiring** (1-2 hours)
   - Remove placeholder code from `key.rs`
   - Wire to universal discovery
   - Update remaining handlers

2. **Verify with Physical Hardware** (30 min)
   - Test Solo V2 detection (should auto-discover)
   - Test Pixel 8a detection (should auto-discover)
   - Verify NO hardcoding needed

---

## 📋 **Execution Plan**

### Phase 1: Complete Agnostic Wiring (1-2 hours)

**Goal**: Remove ALL hardcoding, use universal discovery everywhere

**Tasks**:
- [ ] Remove placeholder code from `entropy.rs` (keep as fallback)
- [ ] Wire `key.rs` to use `hsm_agnostic::discover_all_hsms()`
- [ ] Update all CLI handlers to use universal discovery
- [ ] Remove any remaining vendor IDs from code
- [ ] Verify NO hardcoded paths

**Files to modify**:
- `crates/beardog-cli/src/handlers/key.rs`
- Verify: `crates/beardog-cli/src/handlers/entropy.rs`
- Verify: `crates/beardog-cli/src/handlers/hsm.rs`

**Expected Outcome**:
- BearDog discovers ANY PKCS#11 provider
- BearDog discovers ANY FIDO2/USB token
- BearDog discovers ANY mobile HSM
- NO vendor-specific code in handlers

---

### Phase 2: Validate with Physical Hardware (30 min)

**Goal**: Verify agnostic framework works with real devices

**Test 1: Solo V2 Keys (FIDO2/CTAP2)**
```bash
# Should auto-discover via USB
./target/release/beardog hsm discover --verbose

# Expected: "USB Token detected (FIDO2)"
# NOT: "Solo V2 detected" (vendor-agnostic!)
```

**Test 2: Pixel 8a StrongBox (Mobile HSM)**
```bash
# Should auto-discover via ADB
adb devices
./target/release/beardog hsm discover --verbose

# Expected: "Mobile HSM detected (StrongBox)"
# NOT: "Pixel 8a detected" (vendor-agnostic!)
```

**Test 3: SoftHSM2 (PKCS#11)**
```bash
# Should auto-discover at any path
./target/release/beardog hsm discover --verbose

# Expected: "PKCS#11 provider detected"
# Works at /usr/lib OR /opt/lib OR anywhere
```

**Test 4: Unknown Device**
```bash
# Should work with any compatible FIDO2 token
# Plug in Nitrokey/YubiKey/etc

# Expected: Auto-detected via capability
# NOT: "Unknown device" error
```

---

## 🎯 **Success Criteria**

### Agnostic Framework:
- [ ] NO hardcoded paths in code
- [ ] NO vendor IDs in code  
- [ ] NO device-specific logic in core
- [ ] Universal discovery works
- [ ] Capability-based detection

### Physical Hardware Validation:
- [ ] Solo V2 auto-discovered (no hardcoding)
- [ ] Pixel 8a auto-discovered (no hardcoding)
- [ ] SoftHSM2 works at any path
- [ ] Unknown devices work (if compatible)

### Architecture:
- [ ] BearDog = vendor-free framework
- [ ] Physical devices = test subjects
- [ ] Dev knowledge = how to test
- [ ] Production = works with anything

---

## 🏗️ **Architecture Layers**

```
┌─────────────────────────────────────┐
│  BearDog Core (Vendor-Agnostic)     │
│  - Universal Discovery               │
│  - Capability-Based Detection        │
│  - Trait-Based Extensibility         │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  Discovery Layer (Agnostic)          │
│  - PKCS#11 scanning (any path)       │
│  - USB HID enumeration               │
│  - Mobile HSM detection              │
│  - Capability queries                │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  Physical Hardware (Test Layer)      │
│  - Solo V2 (FIDO2 test subject)     │
│  - Pixel 8a (Mobile test subject)   │
│  - SoftHSM2 (PKCS#11 test subject)  │
│  - Any other compatible device       │
└─────────────────────────────────────┘
```

**Key Insight**: BearDog doesn't know about Solo V2 or Pixel 8a specifically. It knows about:
- FIDO2/CTAP2 protocol
- Android KeyStore API
- PKCS#11 standard

Solo V2 and Pixel 8a just happen to implement these standards!

---

## 🔧 **Implementation Details**

### Current Placeholder Code (TO REMOVE):
```rust
// BAD - Vendor-specific
if line.contains("1209:beee") {  // Solo V2 vendor ID
    // ...
}

// BAD - Hardcoded path
if Path::new("/usr/lib/softhsm/libsofthsm2.so").exists() {
    // ...
}

// BAD - Device-specific
if model.contains("Pixel 8a") {
    // ...
}
```

### Agnostic Replacement:
```rust
// GOOD - Capability-based
let hsms = hsm_agnostic::discover_all_hsms().await?;

// Discovers ANY device that implements:
// - PKCS#11 (any vendor, any path)
// - FIDO2/CTAP2 (any USB token)
// - Mobile HSM (any platform with hardware keystore)
```

---

## 📊 **Expected Outcomes**

### After Agnostic Wiring:
```
Before:  "Solo V2 detected"
After:   "USB Security Token (FIDO2/CTAP2)"

Before:  "Pixel 8a StrongBox detected"
After:   "Mobile HSM (Hardware-Backed KeyStore)"

Before:  "SoftHSM2 at /usr/lib/softhsm/libsofthsm2.so"
After:   "PKCS#11 Provider (Software HSM)"
```

### Vendor-Agnostic Output:
```bash
$ beardog hsm discover

🔍 Discovered 3 HSM(s):

1. PKCS#11 Provider (Software)
   Capabilities: KeyGen, Encrypt, Decrypt, Sign
   
2. USB Security Token (Hardware)
   Protocol: FIDO2/CTAP2
   Capabilities: KeyGen, Sign, UserPresence
   
3. Mobile HSM (Hardware-Backed)
   Platform: Android KeyStore
   Features: StrongBox, Biometric
```

**Notice**: No mention of specific vendors!

---

## 🎓 **Dev Knowledge (Not in Code)**

### Testing with Solo V2:
- Vendor ID: 1209:beee (for manual verification)
- Protocol: FIDO2/CTAP2
- Test: Key generation, signatures, user presence
- **In Code**: Just "FIDO2 device"

### Testing with Pixel 8a:
- Platform: Android 14 / GrapheneOS
- Feature: StrongBox KeyMaster
- Test: Hardware-backed keys, attestation
- **In Code**: Just "Mobile HSM with hardware backing"

### Testing with SoftHSM2:
- Paths: /usr/lib, /opt/lib, /usr/local/lib
- Standard: PKCS#11 v2.40
- Test: Software-backed operations
- **In Code**: Just "PKCS#11 provider"

---

## 🚀 **Execution Steps**

### Step 1: Clean Hardcoding (30-60 min)
```bash
# Review handlers for hardcoding
cd crates/beardog-cli/src/handlers

# Check for vendor IDs
grep -r "1209:beee\|1050:" .

# Check for hardcoded paths
grep -r "/usr/lib/softhsm\|/opt/" .

# Check for device names
grep -r "Solo\|Pixel\|YubiKey" .

# Remove or make agnostic
```

### Step 2: Wire Universal Discovery (30 min)
```bash
# Update key.rs to use agnostic discovery
# Replace: discover_hsms_placeholder()
# With: hsm_agnostic::discover_all_hsms()

# Build and test
cargo build --release
cargo test -p beardog-cli --lib
```

### Step 3: Validate with Hardware (30 min)
```bash
# Test Solo V2
./target/release/beardog hsm discover --verbose

# Test Pixel 8a (if connected)
adb devices
./target/release/beardog hsm discover --verbose

# Test key generation
./target/release/beardog key generate test-key --hsm auto
```

---

## 💎 **Success Metrics**

### Code Quality:
- [ ] Zero vendor IDs in production code
- [ ] Zero hardcoded paths
- [ ] Zero device-specific branches
- [ ] All discovery via universal engine

### Functionality:
- [ ] Discovers Solo V2 (without knowing it's Solo)
- [ ] Discovers Pixel 8a (without knowing it's Pixel)
- [ ] Discovers SoftHSM2 (at any path)
- [ ] Discovers unknown devices (if compatible)

### Philosophy:
- [ ] BearDog = framework
- [ ] Devices = test subjects
- [ ] Users = define their rules
- [ ] Architecture = vendor-free

---

## 🎉 **Expected Result**

**Before**: "Works with Solo V2 and Pixel 8a"  
**After**: "Works with ANY FIDO2 token and ANY mobile HSM with hardware backing"

**Before**: "Hardcoded for specific devices"  
**After**: "Discovers and works with anything compatible"

**Before**: "Vendor lock-in"  
**After**: "Vendor freedom"

---

**🐻 BearDog: Truly agnostic, truly sovereign, truly free! 🔐✨**

---

*Architecture Plan*  
*Focus: Complete agnostic wiring*  
*Validate: Test with physical hardware*  
*Philosophy: Framework, not limits*

