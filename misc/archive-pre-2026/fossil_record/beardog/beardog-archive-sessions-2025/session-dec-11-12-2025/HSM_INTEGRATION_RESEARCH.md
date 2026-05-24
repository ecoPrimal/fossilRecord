# 🔑 HSM Integration Research & Planning

**Hardware Security Module Integration for BearDog**

---

## 🎯 Goal

Integrate real hardware HSMs (Solo V2 and Pixel 8a StrongBox) to enable:
1. Hardware-backed cryptographic operations
2. Biometric authentication via hardware
3. Secure key storage in dedicated hardware
4. Physical security for sensitive operations

---

## 🔍 Current Status

### Solo V2 (SoloKeys)
**Status**: Mock implementation exists

**Current Code**: `crates/beardog-hsm/src/providers/solo_v2.rs`

**What Exists**:
- Basic provider structure
- Mock key generation
- Mock sign/verify
- HSM discovery placeholder

**What's Missing**:
- Real USB/HID communication
- FIDO2/CTAP2 protocol implementation
- Actual cryptographic operations via hardware
- PIN/biometric verification

### Pixel 8a StrongBox
**Status**: Mock implementation for non-Android platforms

**Current Code**: `crates/beardog-tunnel/src/hsm/strongbox.rs`

**What Exists**:
- Basic structure
- Mock implementation for Linux

**What's Missing**:
- Android KeyStore integration
- TEE (Trusted Execution Environment) communication
- JNI bindings (if needed)
- Biometric integration via Android APIs

---

## 📚 Research: Solo V2 Integration

### Hardware Overview
- **Device**: SoloKeys Solo V2
- **Interface**: USB HID (FIDO2/WebAuthn)
- **Protocol**: CTAP2 (Client to Authenticator Protocol)
- **Features**: FIDO2, WebAuthn, U2F, resident keys, PIN protection

### Rust Crates Available

#### Option 1: `ctap-hid-fido2` (Recommended)
```toml
[dependencies]
ctap-hid-fido2 = "3.5"
```

**Pros**:
- Pure Rust implementation
- CTAP2 protocol support
- HID communication
- Active maintenance

**Cons**:
- Need to wrap in BearDog abstraction
- May need USB permissions setup

#### Option 2: `authenticator-rs`
```toml
[dependencies]
authenticator = "0.3"
```

**Pros**:
- Mozilla-backed
- Comprehensive FIDO2 support
- Cross-platform

**Cons**:
- Heavier dependency
- May be more than we need

### Implementation Plan

**Phase 1: USB/HID Communication**
1. Add `ctap-hid-fido2` dependency
2. Implement device discovery via HID
3. Test basic communication

**Phase 2: CTAP2 Protocol**
1. Implement GetInfo command
2. Implement MakeCredential (key generation)
3. Implement GetAssertion (signing)

**Phase 3: Key Management**
1. Store key handles securely
2. Map BearDog key IDs to device credentials
3. Implement key lifecycle

**Phase 4: PIN/Biometric**
1. Implement PIN verification
2. Add biometric support (if Solo V2 supports it)
3. Secure PIN storage

**Estimated Time**: 6-8 hours

---

## 📚 Research: Pixel 8a StrongBox Integration

### Hardware Overview
- **Device**: Google Pixel 8a with GrapheneOS
- **Security**: StrongBox (Hardware-backed KeyStore)
- **TEE**: Titan M2 security chip
- **Features**: Hardware-backed keys, biometric auth, TEE isolation

### Android KeyStore API

**Key Components**:
1. `KeyStore` API - Key management
2. `KeyGenerator` - Hardware key generation
3. `Cipher` - Encryption/decryption
4. `Signature` - Signing operations
5. `BiometricPrompt` - Biometric authentication

### Integration Options

#### Option 1: JNI Bindings (Rust → Java/Kotlin)
```toml
[dependencies]
jni = "0.21"
```

**Approach**:
1. Create Kotlin/Java wrapper for KeyStore
2. Use JNI to call from Rust
3. Pass key operations to Android

**Pros**:
- Direct Android API access
- Full feature support

**Cons**:
- JNI complexity
- Platform-specific code
- Harder to test

#### Option 2: NDK Direct Access
**Approach**:
1. Use Android NDK
2. Access KeyStore via C++ API
3. Wrap in Rust

**Pros**:
- Lower-level access
- Better performance

**Cons**:
- Limited API compared to Java
- Still platform-specific

#### Option 3: CLI Tool + IPC
**Approach**:
1. Create small Android app
2. Expose KeyStore operations via CLI/socket
3. Call from Rust via IPC

**Pros**:
- Clean separation
- Easier to test Rust side

