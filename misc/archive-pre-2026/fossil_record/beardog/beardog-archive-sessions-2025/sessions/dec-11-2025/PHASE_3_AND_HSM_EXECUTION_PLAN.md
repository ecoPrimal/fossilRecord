# 🚀 Phase 3 & HSM Integration - Execution Plan

**Comprehensive plan for constraint demos and hardware HSM integration**

---

## 📋 Overview

### Phase 3: Constraint System Demos
Complete showcase of the constraint-agnostic architecture with live, verifiable demos.

### HSM Integration: Hardware Support
Full integration of Solo V2 and Pixel 8a StrongBox hardware HSMs.

### Testing: Coverage & Chaos
Achieve 90% test coverage and implement chaos testing framework.

---

## 🎯 Phase 3: Constraint Demos (4 Scripts)

### 1. demo-constraints.sh ✅ COMPLETE
**Status**: Done and tested

**Coverage**: All 14 constraint types
- 6 built-in (with real CLI)
- 8 novel examples (conceptual with implementation references)

**Output**: Cryptographic receipts for all operations

### 2. demo-secure-lab.sh 🚧 IN PROGRESS
**Use Case**: Multi-factor authentication for high-security facility

**Constraints** (6 combined with AND logic):
1. GeoFenceConstraint - Must be on-site (50m radius)
2. TimeRangeConstraint - Business hours (8:00-18:00)
3. WeekdayConstraint - Weekdays only (mon-fri)
4. BiometricConstraint - Fingerprint verified (Solo V2)
5. SystemLoadConstraint - System not overloaded (< 2.0)
6. EnvironmentalConstraint - Safe temperature (18-25°C)

**Implementation**: Real CLI for time/weekday, conceptual for others

### 3. demo-tower-sharing.sh 🚧 NEXT
**Use Case**: Share compute resources with privacy and limits

**Constraints** (4 combined with AND logic):
1. TimeRangeConstraint - Off-peak hours (22:00-6:00)
2. CpuQuotaConstraint - Max 50% CPU
3. MemoryQuotaConstraint - Max 8GB memory
4. ExpiryConstraint - 30 days

**Implementation**: All real CLI (fully working)

### 4. demo-mobile-context.sh 📝 PLANNED
**Use Case**: Context-aware operations on mobile devices

**Constraints** (3 combined with AND/OR logic):
1. BatteryConstraint - Battery > 30%
2. NetworkSsidConstraint OR VpnConstraint - Trusted network
3. SystemLoadConstraint - Not overloaded

**Implementation**: Conceptual (requires mobile platform integration)

---

## 🔑 HSM Integration (3 Components)

### 1. Solo V2 Hardware Support 🚧 IN PROGRESS

**Current Status**: Mock implementation exists

**Tasks**:
- [ ] Research Solo V2 Rust crate/SDK
- [ ] Implement real FIDO2/WebAuthn integration
- [ ] Add CTAP2 protocol support
- [ ] Implement secure key storage
- [ ] Add PIN/biometric verification
- [ ] Test with physical Solo V2 key

**Files to Modify**:
- `crates/beardog-hsm/src/providers/solo_v2.rs`
- `crates/beardog-cli/src/handlers/hsm.rs`

**Dependencies**:
- `fido-rs` or `ctap-hid-fido2` crate
- USB/HID access
- Physical Solo V2 key for testing

**Estimated Time**: 4-6 hours

### 2. Pixel 8a StrongBox Support 🚧 NEXT

**Current Status**: Mock implementation for non-Android

**Tasks**:
- [ ] Research Android StrongBox API
- [ ] Implement JNI bindings (if needed)
- [ ] Add KeyStore integration
- [ ] Implement TEE communication
- [ ] Add biometric authentication
- [ ] Test on Pixel 8a with GrapheneOS

**Files to Modify**:
- `crates/beardog-tunnel/src/hsm/strongbox.rs`
- `android/app/src/hsm/` (new)

**Dependencies**:
- Android NDK
- JNI bindings (`jni` crate)
- Physical Pixel 8a
- GrapheneOS environment

**Platform**: Android-specific (conditional compilation)

**Estimated Time**: 6-8 hours

### 3. BiometricConstraint Integration 📝 PLANNED

**Current Status**: Conceptual implementation

**Tasks**:
- [ ] Wire BiometricConstraint to Solo V2
- [ ] Wire BiometricConstraint to Pixel StrongBox
- [ ] Add biometric verification to delegation
- [ ] Test end-to-end with hardware
- [ ] Create demo with real biometric auth

**Files to Modify**:
- `crates/beardog-types/src/constraints/novel.rs`
- `crates/beardog-cli/src/handlers/key_delegate.rs`

