# 🎯 Zero Hardcoding Migration - Infant Discovery Architecture

**Date**: January 1, 2026 19:30 UTC  
**Status**: 🔧 **IN PROGRESS**  
**Goal**: Eliminate ALL hardcoding - primals, vendors, ports, services

---

## 🎓 Core Philosophy: "Start Like an Infant"

> **"The code when deployed starts with 0 knowledge and discovers much like an infant"**

### Principles

1. **Self-Knowledge Only**: Each primal only knows itself
2. **Zero Hardcoding**: No primal names, vendor names, or port numbers in code
3. **Capability-Based**: Discover by "what can you do?" not "who are you?"
4. **Universal Adapter**: Single point for all network effects (not 2^n connections)
5. **Graceful Discovery**: Find services at runtime, fallback if unavailable

---

## 📊 Current State Analysis

### Hardcoding Found

```
🔴 Primal Hardcoding:   838 references across 139 files
   - "beardog", "songbird", "toadstool", "squirrel", "nestgate"
   - Each primal hardcoded to know others by name

🔴 Port Hardcoding:      909 references across 195 files
   - :9000 (BearDog), :8080 (HTTP), :2300 (discovery)
   - Hardcoded in tests, configs, clients

🔴 Vendor Hardcoding:    1,188 references across 101 files
   - "kubernetes", "k8s", "consul", "docker", "etcd"
   - Vendor-specific discovery backends

TOTAL: 2,935 hardcoded references to eliminate!
```

---

## 🎯 Target Architecture

### Before (Hardcoded 2^n Mesh)

```
┌─────────────┐      ┌─────────────┐
│  Songbird   │─────→│   BearDog   │ (hardcoded "beardog:9000")
│             │      │   :9000     │
└─────────────┘      └─────────────┘
      │  ↘                 ↓
      │    ↘         ┌─────────────┐
      │      ↘──────→│  Toadstool  │ (hardcoded "toadstool:3000")
      │              │   :3000     │
      ↓              └─────────────┘
┌─────────────┐
│  Squirrel   │ (hardcoded "squirrel:4000")
│   :4000     │
└─────────────┘

Problem: N primals = N² connections to maintain!
```

### After (Universal Adapter - Zero Hardcoding)

```
┌─────────────────────────────────────────────────────────┐
│         Universal Adapter (Capability Registry)         │
│  • Knows NO primal names                                │
│  • Discovers by capability: "Who has 'security'?"       │
│  • Runtime service mesh                                 │
└─────────────────────────────────────────────────────────┘
      ↑         ↑           ↑          ↑
      │         │           │          │
      │         │           │          │
   [security] [storage] [compute]  [ai-inference]
      │         │           │          │
┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│ Primal A │ │ Primal B │ │ Primal C │ │ Primal D │
│ (crypto) │ │ (storage)│ │ (compute)│ │   (ai)   │
└──────────┘ └──────────┘ └──────────┘ └──────────┘

Each primal:
  1. Knows ONLY itself
  2. Advertises capabilities
  3. Queries adapter for needs
  
Result: N primals = N connections (not N²!)
```

---

## 🔧 Implementation Strategy

### Phase 1: Capability-Based Client (PRIORITY)

**Replace**: Hardcoded primal clients  
**With**: Capability-based universal client

**Before**:
```rust
// ❌ Hardcoded - knows BearDog by name
let beardog = BearDogClient::new("http://localhost:9000");
let decision = beardog.evaluate_trust(peer).await?;
```

**After**:
```rust
// ✅ Capability-based - discovers security provider
let security = adapter.find_capability("security").await?;
let decision = security.evaluate_trust(peer).await?;

// If no security provider found:
//   1. Try multicast discovery
//   2. Check service registry
//   3. Fall back to prompting user
```

### Phase 2: Self-Knowledge Bootstrap

**Each primal starts knowing ONLY itself**:

