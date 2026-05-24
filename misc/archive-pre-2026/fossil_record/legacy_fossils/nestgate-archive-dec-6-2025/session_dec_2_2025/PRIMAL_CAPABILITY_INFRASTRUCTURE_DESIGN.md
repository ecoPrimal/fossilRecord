# 🏗️ Primal Capability Infrastructure Design

**Created**: December 2, 2025  
**Priority**: 🔴 CRITICAL - Required for spec compliance  
**Target**: Week 2 design, Week 3-5 implementation

---

## 🎯 PURPOSE

Design and implement a capability-based service discovery system to replace **1,263 hardcoded primal name references** that violate the "Zero Hardcoding" principle from `PRIMAL_ECOSYSTEM_INTEGRATION_SPEC.md`.

---

## ❌ CURRENT PROBLEM

### Hardcoded Primal Names (1,263 instances)
```rust
// ❌ VIOLATES SPECIFICATION
if service_name == "beardog" {
    // Security operations
}

if primal == "songbird" {
    // Networking operations
}

let client = connect_to("squirrel", port);
```

### Why This Is Critical
1. ❌ **Violates Core Specification**: Breaks "Zero Hardcoding" principle
2. ❌ **Vendor Lock-in**: Hardcodes specific primal names
3. ❌ **No Flexibility**: Can't swap implementations
4. ❌ **Breaks Sovereignty**: Couples to specific vendors
5. ❌ **Prevents Innovation**: Can't add new primals dynamically

---

## ✅ SOLUTION: CAPABILITY-BASED DISCOVERY

### Core Principle
**Discover services by WHAT THEY DO, not WHO THEY ARE**

```rust
// ✅ SPECIFICATION COMPLIANT
if service.has_capability("security") {
    // Security operations
}

if service.provides("networking.tcp") {
    // Networking operations
}

let client = discovery.connect_by_capability("ai.inference")?;
```

---

## 🏗️ ARCHITECTURE DESIGN

### Component Overview

```
┌─────────────────────────────────────────────────┐
│         Capability Discovery System             │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌──────────────────┐    ┌──────────────────┐ │
│  │ Capability       │    │  Service         │ │
│  │ Registry         │◄───┤  Detection       │ │
│  │                  │    │  Engine          │ │
│  └────────┬─────────┘    └──────────────────┘ │
│           │                                    │
│           ▼                                    │
│  ┌──────────────────┐    ┌──────────────────┐ │
│  │ Service          │    │  Connection      │ │
│  │ Resolver         │───►│  Manager         │ │
│  │                  │    │                  │ │
│  └──────────────────┘    └──────────────────┘ │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## 📋 COMPONENT SPECIFICATIONS

### 1. Capability Registry

**Purpose**: Central registry of all service capabilities

```rust
/// Capability registry for service discovery
pub struct CapabilityRegistry {
    /// Registered capabilities and their providers
    capabilities: Arc<RwLock<HashMap<Capability, Vec<ServiceDescriptor>>>>,
    
    /// Capability taxonomy (hierarchy)
    taxonomy: Arc<CapabilityTaxonomy>,
}

impl CapabilityRegistry {
    /// Register a service with its capabilities
    pub fn register_service(&self, service: ServiceDescriptor) -> Result<()> {
        for capability in &service.capabilities {
            self.capabilities
                .write()
                .await
                .entry(capability.clone())
                .or_insert_with(Vec::new)
                .push(service.clone());
        }
        Ok(())
    }
    
    /// Find services providing a capability
    pub fn find_providers(&self, capability: &Capability) -> Vec<ServiceDescriptor> {
        self.capabilities
            .read()
            .await
            .get(capability)
            .cloned()
            .unwrap_or_default()
    }
    
    /// Check if capability is available
    pub fn has_capability(&self, capability: &Capability) -> bool {
        self.capabilities
            .read()
            .await
            .contains_key(capability)
    }
}
```

### 2. Service Detection Engine

**Purpose**: Auto-discover services and their capabilities

```rust
/// Service detection engine for capability discovery
pub struct ServiceDetectionEngine {
    /// Discovery configuration
    config: DiscoveryConfig,
    
    /// Registry to populate
    registry: Arc<CapabilityRegistry>,
    
    /// Active detection tasks
    tasks: Vec<JoinHandle<()>>,
}

