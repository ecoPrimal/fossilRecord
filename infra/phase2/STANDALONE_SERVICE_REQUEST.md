# 🌱 Request: Standalone Service Binaries for RhizoCrypt & LoamSpine

**Date**: December 26, 2025  
**From**: BiomeOS Phase 2 Integration Team  
**To**: RhizoCrypt & LoamSpine Core Teams  

---

## 📋 TL;DR

Your primals have excellent RPC server infrastructure but no standalone service binaries. We'd like you to add simple `main.rs` entry points so BiomeOS can discover and coordinate you as sovereign primals, not just embedded libraries.

---

## 🎯 Current State

**What You Have** ✅
- **RhizoCrypt**: Full tarpc RPC server with 24 methods, rate limiting, metrics
- **LoamSpine**: Full tarpc RPC server with 18 methods, dual protocol (tarpc + JSON-RPC)
- **Both**: Excellent showcase scripts, comprehensive RPC infrastructure

**What's Missing** ❌
- No standalone service binary (no `src/main.rs` + `[[bin]]` in root `Cargo.toml`)
- Currently library-only → can't be deployed/coordinated independently

---

## 🌟 Why This Matters

### Primal Philosophy
> "Primals are FULLY STANDALONE, sovereign agents.  
> BiomeOS discovers and coordinates them through capabilities.  
> Tight coupling and chimeras are BiomeOS's job, not the primal's."

### Current Problem
- You're library-first (embedded into other primals)
- BiomeOS can't discover/coordinate you independently
- Can't be deployed as separate services
- Can't appear in capability-based discovery

### The Gap
Phase 1 primals (beardog, nestgate, songbird, squirrel, toadstool) are all standalone services. Phase 2 primals should be too!

---

## 💡 Proposed Solution: Dual-Mode Design

Support **both** library mode AND service mode:

### Library Mode (Keep This)
```rust
// Other primals embed you directly
use rhizo_crypt_core::RhizoCrypt;
let dag = RhizoCrypt::new();
```

### Service Mode (Add This)
```bash
# BiomeOS coordinates you as external service
./rhizocrypt-service --port 9400 &
./loamspine-service --port 9500 &
```

**No breaking changes** - just add the standalone binary wrapper!

---

## 📋 What We're Asking

### For RhizoCrypt Team

1. Create `src/main.rs`:
```rust
//! RhizoCrypt Standalone Service
use rhizo_crypt_rpc::RpcServer;
use rhizo_crypt_core::RhizoCrypt;
use std::sync::Arc;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    tracing_subscriber::fmt::init();
    
    let port = std::env::var("RHIZOCRYPT_PORT")
        .unwrap_or_else(|_| "9400".to_string())
        .parse()?;
    
    let primal = Arc::new(RhizoCrypt::new());
    let addr = format!("0.0.0.0:{}", port).parse()?;
    let server = RpcServer::new(primal, addr);
    
    println!("🔐 RhizoCrypt service listening on {}", addr);
    server.serve().await?;
    
    Ok(())
}
```

2. Add to root `Cargo.toml`:
```toml
[[bin]]
name = "rhizocrypt-service"
path = "src/main.rs"
```

3. Build: `cargo build --release`
4. Result: `target/release/rhizocrypt-service`

### For LoamSpine Team

1. Create `src/main.rs`:
```rust
//! LoamSpine Standalone Service
use loam_spine_api::{LoamSpineTarpcServer, LoamSpineRpcService};
use std::net::SocketAddr;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    tracing_subscriber::fmt::init();
    
    let port = std::env::var("LOAMSPINE_PORT")
        .unwrap_or_else(|_| "9500".to_string())
        .parse()?;
    
    let service = LoamSpineRpcService::default_service();
    let server = LoamSpineTarpcServer::new(service);
    let addr: SocketAddr = format!("0.0.0.0:{}", port).parse()?;
    
    println!("🦴 LoamSpine service listening on {}", addr);
    // Your existing server.serve(addr) logic here
    
    Ok(())
}
```

2. Add to root `Cargo.toml`:
```toml
[[bin]]
name = "loamspine-service"
path = "src/main.rs"
```

3. Build: `cargo build --release`
4. Result: `target/release/loamspine-service`

---

## 🎁 What You Get

1. **BiomeOS Integration**: Discoverable via Songbird capability-based discovery
2. **Standalone Deployment**: Deploy independently, scale separately
3. **Showcase Value**: "Look, it's a real service, not just a library!"
4. **Flexibility**: Users choose library OR service mode
5. **Phase 2 Consistency**: All Phase 2 primals (rhizoCrypt, loamSpine, sweetGrass) as services

---

## 🚀 Impact

### Before (Library-Only)
```
BiomeOS can coordinate:
  • beardog, nestgate, songbird, squirrel, toadstool (5 primals)
```

### After (Dual-Mode)
```
BiomeOS can coordinate:
  • beardog, nestgate, songbird, squirrel, toadstool (Phase 1)
  • rhizocrypt, loamspine, sweetgrass (Phase 2)
  = 8 total primals! 🌸
```

---

## 📊 Effort Estimate

- **Time**: ~30 minutes per primal
- **Complexity**: Trivial (wrap existing server in `main.rs`)
- **Risk**: Zero (no changes to core libraries)
- **Breaking Changes**: None

---

## 🙏 Request

Could you add standalone service binaries to your next release?

Your RPC infrastructure is **excellent** - we just need the entry point! The `main.rs` examples above should be 90% of what you need.

---

## 📞 Questions?

We're happy to:
- Provide more detailed examples
- Test the binaries
- Help with integration testing
- Add to BiomeOS showcase demos

Let us know how we can help!

---

**Thank you for building foundational Phase 2 infrastructure!** 🌱

BiomeOS Team
