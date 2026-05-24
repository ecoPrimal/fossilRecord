# 🎯 mDNS Implementation Plan - December 4, 2025

**Status**: Ready to implement  
**Priority**: HIGH  
**Effort**: 8-16 hours  
**Impact**: Enables real zero-config local discovery

---

## 📋 IMPLEMENTATION CHECKLIST

### Phase 1: Research & Dependency Selection ✅

**Options Evaluated**:
1. **mdns-sd** (0.10) - Pure Rust, well-maintained ⭐ RECOMMENDED
2. **zeroconf** (0.12) - Higher-level, platform-specific
3. **mdns** (3.0) - Lower-level, more control

**Decision**: Use `mdns-sd` for pure Rust implementation

---

## 🚀 IMPLEMENTATION PLAN

### Step 1: Add Dependency

```toml
# code/crates/nestgate-core/Cargo.toml
[dependencies]
mdns-sd = "0.10"
```

### Step 2: Update mDNS Backend Structure

Current stub methods need real implementation:
- `announce()` - Register service via mDNS
- `find_by_capability()` - Query for services
- `query()` - Advanced queries
- `unannounce()` - Deregister on shutdown

### Step 3: Implementation Approach

**Key Design Decisions**:
1. **Service Naming**: Use capability-based service types
   - Format: `_<capability>._tcp.local.`
   - Example: `_zfs-storage._tcp.local.`

2. **TXT Records**: Embed metadata
   - `id=<primal-id>`
   - `port=<port>`
   - `capabilities=<cap1,cap2,...>`
   - `health=<healthy|degraded|unhealthy>`

3. **Discovery**: Time-bounded queries
   - Default timeout: 5 seconds
   - Collect all responses
   - Return as PeerDescriptor list

---

## 💻 REAL IMPLEMENTATION

### Current Stub (Line ~195-210):
```rust
async fn announce(&self, knowledge: &PrimalSelfKnowledge) -> Result<()> {
    // TODO: Actual mDNS announcement implementation
    self.cleanup_stale().await;
    
    // ... stub logic ...
    
    info!("Would announce via mDNS: {:?}", knowledge);
    Ok(())
}
```

### Real Implementation:

```rust
use mdns_sd::{ServiceDaemon, ServiceInfo, IfKind};
use std::collections::HashMap;

// Add to struct
pub struct MdnsDiscoveryBackend {
    service_name: String,
    peer_cache: Arc<RwLock<HashMap<PrimalId, CachedPeer>>>,
    config: MdnsConfig,
    mdns_daemon: Arc<RwLock<Option<ServiceDaemon>>>, // NEW
}

impl MdnsDiscoveryBackend {
    // Initialize mDNS daemon
    async fn get_or_create_daemon(&self) -> Result<ServiceDaemon> {
        let mut daemon_lock = self.mdns_daemon.write().await;
        
        if let Some(daemon) = daemon_lock.as_ref() {
            return Ok(daemon.clone());
        }
        
        let daemon = ServiceDaemon::new()
            .map_err(|e| NestGateError::internal(
                format!("Failed to create mDNS daemon: {e}")
            ))?;
        
        *daemon_lock = Some(daemon.clone());
        Ok(daemon)
    }
    
    // Real announce implementation
    async fn announce(&self, knowledge: &PrimalSelfKnowledge) -> Result<()> {
        self.cleanup_stale().await;
        
        let daemon = self.get_or_create_daemon().await?;
        
        // Build service type from first capability
        let service_type = if !knowledge.capabilities.is_empty() {
            self.service_name_for_capability(&knowledge.capabilities[0])
        } else {
            format!("_nestgate._tcp.local.")
        };
        
        // Create TXT records with metadata
        let txt_records = self.binding_to_txt_records(knowledge);
        let txt_map: HashMap<String, String> = txt_records
            .into_iter()
            .filter_map(|record| {
                let parts: Vec<&str> = record.splitn(2, '=').collect();
                if parts.len() == 2 {
                    Some((parts[0].to_string(), parts[1].to_string()))
                } else {
                    None
                }
            })
            .collect();
        
        // Create service info
        let host_name = format!("{}.local.", self.service_name);
        let service_info = ServiceInfo::new(
            &service_type,
            &knowledge.id.as_str(),
            &host_name,
            "",
            knowledge.binding.port,
            txt_map.as_ref(),
        ).map_err(|e| NestGateError::internal(
            format!("Failed to create service info: {e}")
        ))?;
        
        // Register service
        daemon.register(service_info)
            .map_err(|e| NestGateError::internal(
                format!("Failed to register mDNS service: {e}")
            ))?;
        
        info!(
            "✅ Announced {} via mDNS on port {} with capabilities: {:?}",
            knowledge.id.as_str(),
            knowledge.binding.port,
            knowledge.capabilities
        );
        
        Ok(())
    }
    
    // Real find_by_capability implementation
    async fn find_by_capability(
        &self,
        capability: &PrimalCapability,
    ) -> Result<Vec<PeerDescriptor>> {
        self.cleanup_stale().await;
        
        let daemon = self.get_or_create_daemon().await?;
        let service_type = self.service_name_for_capability(capability);
        
        debug!("🔍 Querying mDNS for capability: {:?} (type: {})", 
            capability, service_type);
        
        // Browse for services
        let receiver = daemon.browse(&service_type)
            .map_err(|e| NestGateError::internal(
                format!("Failed to browse mDNS: {e}")
            ))?;
        
        let timeout = tokio::time::sleep(self.config.query_timeout);
        tokio::pin!(timeout);
        
        let mut peers = Vec::new();
        
        // Collect services with timeout
        loop {
            tokio::select! {
                event = receiver.recv_async() => {
                    match event {
                        Ok(mdns_sd::ServiceEvent::ServiceResolved(info)) => {
                            if let Some(peer) = self.parse_service_info(info) {
                                debug!("📡 Found peer via mDNS: {}", peer.id.as_str());
                                peers.push(peer);
                            }
                        }
                        Ok(_) => continue,
                        Err(e) => {
                            warn!("mDNS receive error: {e}");
                            break;
                        }
                    }
                }
                _ = &mut timeout => {
                    debug!("⏱️  mDNS query timeout reached, found {} peers", peers.len());
                    break;
                }
            }
        }
        
        Ok(peers)
    }
    
    // Parse ServiceInfo to PeerDescriptor
    fn parse_service_info(&self, info: ServiceInfo) -> Option<PeerDescriptor> {
        let properties = info.get_properties();
        
        // Extract ID from TXT records
        let id_str = properties.get("id")?;
        let id = PrimalId(id_str.val_str().to_string());
        
        // Extract capabilities
        let caps_str = properties.get("capabilities")
            .map(|v| v.val_str())
            .unwrap_or("");
        let capabilities: Vec<PrimalCapability> = caps_str
            .split(',')
            .filter_map(|s| self.parse_capability(s))
            .collect();
        
        // Extract health
        let health_str = properties.get("health")
            .map(|v| v.val_str())
            .unwrap_or("healthy");
        let health = match health_str {
            "healthy" => HealthStatus::Healthy,
            "degraded" => HealthStatus::Degraded { 
                reason: "Reported as degraded".to_string() 
            },
            _ => HealthStatus::Unhealthy { 
                reason: "Reported as unhealthy".to_string() 
            },
        };
        
        // Get address and port
        let addresses = info.get_addresses();
        let address = addresses.iter().next()?.clone();
        let port = info.get_port();
        
        Some(PeerDescriptor {
            id,
            capabilities,
            endpoint: ServiceEndpoint {
                address,
                port,
            },
            health,
            last_seen: SystemTime::now(),
            metadata: HashMap::new(),
        })
    }
    
    // Helper to parse capability strings
    fn parse_capability(&self, s: &str) -> Option<PrimalCapability> {
        match s.trim() {
            "zfs-storage" => Some(PrimalCapability::ZfsStorage),
            "api-gateway" => Some(PrimalCapability::ApiGateway),
            "service-discovery" => Some(PrimalCapability::ServiceDiscovery),
            "observability" => Some(PrimalCapability::Observability),
            "authentication" => Some(PrimalCapability::Authentication),
            "data-sync" => Some(PrimalCapability::DataSync),
            _ if s.starts_with("nfs-") => Some(PrimalCapability::NetworkFileSystem(
                NfsVersion::V4
            )),
            _ => Some(PrimalCapability::Custom(s.to_string())),
        }
    }
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
    async fn test_mdns_announcement() {
        let backend = MdnsDiscoveryBackend::new();
        let knowledge = create_test_knowledge();
        
        let result = backend.announce(&knowledge).await;
        assert!(result.is_ok(), "Announcement should succeed");
    }
    
    #[tokio::test]
    async fn test_mdns_discovery() {
        let backend = MdnsDiscoveryBackend::new();
        
        // Announce a test service
        let knowledge = create_test_knowledge();
        backend.announce(&knowledge).await.unwrap();
        
        // Give mDNS time to propagate
        tokio::time::sleep(Duration::from_millis(500)).await;
        
        // Try to find it
        let peers = backend
            .find_by_capability(&PrimalCapability::ZfsStorage)
            .await
            .unwrap();
        
        assert!(!peers.is_empty(), "Should find at least one peer");
    }
}
```