**Cons**:
- More components
- IPC overhead

**Recommendation**: Option 1 (JNI) for full integration

### Implementation Plan

**Phase 1: JNI Setup**
1. Add `jni` crate dependency
2. Create Android wrapper module
3. Test basic JNI communication

**Phase 2: KeyStore Integration**
1. Implement key generation in StrongBox
2. Map to BearDog key model
3. Test key persistence

**Phase 3: Cryptographic Operations**
1. Implement encrypt/decrypt via hardware
2. Implement sign/verify via hardware
3. Performance testing

**Phase 4: Biometric Integration**
1. Add BiometricPrompt support
2. Link biometric auth to key access
3. Test with BiometricConstraint

**Estimated Time**: 8-10 hours

---

## 🔗 Integration Architecture

### Unified HSM Interface

```rust
pub trait HsmProvider: Send + Sync {
    /// Discover HSM devices
    async fn discover() -> Result<Vec<HsmInfo>, BearDogError>;
    
    /// Generate key in hardware
    async fn generate_key(
        &self,
        key_id: &str,
        algorithm: Algorithm,
        params: &KeyParams,
    ) -> Result<KeyHandle, BearDogError>;
    
    /// Sign data with hardware key
    async fn sign(
        &self,
        key_handle: &KeyHandle,
        data: &[u8],
    ) -> Result<Vec<u8>, BearDogError>;
    
    /// Verify signature
    async fn verify(
        &self,
        key_handle: &KeyHandle,
        data: &[u8],
        signature: &[u8],
    ) -> Result<bool, BearDogError>;
    
    /// Encrypt with hardware key
    async fn encrypt(
        &self,
        key_handle: &KeyHandle,
        plaintext: &[u8],
    ) -> Result<Vec<u8>, BearDogError>;
    
    /// Decrypt with hardware key
    async fn decrypt(
        &self,
        key_handle: &KeyHandle,
        ciphertext: &[u8],
    ) -> Result<Vec<u8>, BearDogError>;
    
    /// Check biometric (if supported)
    async fn verify_biometric(
        &self,
        biometric_type: BiometricType,
    ) -> Result<bool, BearDogError>;
}
```

### Platform-Specific Compilation

```rust
#[cfg(target_os = "linux")]
use solo_v2_provider::SoloV2Provider;

#[cfg(target_os = "android")]
use strongbox_provider::StrongBoxProvider;

pub fn get_available_hsms() -> Vec<Box<dyn HsmProvider>> {
    let mut hsms: Vec<Box<dyn HsmProvider>> = vec![];
    
    #[cfg(target_os = "linux")]
    if let Ok(solo) = SoloV2Provider::new() {
        hsms.push(Box::new(solo));
    }
    
    #[cfg(target_os = "android")]
    if let Ok(strongbox) = StrongBoxProvider::new() {
        hsms.push(Box::new(strongbox));
    }
    
    // Software HSM always available
    hsms.push(Box::new(SoftHsmProvider::new()));
    
    hsms
}
```

---

## 🧪 Testing Strategy

### Without Hardware
- Keep mock implementations for CI/CD
- Unit tests with mocks
- Integration tests with software HSM

### With Hardware
- Manual testing with physical devices
- Platform-specific test suites
- Conditional compilation for hardware tests

### Test Coverage
- ✅ Software HSM: 100% automated
- ⚠️ Hardware HSMs: Manual testing required
- 🎯 Goal: 90% coverage overall (excluding hardware-specific)

---

## 🎯 Success Criteria

### Solo V2 ✅
- [ ] Device discovery working
- [ ] Key generation in hardware
- [ ] Sign/verify operations
- [ ] PIN verification
- [ ] Integration with BiometricConstraint (if supported)

### Pixel StrongBox ✅
- [ ] JNI communication working
- [ ] KeyStore integration complete
- [ ] Key operations in TEE
- [ ] Biometric authentication
- [ ] Integration with BiometricConstraint

### Overall ✅
- [ ] Unified HSM interface
- [ ] Automatic HSM discovery
- [ ] Graceful fallback to software
- [ ] Clear error messages
- [ ] Documentation complete

---

## 📅 Timeline

### Week 1
- Research complete (this document)
- Solo V2 integration started
- Basic USB/HID communication working

### Week 2
- Solo V2 integration complete
- Begin Pixel StrongBox integration
- JNI setup complete

### Week 3
- Pixel StrongBox integration complete
- BiometricConstraint wiring
- End-to-end hardware testing

### Week 4
- Polish and documentation
- Performance testing
- Create hardware demos

---

*HSM Integration Research - December 11, 2025*  
*Status: Research Complete*  
*Next: Begin Solo V2 Implementation*
