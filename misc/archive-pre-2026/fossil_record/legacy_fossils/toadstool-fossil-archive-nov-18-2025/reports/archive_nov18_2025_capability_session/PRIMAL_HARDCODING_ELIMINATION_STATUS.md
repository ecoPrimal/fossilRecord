# 🔄 Primal Hardcoding Elimination - Implementation Status

**Date**: November 18, 2025  
**Status**: 🟢 **Phase 1 In Progress**  
**Goal**: Zero hardcoded primal/vendor names, pure capability-based discovery

---

## 📊 QUICK STATUS

| Phase | Status | Progress | Completion |
|-------|--------|----------|------------|
| **Phase 1: Abstractions** | 🟢 In Progress | 60% | 3 of 5 files |
| **Phase 2: Migration** | ⏳ Not Started | 0% | 0 of 4 files |
| **Phase 3: Port Cleanup** | ⏳ Not Started | 0% | 0 of 3 tasks |
| **Phase 4: Vendor Abstraction** | ⏳ Not Started | 0% | 0 of 3 tasks |

**Overall**: 🟡 **15% Complete** (3 of 20 deliverables)

---

## ✅ COMPLETED

### Phase 1: Capability-Based Abstractions

1. ✅ **Capability Taxonomy** (`capabilities/taxonomy.rs`)
   - 70+ standard capabilities defined
   - Hierarchical naming: `category.subcategory.specific`
   - Wildcard matching support
   - Zero primal name dependencies

2. ✅ **Capability Registry** (`capabilities/registry.rs`)
   - Provider registration and lookup
   - Priority-based provider selection
   - Health-aware routing
   - Automatic stale provider cleanup
   - TTL-based caching

3. ✅ **Capability Resolver** (`capabilities/resolver.rs`)
   - Bridges infant discovery → capability registry
   - Cache-first resolution
   - Auto-registration of discovered services
   - Preference-based filtering

4. ✅ **Migration Plan** (`docs/planning/PRIMAL_HARDCODING_ELIMINATION_PLAN.md`)
   - 554 lines of comprehensive guidance
   - 4-phase implementation plan
   - Example code transformations
   - Success criteria defined

---

## 🚧 IN PROGRESS

### Phase 1: Remaining Tasks

5. 🔄 **Universal Service Adapter** (`adapters/universal.rs`)
   - Protocol negotiation
   - Request/response routing
   - Error handling
   - **ETA**: 1 day

6. 🔄 **Protocol Framework** (`protocols/`)
   - HTTP adapter
   - gRPC adapter
   - Message queue adapter
   - **ETA**: 2 days

---

## ⏳ NOT STARTED

### Phase 2: Service Integration Migration

7. ⏳ **CryptoAdapter** (replaces `services/beardog.rs`)
   - Ed25519 signature verification
   - Key generation
   - Encryption/decryption
   - **ETA**: 2 days

8. ⏳ **StorageAdapter** (replaces `services/nestgate.rs`)
   - Distributed filesystem mounting
   - Object storage access
   - Key-value operations
   - **ETA**: 2 days

9. ⏳ **CoordinationAdapter** (replaces `services/songbird.rs`)
   - Service registration
   - Peer discovery
   - Health checking
   - **ETA**: 1 day

10. ⏳ **Deprecate Service Files**
    - Add deprecation warnings
    - Update documentation
    - Migration guide for users
    - **ETA**: 1 day

### Phase 3: Port Hardcoding Cleanup

11. ⏳ **Remove `get_standard_service_ports()`**
    - Delete function from `discovery.rs`
    - Remove all port → service mappings
    - **ETA**: 1 hour

12. ⏳ **Environment-Based Discovery**
    - `TOADSTOOL_*_SERVICE_URL` variables
    - Fallback to mDNS discovery
    - **ETA**: 1 day

13. ⏳ **Configuration File Support**
    - `~/.toadstool/services.toml`
    - Per-project `.toadstool/config.toml`
    - **ETA**: 1 day

### Phase 4: Vendor Abstraction

14. ⏳ **Infrastructure Provider Abstraction**
    - Generic deployment interface
    - Dynamic provider detection
    - **ETA**: 2 days

15. ⏳ **Service Mesh Detection**
    - Auto-detect Consul, etcd, K8s
    - Protocol-agnostic queries
    - **ETA**: 2 days

16. ⏳ **Remove Vendor References**
    - Grep for k8s, consul, docker, etc.
    - Replace with generic abstractions
    - **ETA**: 1 day

---

## 📈 CURRENT CAPABILITIES

### Standard Capabilities Defined (70+)

```
crypto.*              (8 capabilities)
  ├── signature.*     (ed25519, ecdsa, rsa)
  ├── encryption.*    (aes256, chacha20)
  ├── key-*           (generation, derivation)
  └── random

storage.*             (6 capabilities)
  ├── distributed.*
  ├── object.*
  ├── block
  ├── kv
  └── database.*

coordination.*        (6 capabilities)
  ├── service-registry
  ├── peer-discovery
  ├── leader-election
  ├── distributed-lock
  ├── config-management
  └── health-check

compute.*             (7 capabilities)
  ├── container.oci
  ├── wasm.*          (component-model, wasi)
  ├── native
  ├── python
  ├── gpu
  └── edge

messaging.*           (5 capabilities)
  ├── queue.amqp
  ├── pubsub.*        (mqtt, redis)
  ├── stream.kafka
  └── websocket

networking.*          (6 capabilities)
  ├── http
  ├── grpc
  ├── graphql
  ├── load-balancer
  ├── service-mesh
  └── tunnel

monitoring.*          (5 capabilities)
  ├── metrics
  ├── tracing
  ├── logs
  ├── alerting
  └── health-aggregation

auth.*                (5 capabilities)
  ├── oauth2
  ├── api-key
  ├── jwt
  ├── permissions
  └── rbac

infra.*               (5 capabilities)
  ├── kubernetes
  ├── docker
  ├── systemd
  ├── dns
  └── certificates
```