impl ServiceDetectionEngine {
    /// Start continuous service detection
    pub async fn start(&mut self) -> Result<()> {
        // Scan configured ports/endpoints
        for endpoint in &self.config.discovery.port_range {
            let task = self.probe_endpoint(endpoint).await?;
            self.tasks.push(task);
        }
        Ok(())
    }
    
    /// Probe an endpoint for capabilities
    async fn probe_endpoint(&self, endpoint: &Endpoint) -> Result<ServiceDescriptor> {
        // HTTP/gRPC/custom protocol capability probe
        let response = self.send_capability_query(endpoint).await?;
        
        Ok(ServiceDescriptor {
            name: response.service_name,
            capabilities: response.capabilities,
            endpoint: endpoint.clone(),
            metadata: response.metadata,
        })
    }
    
    /// Query service for its capabilities
    async fn send_capability_query(&self, endpoint: &Endpoint) -> Result<CapabilityResponse> {
        // Try multiple protocols
        if let Ok(response) = self.try_http_capability(endpoint).await {
            return Ok(response);
        }
        if let Ok(response) = self.try_grpc_capability(endpoint).await {
            return Ok(response);
        }
        // Custom primal protocol
        self.try_primal_protocol(endpoint).await
    }
}
```

### 3. Capability Taxonomy

**Purpose**: Hierarchical capability organization

```rust
/// Capability taxonomy for structured discovery
#[derive(Debug, Clone)]
pub enum Capability {
    // Security capabilities
    Security(SecurityCapability),
    
    // Networking capabilities
    Networking(NetworkingCapability),
    
    // AI capabilities
    AI(AICapability),
    
    // Orchestration capabilities
    Orchestration(OrchestrationCapability),
    
    // Storage capabilities
    Storage(StorageCapability),
    
    // Custom capabilities
    Custom(String),
}

#[derive(Debug, Clone)]
pub enum SecurityCapability {
    Authentication,
    Authorization,
    Encryption,
    KeyManagement,
    ThreatDetection,
    AuditLogging,
}

#[derive(Debug, Clone)]
pub enum NetworkingCapability {
    TCP,
    UDP,
    HTTP,
    WebSocket,
    gRPC,
    LoadBalancing,
    ServiceMesh,
}

#[derive(Debug, Clone)]
pub enum AICapability {
    Inference,
    Training,
    ModelServing,
    FeatureExtraction,
    NaturalLanguage,
    ComputerVision,
}