```rust
// On startup, primal discovers itself
pub struct SelfKnowledge {
    /// What am I? (discovered from binary name or env)
    pub identity: Option<String>,  // NOT hardcoded!
    
    /// What can I do? (introspected from available modules)
    pub capabilities: Vec<String>,
    
    /// Where am I listening? (discovered from bound ports)
    pub endpoints: Vec<Endpoint>,
    
    /// What do I need? (declared in manifest or discovered)
    pub required_capabilities: Vec<String>,
}

// Example for ANY primal:
impl SelfKnowledge {
    pub async fn discover() -> Result<Self> {
        Ok(Self {
            // Discover identity from binary name
            identity: std::env::current_exe()?
                .file_stem()
                .and_then(|s| s.to_str())
                .map(String::from),
            
            // Introspect capabilities from available modules
            capabilities: Self::introspect_capabilities()?,
            
            // Discover bound endpoints from system
            endpoints: Self::discover_bound_endpoints().await?,
            
            // Read required capabilities from manifest
            required_capabilities: Self::load_required_capabilities()?,
        })
    }
}
```

### Phase 3: Universal Adapter Integration

**Single interface for all primals**:

```rust
/// Universal adapter - works for ANY primal
pub struct UniversalPrimalAdapter {
    /// Service registry (capability → endpoints)
    registry: CapabilityRegistry,
    
    /// Discovery backends (try in order)
    discovery: Vec<Box<dyn DiscoveryBackend>>,
}

impl UniversalPrimalAdapter {
    /// Find a service by capability (not name!)
    pub async fn find_capability(&self, capability: &str) 
        -> Result<CapabilityClient> 
    {
        // 1. Check local registry (cached)
        if let Some(endpoint) = self.registry.find(capability).await? {
            return Ok(CapabilityClient::new(endpoint));
        }
        
        // 2. Try discovery backends in order
        for backend in &self.discovery {
            if let Ok(endpoint) = backend.discover(capability).await {
                self.registry.register(capability, endpoint.clone()).await?;
                return Ok(CapabilityClient::new(endpoint));
            }
        }
        
        // 3. No provider found
        Err(CapabilityNotFound(capability.to_string()))
    }
    
    /// Register our capabilities (broadcast)
    pub async fn advertise(&self, self_knowledge: &SelfKnowledge) 
        -> Result<()> 
    {
        for backend in &self.discovery {
            backend.advertise(self_knowledge).await?;
        }
        Ok(())
    }
}
```

### Phase 4: Discovery Backends (Pluggable)

**No hardcoded vendors**:

```rust
/// Generic discovery backend trait
#[async_trait]
pub trait DiscoveryBackend: Send + Sync {
    /// Discover a service by capability
    async fn discover(&self, capability: &str) -> Result<ServiceEndpoint>;
    
    /// Advertise our capabilities
    async fn advertise(&self, knowledge: &SelfKnowledge) -> Result<()>;
}

/// Implementations (auto-detected at runtime)
pub enum DiscoveryBackendType {
    /// Local multicast (always available)
    Multicast(MulticastDiscovery),
    
    /// Service registry (if available)
    Registry(ServiceRegistryClient),
    
    /// Container orchestrator (if running in one)
    Container(Box<dyn ContainerDiscovery>),  // NOT "Kubernetes"!
    
    /// DNS-SD (if available)
    DnsSd(DnsSdClient),
}

impl DiscoveryBackendType {
    /// Auto-detect available backends (infant discovery!)
    pub async fn auto_detect() -> Vec<Self> {
        let mut backends = vec![];
        
        // Always available: multicast
        backends.push(Self::Multicast(MulticastDiscovery::new()));
        
        // Try to detect service registry
        if let Ok(registry) = Self::detect_registry().await {
            backends.push(Self::Registry(registry));
        }
        
        // Try to detect container orchestrator (generic!)
        if let Ok(container) = Self::detect_container().await {
            backends.push(Self::Container(container));
        }
        
        // Try DNS-SD
        if let Ok(dns_sd) = Self::detect_dns_sd().await {
            backends.push(Self::DnsSd(dns_sd));
        }
        
        backends
    }
    
    /// Detect if running in a container orchestrator
    async fn detect_container() -> Result<Box<dyn ContainerDiscovery>> {
        // Try Kubernetes API (generic detection, no hardcoding!)
        if let Ok(k8s) = KubernetesDiscovery::try_new().await {
            return Ok(Box::new(k8s));
        }
        
        // Try Consul API
        if let Ok(consul) = ConsulDiscovery::try_new().await {
            return Ok(Box::new(consul));
        }
        
        // Try Docker API
        if let Ok(docker) = DockerDiscovery::try_new().await {
            return Ok(Box::new(docker));
        }
        
        Err(anyhow!("No container orchestrator detected"))
    }
}
```