**Dependencies**:
- Solo V2 integration complete
- Pixel StrongBox integration complete

**Estimated Time**: 2-3 hours

---

## 🧪 Testing Enhancement (2 Components)

### 1. Test Coverage to 90% 📊 PLANNED

**Current**: ~85% coverage  
**Target**: 90% coverage  
**Gap**: ~5% (focus on error paths and edge cases)

**Priority Areas**:
1. CLI handler error paths
2. Constraint edge cases
3. HSM provider error handling
4. Key mixing error scenarios
5. Revocation edge cases

**Approach**:
- Use `cargo llvm-cov` to identify gaps
- Add targeted unit tests
- Add integration tests for CLI
- Add property-based tests (proptest)

**Estimated Time**: 4-6 hours

### 2. Chaos Testing Framework 🌀 PLANNED

**Goal**: Test system resilience under adverse conditions

**Test Categories**:
1. **Resource Exhaustion**
   - Memory pressure
   - CPU saturation
   - Disk full
   - Network unavailable

2. **Timing Issues**
   - Race conditions
   - Timeouts
   - Clock skew

3. **HSM Failures**
   - HSM disconnected
   - HSM errors
   - Key not found

4. **Constraint Violations**
   - Expired keys
   - Revoked keys
   - Resource limits exceeded

**Implementation**:
- Create `crates/beardog-testing/src/chaos/`
- Use `tokio-test` for async chaos
- Use `proptest` for property-based testing
- Add chaos scenarios to CI

**Estimated Time**: 6-8 hours

---

## 📅 Execution Timeline

### Immediate (Today)
1. ✅ demo-constraints.sh - DONE
2. 🚧 demo-secure-lab.sh - IN PROGRESS
3. 🚧 demo-tower-sharing.sh - NEXT

### Near-Term (This Week)
4. demo-mobile-context.sh
5. Solo V2 integration research
6. Begin Solo V2 implementation

### Mid-Term (Next Week)
7. Complete Solo V2 integration
8. Pixel StrongBox integration research
9. Begin Pixel StrongBox implementation
10. BiometricConstraint wiring

### Later (Week 3-4)
11. Test coverage push to 90%
12. Chaos testing framework
13. End-to-end hardware tests
14. Performance benchmarking

---

## 🎯 Success Criteria

### Phase 3 Demos ✅
- [ ] 4 demo scripts completed
- [ ] All demos use real BearDog CLI where possible
- [ ] Cryptographic receipts for all operations
- [ ] Clear documentation of conceptual vs. real
- [ ] README updated with demo descriptions

### HSM Integration ✅
- [ ] Solo V2: Real hardware communication working
- [ ] Pixel StrongBox: Real TEE integration working
- [ ] BiometricConstraint: End-to-end with hardware
- [ ] HSM discovery: Automatic hardware detection
- [ ] Error handling: Graceful HSM failures

### Testing ✅
- [ ] Test coverage: 90%+
- [ ] Chaos tests: 20+ scenarios
- [ ] CI integration: All tests passing
- [ ] Performance: No regressions
- [ ] Documentation: Complete test guides

---

## 🚧 Known Challenges

### HSM Integration
1. **Platform-Specific Code**: Need conditional compilation for Android
2. **Hardware Access**: Requires physical devices for testing
3. **Driver/SDK**: May need vendor-specific SDKs
4. **Permissions**: USB/HID access, Android permissions
5. **Testing**: Hard to test without hardware

**Mitigation**: Keep mock implementations for CI/CD, real hardware optional

### Testing
1. **Chaos Tests**: Can be flaky if not designed carefully
2. **Coverage**: Edge cases can be hard to trigger
3. **Time**: Comprehensive testing takes significant time

**Mitigation**: Focus on high-value tests, use property-based testing

---

## 📊 Progress Tracking

### Overall Progress
```
Phase 3 Demos:          25% (1/4 complete)
HSM Integration:        10% (research phase)
Testing Enhancement:    0% (not started)
Overall:                15% complete
```

### Estimated Total Time
```
Phase 3 Demos:          6-8 hours
HSM Integration:        12-18 hours
Testing:                10-14 hours
Total:                  28-40 hours (3.5-5 days)
```

---

## 🎯 Current Focus

**NOW**: Phase 3 demos (demo-secure-lab.sh, demo-tower-sharing.sh)  
**NEXT**: HSM integration research and planning  
**THEN**: Solo V2 implementation

---

*Execution Plan - December 11, 2025*  
*Status: IN PROGRESS*  
*Phase: 3 (Demos) + HSM Integration*  
*Next Update: After Phase 3 demos complete*