### Integration Tests

```rust
// tests/integration/mdns_discovery_integration.rs

#[tokio::test]
async fn test_cross_primal_discovery() {
    // Start two primals
    let primal1 = start_test_primal("primal1", vec![
        PrimalCapability::ZfsStorage
    ]).await;
    
    let primal2 = start_test_primal("primal2", vec![
        PrimalCapability::ApiGateway
    ]).await;
    
    // Wait for mDNS propagation
    tokio::time::sleep(Duration::from_secs(2)).await;
    
    // Primal1 should find Primal2
    let found = primal1.discover_capability(
        &PrimalCapability::ApiGateway
    ).await.unwrap();
    
    assert_eq!(found.len(), 1);
    assert_eq!(found[0].id.as_str(), "primal2");
}
```

---

## ⚠️ LIMITATIONS & CONSIDERATIONS

### Network Requirements
- **Local Network Only**: mDNS works on local subnet
- **Multicast Support**: Network must support multicast (not all do)
- **Firewall**: UDP port 5353 must be open

### When NOT to Use mDNS
- ❌ Cross-datacenter discovery → Use Consul
- ❌ Kubernetes clusters → Use K8s service discovery
- ❌ Production internet-facing → Use DNS-based discovery

### When mDNS is Perfect
- ✅ Local development
- ✅ Home labs
- ✅ Edge computing
- ✅ IoT devices
- ✅ Zero-config scenarios

---

## 📝 DOCUMENTATION UPDATES

### User Guide

```markdown
## Local Discovery with mDNS

NestGate supports zero-configuration service discovery on local networks
using multicast DNS (mDNS).

### Automatic Discovery

No configuration needed! Just start multiple NestGate instances:

```bash
# Terminal 1: Start with ZFS capability
NESTGATE_CAPABILITIES=zfs-storage cargo run

# Terminal 2: Start with API capability  
NESTGATE_CAPABILITIES=api-gateway cargo run
```

They'll automatically discover each other!

### Requirements

- Local network with multicast support
- UDP port 5353 open
- Avahi (Linux) or Bonjour (macOS/Windows) daemon running
```

---

## 🎯 SUCCESS CRITERIA

- [ ] Dependency added and compiling
- [ ] Real mDNS announcement working
- [ ] Real mDNS query working
- [ ] Unit tests passing
- [ ] Integration tests passing
- [ ] Documentation updated
- [ ] Example working in dev environment

---

## 📊 ESTIMATED TIMELINE

**Phase 1** (2-3 hours): Dependency + basic structure  
**Phase 2** (3-4 hours): Announcement implementation  
**Phase 3** (2-3 hours): Discovery implementation  
**Phase 4** (1-2 hours): Testing  
**Phase 5** (1-2 hours): Documentation  

**Total**: 8-14 hours

---

**Status**: 📋 READY TO IMPLEMENT  
**Next Step**: Add mdns-sd dependency  
**Blocked By**: Nothing - ready to start!


