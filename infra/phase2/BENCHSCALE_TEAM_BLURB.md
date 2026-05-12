# benchScale Enhancement Request - BiomeOS VM Support

**From**: BiomeOS Team  
**Date**: December 27, 2025  
**Priority**: High (needed for BiomeOS NUC deployment validation)  
**Timeline**: 5 days (parallel with BiomeOS root FS work)

---

## 🎯 What We Need

**Goal**: Extend benchScale to support **BiomeOS VMs** as a backend (in addition to existing Docker backend)

**Why**: We need to validate complete BiomeOS deployments (boot + primals + networking) in VMs before deploying to physical NUCs. This lets us test the full stack in a reproducible way.

---

## 📋 Required Features

### **1. BiomeOS VM Backend** (Priority 1)

Extend benchScale to manage QEMU/KVM VMs (via libvirt - you already have this started!)

**What it needs to do**:
```yaml
# Example topology
topology:
  name: biomeos-federation
  backend: biomeos_vm  # New backend type
  
nodes:
  - name: node1
    type: biomeos_vm
    image: /path/to/biomeos-root.qcow2  # Root filesystem image
    memory: 2G
    vcpus: 2
    network: biome-net
    serial_log: /tmp/node1-serial.log  # Capture boot logs
```

**Key Requirements**:
- Use existing libvirt backend code (already in benchScale)
- Support qcow2 disk images as root filesystems
- VM lifecycle: create, start, stop, destroy, status
- Return VM IP addresses for networking tests

---

### **2. Serial Console Capture** (Priority 1)

BiomeOS uses BootLogger for boot observability via serial console. We need to capture this.

**What it needs to do**:
```rust
// In benchScale VM backend
pub struct BiomeOsVmNode {
    // ... existing fields ...
    serial_log_path: PathBuf,  // Where to write serial output
}

// When starting VM
impl BiomeOsVmNode {
    fn start(&self) -> Result<()> {
        // Configure QEMU with:
        // -serial file:/path/to/serial.log
        // (libvirt XML equivalent)
    }
    
    fn get_serial_log(&self) -> Result<String> {
        // Read serial log file
        std::fs::read_to_string(&self.serial_log_path)
    }
}
```

**Why**: BiomeOS BootLogger writes structured logs to serial. We need to capture and parse these for validation.

---

### **3. Root Filesystem Handling** (Priority 2)

Unlike Docker (images), VMs need disk images.

**What it needs to do**:
```rust
// Support for disk images
pub struct VmDiskConfig {
    source: PathBuf,           // Source qcow2 image
    size: String,              // "10G"
    format: DiskFormat,        // Qcow2, Raw, etc.
    copy_on_write: bool,       // Use backing files?
}

// Example usage
let disk = VmDiskConfig {
    source: PathBuf::from("biomeos-base.qcow2"),
    copy_on_write: true,  // Each VM gets a copy-on-write overlay
    ..Default::default()
};
```

**Why**: We want to start from a base BiomeOS image and let each VM have its own overlay (like Docker layers).

---

### **4. Network Bridge Management** (Priority 2)