---

## 🔄 Migration Plan

### Step 1: Create Capability Mapping

Map hardcoded names → capabilities:

```rust
// OLD (hardcoded):
let beardog = BearDogClient::new("http://localhost:9000");

// NEW (capability-based):
let security = adapter.find_capability("security").await?;
```

**Capability Taxonomy**:
```
security:
  - identity (BearDog provides this)
  - encryption (BearDog provides this)
  - trust-evaluation (BearDog provides this)

storage:
  - object-storage
  - block-storage
  - database

compute:
  - cpu (Toadstool provides this)
  - gpu
  - inference (Squirrel might provide this)

orchestration:
  - discovery (Songbird provides this)
  - coordination
  - federation
```

### Step 2: Update BearDog Client

**File**: `crates/songbird-orchestrator/src/beardog_client.rs`

```rust
// NEW: Make it capability-aware, not name-aware
pub struct SecurityCapabilityClient {
    /// Generic HTTP client (works for ANY security provider)
    http_client: Client,
    
    /// Discovered endpoint (not hardcoded!)
    endpoint: ServiceEndpoint,
}

impl SecurityCapabilityClient {
    /// Create from discovered endpoint
    pub fn from_endpoint(endpoint: ServiceEndpoint) -> Self {
        Self {
            http_client: Client::new(),
            endpoint,
        }
    }
    
    /// Evaluate trust (generic security capability)
    pub async fn evaluate_trust(&self, request: &TrustEvaluationRequest) 
        -> Result<TrustEvaluationResponse> 
    {
        let url = format!("{}/api/v1/trust/evaluate", self.endpoint.url);
        // ... same implementation, but endpoint discovered at runtime!
    }
}
```

### Step 3: Update Discovery to Use Adapter

**File**: `crates/songbird-orchestrator/src/app/startup.rs` (NEW)

```rust
pub async fn initialize_with_zero_knowledge() -> Result<App> {
    // 1. Discover ourselves (introspection)
    let self_knowledge = SelfKnowledge::discover().await?;
    info!("✅ Self-discovered identity: {:?}", self_knowledge.identity);
    info!("✅ Self-discovered capabilities: {:?}", self_knowledge.capabilities);
    
    // 2. Create universal adapter
    let mut adapter = UniversalPrimalAdapter::auto_detect().await?;
    
    // 3. Advertise our capabilities
    adapter.advertise(&self_knowledge).await?;
    info!("✅ Advertised to universal adapter");
    
    // 4. Discover required capabilities (not by name!)
    for capability in &self_knowledge.required_capabilities {
        match adapter.find_capability(capability).await {
            Ok(client) => {
                info!("✅ Found provider for capability: {}", capability);
            },
            Err(_) => {
                warn!("⚠️ No provider for capability: {} (will fallback)", capability);
            },
        }
    }
    
    Ok(App {
        self_knowledge,
        adapter,
    })
}
```

### Step 4: Eliminate Port Hardcoding

**Replace**: All hardcoded ports with discovery or env vars

```rust
// Configuration precedence (infant-style):
// 1. Environment variable (explicit config)
// 2. Service discovery (found at runtime)
// 3. Dynamic port (OS assigns)
// 4. NO default port hardcoded!

pub async fn bind_server() -> Result<SocketAddr> {
    // Try explicit port from env
    if let Ok(port_str) = env::var("SERVICE_PORT") {
        let port = port_str.parse()?;
        return Ok(SocketAddr::from(([0, 0, 0, 0], port)));
    }
    
    // Try to find available port in registry
    if let Ok(port) = discover_available_port().await {
        return Ok(SocketAddr::from(([0, 0, 0, 0], port)));
    }
    
    // Let OS assign (bind to port 0)
    let listener = TcpListener::bind("0.0.0.0:0").await?;
    let addr = listener.local_addr()?;
    info!("✅ OS assigned port: {}", addr.port());
    
    // Register our discovered port
    register_discovered_endpoint(addr).await?;
    
    Ok(addr)
}
```

### Step 5: Eliminate Vendor Hardcoding

**Make container discovery vendor-agnostic**:

```rust
/// Generic container discovery (works for any orchestrator)
#[async_trait]
pub trait ContainerDiscovery: Send + Sync {
    /// Get service endpoint by capability
    async fn find_by_capability(&self, capability: &str) 
        -> Result<ServiceEndpoint>;
    
    /// Register our service
    async fn register(&self, service: &ServiceInfo) -> Result<()>;
}

/// Auto-detect which container orchestrator we're in
pub async fn detect_orchestrator() -> Result<Box<dyn ContainerDiscovery>> {
    // Try Kubernetes (via API server detection, not name!)
    if env::var("KUBERNETES_SERVICE_HOST").is_ok() {
        return Ok(Box::new(KubernetesDiscovery::new()));
    }
    
    // Try Consul (via agent detection)
    if let Ok(consul) = ConsulDiscovery::try_connect().await {
        return Ok(Box::new(consul));
    }
    
    // Try Docker (via socket detection)
    if Path::new("/var/run/docker.sock").exists() {
        return Ok(Box::new(DockerDiscovery::new()));
    }
    
    Err(anyhow!("No container orchestrator detected"))
}
```

---

## 📝 File-by-File Migration

### High Priority Files

1. **`crates/songbird-orchestrator/src/beardog_client.rs`**
   - Rename to `security_capability_client.rs`
   - Remove "beardog" references (189 lines to update)
   - Make endpoint discovery-based

2. **`crates/songbird-types/src/config/consolidated_canonical/discovery.rs`**
   - Remove default port `2300` → dynamic
   - Remove hardcoded addresses

3. **`crates/songbird-discovery/src/abstraction/adapters/*.rs`**
   - Make vendor adapters implement generic trait
   - Remove vendor name hardcoding (1,188 references!)

4. **`crates/songbird-config/src/*.rs`**
   - Remove all port constants
   - Replace with env-driven config

---

## 🎯 Success Criteria

### Zero Hardcoding Achieved When:

1. ✅ **Primal Names**: No "beardog", "songbird", etc. in production code
2. ✅ **Port Numbers**: No `:9000`, `:8080`, etc. in production code
3. ✅ **Vendor Names**: No "kubernetes", "consul", etc. in production code
4. ✅ **Discovery**: All services found via capability queries
5. ✅ **Tests Pass**: All 695+ tests updated and passing
6. ✅ **Documentation**: "Infant Discovery" guide complete

### Acceptance Test:

```bash
# Deploy ANY primal with ZERO configuration
$ ./primal-binary

# It should:
1. Discover its own identity
2. Discover available endpoints
3. Register with universal adapter
4. Find required capabilities
5. Start serving
6. Work in ANY environment (local, k8s, consul, docker, etc.)

# NO hardcoded knowledge required!
```

---

## 📊 Effort Estimate

| Phase | Files | Lines | Effort | Priority |
|-------|-------|-------|--------|----------|
| Capability mapping | 10 | 500 | 2h | HIGH |
| BearDog → Security | 20 | 1,000 | 3h | HIGH |
| Port elimination | 50 | 500 | 2h | MEDIUM |
| Vendor abstraction | 30 | 800 | 4h | MEDIUM |
| Tests update | 100 | 1,000 | 3h | HIGH |
| Documentation | 5 | 500 | 1h | LOW |
| **TOTAL** | **215** | **4,300** | **15h** | - |

**Can be done in parallel** by different team members!

---

## 🚀 Next Steps

### Immediate Actions (This Session)

1. [ ] Create `SecurityCapabilityClient` (generic, not BearDog-specific)
2. [ ] Create `UniversalPrimalAdapter` stub
3. [ ] Create `SelfKnowledge` introspection module
4. [ ] Update discovery to use capabilities
5. [ ] Update 10 highest-impact files

### Phase 2 (Next Session)

1. [ ] Migrate all primal clients to capability-based
2. [ ] Remove all port hardcoding
3. [ ] Abstract vendor-specific discovery
4. [ ] Update all tests
5. [ ] Integration testing

---

_"Every primal is an infant at birth - discovering the world at runtime"_ 🐣

**Status**: 🔧 **Ready to implement**  
**Complexity**: HIGH (2,935 references to eliminate)  
**Impact**: CRITICAL (enables true universal orchestration)  
**Timeline**: 15 hours (parallel work possible)