---

## 🎯 EXAMPLE: BEFORE vs AFTER

### ❌ BEFORE (Hardcoded)

```rust
// Knows about BearDog specifically
use crate::ecosystem::services::beardog;

let beardog_addr = "127.0.0.1:8081";  // Hardcoded port
let verified = beardog::verify_ed25519_signature(
    &public_key,
    &message,
    &signature,
).await?;
```

### ✅ AFTER (Capability-Based)

```rust
// Knows nothing about BearDog
use crate::ecosystem::adapters::CryptoAdapter;
use crate::ecosystem::capabilities::StandardCapability;

let crypto = CryptoAdapter::new(universal_adapter);
let verified = crypto.verify_signature(
    StandardCapability::CryptoSignatureEd25519,
    &public_key,
    &message,
    &signature,
).await?;

// Under the hood:
// 1. Discovers "who provides crypto.signature.ed25519?"
// 2. Could find BearDog, AWS KMS, HashiCorp Vault, or custom HSM
// 3. Negotiates protocol (HTTP, gRPC, etc.)
// 4. Invokes service
// 5. Returns result
//
// Code never knows what service it used!
```

---

## 📊 FILES CREATED

### New Files (Phase 1)

```
docs/planning/
└── PRIMAL_HARDCODING_ELIMINATION_PLAN.md          (554 lines)

crates/cli/src/ecosystem/
├── capabilities/
│   ├── mod.rs                                     (8 lines)
│   ├── taxonomy.rs                                (347 lines)
│   ├── registry.rs                                (263 lines)
│   └── resolver.rs                                (261 lines)
└── (more to come in Phase 1-2)
```

**Total New Code**: 879 lines  
**Total Documentation**: 554 lines  
**Grand Total**: 1,433 lines created

---

## 🎯 NEXT STEPS (This Week)

### Immediate Priorities

1. **Complete UniversalServiceAdapter** (1 day)
   - Protocol routing
   - Request/response handling
   - Error propagation

2. **Create Protocol Framework** (2 days)
   - HTTP adapter
   - gRPC adapter
   - Protocol negotiation

3. **Begin Phase 2** (3 days)
   - CryptoAdapter
   - StorageAdapter
   - CoordinationAdapter

**Expected Completion of Phase 1**: End of this week  
**Expected Completion of Phase 2**: End of next week

---

## 🏆 SUCCESS METRICS

### Phase 1 Success Criteria
- [x] Capability taxonomy defined (70+ capabilities)
- [x] Capability registry implemented
- [x] Capability resolver implemented
- [ ] Universal service adapter implemented
- [ ] Protocol framework implemented

### Overall Success Criteria
- [ ] Zero hardcoded primal names in production code
- [ ] Zero hardcoded ports/addresses in production code
- [ ] Zero vendor names (k8s, consul, etc.) in production code
- [ ] Can swap any service without code changes
- [ ] Infant discovery works end-to-end
- [ ] All tests pass with capability-based code

---

## 🎓 ARCHITECTURAL PRINCIPLES

### Core Philosophy

> **"Each primal knows only itself. Everything else is discovered via capabilities."**

This means:

1. **No Service Names**: Code never mentions "BearDog", "NestGate", "Songbird"
2. **No Port Numbers**: Discovery finds endpoints dynamically
3. **No Vendor Lock**: Works with any provider of a capability
4. **Zero Configuration**: Infant discovery starts with nothing
5. **Network Effects**: Universal adapter creates n→n connections, not n²

### Example Scenarios

**Scenario 1**: Swapping Crypto Providers
```
Today:    ToadStool → BearDog
Tomorrow: ToadStool → AWS KMS (zero code changes)
Next:     ToadStool → Hardware HSM (zero code changes)
```

**Scenario 2**: Multi-Provider Support
```
ToadStool discovers TWO crypto services:
- BearDog at 10.0.0.5:9876 (priority: 90)
- AWS KMS at kms.us-west-2.amazonaws.com (priority: 50)

Automatically uses BearDog (higher priority)
Falls back to AWS KMS if BearDog unavailable
```

**Scenario 3**: New Primal Integration
```
A new primal "Dolphin" provides "auth.oauth2" capability.

ToadStool code needs OAuth2 → discovers Dolphin automatically.
No code changes needed. No hardcoding. Pure capability matching.
```

---

## 📞 RESOURCES

- **Migration Plan**: `docs/planning/PRIMAL_HARDCODING_ELIMINATION_PLAN.md`
- **Capability Taxonomy**: `crates/cli/src/ecosystem/capabilities/taxonomy.rs`
- **Status**: This document (`PRIMAL_HARDCODING_ELIMINATION_STATUS.md`)

---

**Last Updated**: November 18, 2025  
**Next Review**: November 19, 2025 (check Phase 1 completion)  
**Target Completion**: December 6, 2025 (3 weeks)

🎯 **Goal**: Fully agnostic, capability-based ecosystem integration with zero hardcoded primals, ports, or vendors.