#[derive(Debug, Clone)]
pub enum OrchestrationCapability {
    ContainerManagement,
    ServiceScheduling,
    ResourceAllocation,
    HealthMonitoring,
    AutoScaling,
}
```

### 4. Service Descriptor

**Purpose**: Describe a discovered service

```rust
/// Service descriptor for capability-based discovery
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ServiceDescriptor {
    /// Service identifier (generated, not hardcoded)
    pub id: Uuid,
    
    /// Service name (for logging only, not used for discovery)
    pub name: String,
    
    /// Capabilities provided by this service
    pub capabilities: Vec<Capability>,
    
    /// Endpoint information
    pub endpoint: Endpoint,
    
    /// Service metadata
    pub metadata: ServiceMetadata,
    
    /// Health status
    pub health: ServiceHealth,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Endpoint {
    pub host: String,
    pub port: u16,
    pub protocol: Protocol,
    pub tls: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ServiceMetadata {
    pub version: String,
    pub uptime: Duration,
    pub load: f64,
    pub tags: HashMap<String, String>,
}
```

### 5. Service Resolver

**Purpose**: Resolve capabilities to service connections

```rust
/// Service resolver for capability-based connections
pub struct ServiceResolver {
    registry: Arc<CapabilityRegistry>,
    connection_pool: Arc<ConnectionPool>,
    load_balancer: Arc<LoadBalancer>,
}

impl ServiceResolver {
    /// Connect to a service by capability
    pub async fn connect_by_capability(
        &self,
        capability: &Capability,
    ) -> Result<ServiceConnection> {
        // Find all providers
        let providers = self.registry.find_providers(capability).await;
        
        if providers.is_empty() {
            return Err(Error::NoProviderFound(capability.clone()));
        }
        
        // Load balance across providers
        let selected = self.load_balancer.select(&providers).await?;
        
        // Get or create connection
        self.connection_pool.get_connection(&selected).await
    }
    
    /// Find best provider for capability
    pub async fn find_best_provider(
        &self,
        capability: &Capability,
        criteria: &SelectionCriteria,
    ) -> Result<ServiceDescriptor> {
        let providers = self.registry.find_providers(capability).await;
        
        // Apply selection criteria
        self.select_by_criteria(providers, criteria).await
    }
}
```

---

## 🔄 MIGRATION STRATEGY

### Phase 1: Infrastructure (Week 2)
**Goal**: Build core capability system

**Tasks**:
1. [ ] Implement `CapabilityRegistry`
2. [ ] Implement `ServiceDetectionEngine`
3. [ ] Define `Capability` taxonomy
4. [ ] Implement `ServiceDescriptor`
5. [ ] Create unit tests

**Deliverables**:
- Core capability infrastructure (1,000 LOC)
- Comprehensive tests
- API documentation

---

### Phase 2: Detection (Week 3)
**Goal**: Auto-discover primal services

**Tasks**:
1. [ ] Implement HTTP capability probe
2. [ ] Implement gRPC capability probe
3. [ ] Implement custom primal protocol
4. [ ] Add continuous discovery
5. [ ] Add health monitoring

**Deliverables**:
- Working service detection
- Multiple protocol support
- Health tracking

---

### Phase 3: Migration (Week 4-5)
**Goal**: Replace all hardcoded names

**Tasks**:
1. [ ] Migrate security operations (beardog → capability)
2. [ ] Migrate networking operations (songbird → capability)
3. [ ] Migrate AI operations (squirrel/toadstool → capability)
4. [ ] Update all tests
5. [ ] Update all documentation

**Deliverables**:
- Zero hardcoded primal names
- All operations capability-based
- Specification compliant

---

### Phase 4: Verification (Week 6)
**Goal**: Validate compliance

**Tasks**:
1. [ ] Verify zero primal names: `rg -i "beardog|songbird|squirrel|toadstool" = 0`
2. [ ] Test multi-provider scenarios
3. [ ] Test dynamic provider swapping
4. [ ] Performance testing
5. [ ] Documentation review

---

## 📝 MIGRATION EXAMPLES

### Security Operations

#### Before (Hardcoded)
```rust
// ❌ VIOLATES SPEC
pub async fn authenticate_user(primal: &str, user: &User) -> Result<Token> {
    if primal == "beardog" {
        let client = connect_to_beardog().await?;
        client.authenticate(user).await
    } else {
        Err(Error::UnsupportedPrimal)
    }
}
```

#### After (Capability-Based)
```rust
// ✅ SPECIFICATION COMPLIANT
pub async fn authenticate_user(
    resolver: &ServiceResolver,
    user: &User,
) -> Result<Token> {
    let client = resolver
        .connect_by_capability(&Capability::Security(
            SecurityCapability::Authentication
        ))
        .await?;
    
    client.authenticate(user).await
}
```

---

### Networking Operations

#### Before (Hardcoded)
```rust
// ❌ VIOLATES SPEC
pub async fn send_message(target: &str, message: &Message) -> Result<()> {
    if target == "songbird" {
        let client = connect_songbird().await?;
        client.send(message).await
    } else {
        Err(Error::UnsupportedTarget)
    }
}
```

#### After (Capability-Based)
```rust
// ✅ SPECIFICATION COMPLIANT
pub async fn send_message(
    resolver: &ServiceResolver,
    message: &Message,
) -> Result<()> {
    let client = resolver
        .connect_by_capability(&Capability::Networking(
            NetworkingCapability::TCP
        ))
        .await?;
    
    client.send(message).await
}
```

---

### AI Operations

#### Before (Hardcoded)
```rust
// ❌ VIOLATES SPEC
pub async fn run_inference(model_name: &str, input: &Tensor) -> Result<Tensor> {
    let ai_service = match env::var("AI_PRIMAL") {
        Ok(primal) if primal == "squirrel" => connect_squirrel().await?,
        Ok(primal) if primal == "toadstool" => connect_toadstool().await?,
        _ => return Err(Error::NoAIService),
    };
    
    ai_service.infer(model_name, input).await
}
```

#### After (Capability-Based)
```rust
// ✅ SPECIFICATION COMPLIANT
pub async fn run_inference(
    resolver: &ServiceResolver,
    model_name: &str,
    input: &Tensor,
) -> Result<Tensor> {
    // Find best AI inference provider
    let client = resolver
        .find_best_provider(
            &Capability::AI(AICapability::Inference),
            &SelectionCriteria {
                min_gpu_memory: Some(8_000_000_000), // 8GB
                prefer_low_latency: true,
                max_cost_per_hour: Some(1.0),
            },
        )
        .await?;
    
    client.infer(model_name, input).await
}
```

---

## 🧪 TESTING STRATEGY

### Unit Tests
```rust
#[cfg(test)]
mod tests {
    use super::*;
    
    #[tokio::test]
    async fn test_capability_registration() {
        let registry = CapabilityRegistry::new();
        
        let service = ServiceDescriptor {
            id: Uuid::new_v4(),
            name: "test-security-service".to_string(),
            capabilities: vec![
                Capability::Security(SecurityCapability::Authentication),
                Capability::Security(SecurityCapability::Encryption),
            ],
            endpoint: Endpoint {
                host: "localhost".to_string(),
                port: 8443,
                protocol: Protocol::HTTPS,
                tls: true,
            },
            metadata: ServiceMetadata::default(),
            health: ServiceHealth::Healthy,
        };
        
        registry.register_service(service.clone()).await.unwrap();
        
        let providers = registry
            .find_providers(&Capability::Security(SecurityCapability::Authentication))
            .await;
        
        assert_eq!(providers.len(), 1);
        assert_eq!(providers[0].id, service.id);
    }
    
    #[tokio::test]
    async fn test_no_hardcoded_names() {
        // Verify we can discover and connect without knowing names
        let resolver = ServiceResolver::new();
        
        // Should work regardless of which service provides capability
        let conn = resolver
            .connect_by_capability(&Capability::Security(
                SecurityCapability::Authentication
            ))
            .await;
        
        assert!(conn.is_ok());
        // We don't care WHICH service answered, just that it has the capability
    }
}
```

---

## ✅ SUCCESS CRITERIA

### Must Achieve
- [ ] Zero hardcoded primal names (0/1,263)
- [ ] All operations capability-based
- [ ] Specification compliant
- [ ] Multi-provider support
- [ ] Dynamic service discovery
- [ ] Load balancing across providers

### Should Achieve
- [ ] <10ms capability lookup
- [ ] <100ms service connection
- [ ] Automatic failover
- [ ] Health monitoring
- [ ] Metrics collection

### Nice to Have
- [ ] Plugin system for new capabilities
- [ ] WebAssembly primal support
- [ ] Cross-cluster discovery
- [ ] Capability versioning

---

## 📊 IMPLEMENTATION TIMELINE

```
Week 2 (Dec 9-13):  Infrastructure design ✅
                    Core components implemented
                    Unit tests complete
                    
Week 3 (Dec 16-20): Service detection working
                    HTTP/gRPC probes complete
                    Continuous discovery active
                    
Week 4 (Dec 23-27): Migration phase 1
                    Security operations migrated (316 instances)
                    Networking operations migrated (316 instances)
                    
Week 5 (Dec 30-Jan 3): Migration phase 2
                       AI operations migrated (631 instances)
                       All tests updated
                       Documentation complete
                       
Week 6 (Jan 6-10):  Verification & polish
                    Zero hardcoded names confirmed
                    Performance validated
                    Specification compliance verified
```

---

## 🚨 RISK MITIGATION

### Risk: Complex Migration
**Mitigation**: Incremental migration, keep deprecated code during transition

### Risk: Performance Impact
**Mitigation**: Cache capability lookups, connection pooling, benchmarking

### Risk: Breaking Changes
**Mitigation**: Compatibility layer, deprecation warnings, migration guide

### Risk: Unknown Primal Protocols
**Mitigation**: Protocol negotiation, fallback mechanisms, documentation

---

## 📚 REFERENCES

- `specs/PRIMAL_ECOSYSTEM_INTEGRATION_SPEC.md` - Core specification
- `HARDCODING_MIGRATION_TRACKER.md` - Overall migration plan
- `code/crates/nestgate-core/src/universal_adapter/` - Existing adapter code
- `code/crates/nestgate-core/src/capabilities/` - Capability taxonomy

---

**Status**: 📋 Design Complete, Ready for Implementation  
**Priority**: 🔴 CRITICAL - Specification Compliance  
**Timeline**: Weeks 2-6  
**Impact**: +10 points to grade (specification compliance)

---

*Capability-based discovery: The heart of true vendor independence.* 🎯