VMs need real bridge networking (not Docker's NAT).

**What it needs to do**:
```yaml
network:
  type: bridge
  name: biome-br0
  subnet: 10.42.0.0/24
  dhcp: false  # Static IPs for primals
  
nodes:
  - name: node1
    network:
      ip: 10.42.0.10/24
      gateway: 10.42.0.1
```

**Key Requirements**:
- Create Linux bridge (already have this in network code)
- Assign static IPs to VMs
- VMs can reach each other
- VMs can reach host (for testing)

---

### **5. Health Monitoring for VMs** (Priority 3)

Extend existing health checks to work with VMs (not just containers).

**What it needs to do**:
```rust
impl HealthCheck for BiomeOsVmNode {
    fn is_healthy(&self) -> Result<bool> {
        // Check 1: VM is running (libvirt state)
        // Check 2: Network is up (can ping)
        // Check 3: BootLogger shows "Complete" (parse serial log)
        // Check 4: Can SSH (optional)
    }
}
```

**Why**: We need to know when VMs are fully booted and ready for testing.

---

## 🔧 Implementation Notes

### **Use Existing Code**

You already have most of this! Just needs integration:

1. **libvirt backend** (`src/backend/libvirt.rs`) - Already exists!
   - Just need to wire it into topology management
   - Add serial console configuration

2. **Network simulation** (`src/network/`) - Already exists!
   - Bridge creation already works
   - Just need VM bridge attachment

3. **Backend trait** (`src/backend/mod.rs`) - Already defined!
   - BiomeOS VMs are just another backend implementation

### **New Code Needed**

1. **Serial console integration** - ~100 lines
   - libvirt XML generation for serial console
   - File-based serial logging
   - Log parsing helpers

2. **Disk image management** - ~150 lines
   - qcow2 backing file support
   - Copy-on-write overlay creation
   - Cleanup on destroy

3. **VM health checks** - ~100 lines
   - Extend existing health check trait
   - Parse BootLogger output
   - Network connectivity checks

**Total new code**: ~350 lines (in a codebase of ~2,000 lines)

---

## 📊 Testing Strategy

### **Unit Tests**
```rust
#[test]
fn test_biomeos_vm_creation() {
    let node = BiomeOsVmNode::new(config);
    assert!(node.create().is_ok());
}

#[test]
fn test_serial_log_capture() {
    let node = start_test_vm();
    let log = node.get_serial_log()?;
    assert!(log.contains("[Info] BiomeOS Init"));
}
```

### **Integration Tests**
```bash
# Create 3-node BiomeOS federation
cargo test --test biomeos_vm_integration

# What it tests:
# 1. Create 3 BiomeOS VMs
# 2. Start all VMs
# 3. Wait for boot (parse serial logs)
# 4. Verify networking (ping between VMs)
# 5. Clean shutdown
```

---

## 🗓️ Suggested Timeline (5 days)

**Day 1-2: Core VM Backend**
- Wire libvirt backend into topology management
- Support qcow2 disk images
- Basic VM lifecycle (create, start, stop)
- Unit tests

**Day 3: Serial Console**
- Add serial console configuration to libvirt XML
- File-based logging
- Log parsing utilities
- Tests

**Day 4: Networking & Health**
- Bridge network integration
- Static IP assignment
- VM health checks
- Tests

**Day 5: Integration & Documentation**
- Full integration test
- Update README with BiomeOS VM examples
- Coordinate with BiomeOS team

---

## 🎯 Success Criteria

By end of Day 5, benchScale should be able to:

```bash
# Create topology
cat > biomeos-test.yaml << EOF
topology:
  name: biomeos-test
  backend: biomeos_vm
  
nodes:
  - name: node1
    image: /path/to/biomeos.qcow2
    memory: 2G
    network:
      ip: 10.42.0.10
EOF

# Deploy
benchscale create biomeos-test.yaml
benchscale start biomeos-test

# Validate
benchscale status biomeos-test
# Should show:
# node1: RUNNING, IP: 10.42.0.10, Boot: Complete (178ms)

# Get logs
benchscale logs biomeos-test node1
# Should show BootLogger output

# Cleanup
benchscale destroy biomeos-test
```

---

## 🤝 Coordination Points

### **We'll Provide** (BiomeOS Team):
- ✅ Working BiomeOS root filesystem image (qcow2)
- ✅ Expected BootLogger output format
- ✅ Network configuration requirements
- ✅ Health check criteria
- ✅ Integration test scenarios

### **We Need** (benchScale Team):
- 🔧 VM backend working (Day 2)
- 🔧 Serial console capture (Day 3)
- 🔧 Full integration ready (Day 5)

### **Sync Points**:
- **Day 2**: Check in - VM backend basics working?
- **Day 3**: Check in - Can we see serial output?
- **Day 5**: Integration - Test together!

---

## 📚 Reference Materials

### **Existing Code to Build On**:
- `benchscale/src/backend/libvirt.rs` - libvirt integration (already exists!)
- `benchscale/src/backend/mod.rs` - Backend trait
- `benchscale/src/network/mod.rs` - Network simulation
- `benchscale/src/topology/mod.rs` - Topology management

### **BiomeOS Resources**:
- `biomeOS/BOOTLOGGER_PHASE1_SUCCESS.md` - BootLogger format
- `biomeOS/specs/boot-observability.md` - Boot system spec
- `biomeOS/scripts/setup-vm-network.sh` - Network setup example

### **libvirt Serial Console**:
```xml
<!-- Example libvirt XML for serial console -->
<domain type='kvm'>
  <devices>
    <serial type='file'>
      <source path='/tmp/vm-serial.log'/>
      <target type='isa-serial' port='0'/>
    </serial>
    <console type='file'>
      <source path='/tmp/vm-console.log'/>
      <target type='serial' port='0'/>
    </console>
  </devices>
</domain>
```

---

## 💡 Why This Matters

**Current State**: 
- benchScale can deploy primals in Docker
- BiomeOS can boot VMs manually
- No automated way to test complete BiomeOS deployments

**With This Enhancement**:
- ✅ Automated BiomeOS VM deployment
- ✅ Full boot-to-federation testing
- ✅ Reproducible validation before NUC deployment
- ✅ Same tool for containers AND VMs
- ✅ Production-quality testing infrastructure

**Impact**: De-risks BiomeOS NUC deployment by validating everything in VMs first. Makes benchScale the universal testing tool for the entire ecoPrimals ecosystem.

---

## 🚀 Getting Started

### **If You Accept This**:

1. **Reply with timeline** (5 days realistic?)
2. **Assign owner** (who's driving this?)
3. **Set sync schedule** (Day 2, 3, 5 check-ins)
4. **Clone BiomeOS repo** (for reference/testing)

### **Questions?**

Reach out anytime! We're coordinating closely and can provide:
- BiomeOS disk images for testing
- BootLogger output examples
- Integration test scenarios
- Debugging help

---

**Summary**: Extend benchScale to support BiomeOS VMs using existing libvirt code. ~350 new lines, 5-day timeline. Enables full BiomeOS validation before NUC deployment.

**This is the critical path for BiomeOS production deployment.** 🚀

---

**Contact**: BiomeOS Team  
**Repository**: `biomeOS/` (adjacent to `benchscale/`)  
**Documentation**: See `BENCHSCALE_TO_NUC_STRATEGY.md`

