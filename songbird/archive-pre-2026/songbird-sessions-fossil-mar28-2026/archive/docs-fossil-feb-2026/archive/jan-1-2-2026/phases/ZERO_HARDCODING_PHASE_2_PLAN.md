# 🎯 Zero Hardcoding Migration - Phase 2 Plan

**Date**: January 1, 2026  
**Status**: PLANNED - Ready for Execution  
**Prerequisite**: ✅ Phase 1 Complete (Primal name hardcoding eliminated)  
**Estimated Effort**: 4-6 hours

---

## 📊 Scanning Results

### Hardcoding Inventory:

| Type | Count | Files | Priority |
|------|-------|-------|----------|
| `localhost:[port]` | 1,536 | 324 files | **HIGH** |
| `:8[0-9]{3}` (8000-8999 ports) | 808 | 180 files | **HIGH** |
| `Duration::from_secs([0-9])` | 1,145 | 261 files | **MEDIUM** |
| `192.168.*` (private IPs) | 939 | 247 files | **MEDIUM** |
| `127.0.0.1:[port]` | 109 | 51 files | **LOW** (subset of localhost) |

### High-Impact Files (Most Hardcoding):

1. **Test Files** (60% of matches) - Test fixtures, integration tests
2. **Configuration** (~20%) - Default configs, constants
3. **Examples/Showcase** (~15%) - Demo scripts, documentation
4. **Production Code** (~5%) - Actual runtime code

---

## 🎯 Strategy

### Phase 2A: Environment-Driven Configuration (2 hours)

**Goal**: Replace all hardcoded ports/IPs with environment variables

**Approach**:
```rust
// Before
let endpoint = "http://localhost:9000";

// After
let endpoint = std::env::var("SECURITY_ENDPOINT")
    .unwrap_or_else(|_| "http://127.0.0.1:0".to_string()); // port 0 = auto-select
```

**Key Modules to Update**:
1. `crates/songbird-config/src/canonical/constants.rs`
2. `crates/songbird-config/src/defaults/endpoints.rs`
3. `crates/songbird-types/src/constants.rs`
4. `crates/songbird-config/src/config/constants.rs`

### Phase 2B: Intelligent Port Selection (1.5 hours)

**Goal**: Auto-select available ports (port 0 magic)

**Implementation**:
```rust
pub struct EndpointConfig {
    /// Port (0 = auto-select first available)
    pub port: u16,
    
    /// Bind address (empty = all interfaces)
    pub bind_addr: String,
}

impl Default for EndpointConfig {
    fn default() -> Self {
        Self {
            port: std::env::var("PORT")
                .ok()
                .and_then(|p| p.parse().ok())
                .unwrap_or(0), // Auto-select!
            bind_addr: std::env::var("BIND_ADDR")
                .unwrap_or_else(|_| "0.0.0.0".to_string()),
        }
    }
}
```

**Benefits**:
- No port conflicts
- Works in any environment
- Cloud-native (let orchestrator assign)

### Phase 2C: Timeout Configuration (1 hour)

**Goal**: Replace hardcoded timeouts with configurable durations

**Implementation**:
```rust
pub struct TimeoutConfig {
    /// Connection timeout (default: 10s)
    pub connect: Duration,
    
    /// Request timeout (default: 30s)
    pub request: Duration,
    
    /// Idle timeout (default: 60s)
    pub idle: Duration,
}

impl TimeoutConfig {
    pub fn from_env() -> Self {
        Self {
            connect: Self::parse_duration_env("TIMEOUT_CONNECT", 10),
            request: Self::parse_duration_env("TIMEOUT_REQUEST", 30),
            idle: Self::parse_duration_env("TIMEOUT_IDLE", 60),
        }
    }
    
    fn parse_duration_env(key: &str, default_secs: u64) -> Duration {
        std::env::var(key)
            .ok()
            .and_then(|v| v.parse().ok())
            .map(Duration::from_secs)
            .unwrap_or_else(|| Duration::from_secs(default_secs))
    }
}
```

### Phase 2D: Test Infrastructure (1.5 hours)

**Goal**: Update test fixtures to use dynamic configuration

**Approach**:
```rust
// Test helper
pub fn test_endpoint() -> String {
    // Use ephemeral port for tests
    format!("http://127.0.0.1:{}", allocate_test_port())
}

pub fn allocate_test_port() -> u16 {
    // Bind to port 0, get assigned port, close, return
    let listener = std::net::TcpListener::bind("127.0.0.1:0").unwrap();
    let port = listener.local_addr().unwrap().port();
    drop(listener);
    port
}
```

---

## 📋 Execution Plan

### Step 1: Create Configuration Modules (30 min)

**Files to Create**:
1. `crates/songbird-config/src/zero_hardcoding/endpoints.rs`
2. `crates/songbird-config/src/zero_hardcoding/timeouts.rs`
3. `crates/songbird-config/src/zero_hardcoding/mod.rs`

**Content**:
```rust
// endpoints.rs
pub struct EndpointConfig {
    pub http_port: u16,
    pub rpc_port: u16,
    pub ws_port: u16,
    pub bind_addr: String,
}

impl EndpointConfig {
    pub fn from_env() -> Self {
        Self {
            http_port: Self::parse_port("HTTP_PORT", 0),
            rpc_port: Self::parse_port("RPC_PORT", 0),
            ws_port: Self::parse_port("WS_PORT", 0),
            bind_addr: std::env::var("BIND_ADDR")
                .unwrap_or_else(|_| "0.0.0.0".to_string()),
        }
    }
    
    fn parse_port(key: &str, default: u16) -> u16 {
        std::env::var(key)
            .ok()
            .and_then(|v| v.parse().ok())
            .unwrap_or(default)
    }
}
```

### Step 2: Update Constants Files (45 min)

**Replace in `crates/songbird-config/src/canonical/constants.rs`**:
```rust
// Before
pub const DEFAULT_HTTP_PORT: u16 = 8080;
pub const DEFAULT_RPC_PORT: u16 = 9000;

// After
pub fn default_http_port() -> u16 {
    std::env::var("HTTP_PORT")
        .ok()
        .and_then(|p| p.parse().ok())
        .unwrap_or(0) // Auto-select!
}

pub fn default_rpc_port() -> u16 {
    std::env::var("RPC_PORT")
        .ok()
        .and_then(|p| p.parse().ok())
        .unwrap_or(0) // Auto-select!
}
```

### Step 3: Update Production Code (1 hour)

**Target Files** (5% of matches, highest impact):
1. `crates/songbird-orchestrator/src/server/mod.rs`
2. `crates/songbird-orchestrator/src/rpc/tarpc_server.rs`
3. `crates/songbird-network-federation/src/btsp/provider.rs`
4. `crates/songbird-discovery/src/discovery/core.rs`
5. `crates/songbird-universal/src/unified_adapter.rs`

**Search & Replace Pattern**:
```bash
# Find hardcoded localhost:PORT
rg 'localhost:[0-9]{4}' --type rust

# Replace with dynamic endpoint
# From: "http://localhost:9000"
# To:   &discover_or_default_endpoint("security")
```

### Step 4: Update Test Infrastructure (1 hour)

**Create** `crates/songbird-test-utils/src/dynamic_ports.rs`:
```rust
use std::sync::Mutex;
use std::collections::HashSet;

lazy_static! {
    static ref ALLOCATED_PORTS: Mutex<HashSet<u16>> = Mutex::new(HashSet::new());
}

pub fn allocate_test_port() -> u16 {
    loop {
        let listener = std::net::TcpListener::bind("127.0.0.1:0").unwrap();
        let port = listener.local_addr().unwrap().port();
        drop(listener);
        
        let mut ports = ALLOCATED_PORTS.lock().unwrap();
        if !ports.contains(&port) {
            ports.insert(port);
            return port;
        }
    }
}

pub fn test_endpoint(protocol: &str) -> String {
    format!("{}://127.0.0.1:{}", protocol, allocate_test_port())
}
```

### Step 5: Update Documentation (30 min)

**Update**:
1. `README.md` - Add environment variable section
2. `docs/CONFIGURATION_GUIDE.md` - Document all env vars
3. `docs/DEPLOYMENT_GUIDE.md` - Update deployment examples

**Example Documentation**:
```markdown
## Environment Variables

### Endpoints
- `HTTP_PORT` - HTTP server port (default: auto-select)
- `RPC_PORT` - RPC server port (default: auto-select)
- `WS_PORT` - WebSocket port (default: auto-select)
- `BIND_ADDR` - Bind address (default: 0.0.0.0)

### Capabilities
- `SECURITY_ENDPOINT` - Security provider URL (discovered if not set)
- `STORAGE_ENDPOINT` - Storage provider URL (discovered if not set)
- `COMPUTE_ENDPOINT` - Compute provider URL (discovered if not set)

### Timeouts
- `TIMEOUT_CONNECT` - Connection timeout in seconds (default: 10)
- `TIMEOUT_REQUEST` - Request timeout in seconds (default: 30)
- `TIMEOUT_IDLE` - Idle timeout in seconds (default: 60)
```

### Step 6: Run Full Test Suite (30 min)

```bash
# Build all features
cargo build --all-features

# Run tests with dynamic ports
cargo test --all-features

# Run clippy
cargo clippy --all-features -- -D warnings

# Check for remaining hardcoding
rg 'localhost:[0-9]{4}' --type rust | grep -v test | grep -v example
```

---

## 🎯 Success Criteria

### Must Have:
- ✅ All production code uses environment variables or auto-selection
- ✅ No hardcoded ports in runtime code
- ✅ All tests pass with dynamic port allocation
- ✅ Documentation updated with env var guide
- ✅ `cargo build --all-features` succeeds

### Nice to Have:
- ✅ Test fixtures converted to dynamic ports
- ✅ Example scripts use env vars
- ✅ Showcase demos updated
- ✅ Migration guide for users

---

## 📊 Expected Outcomes

### Before Phase 2:
```rust
// Hardcoded
let http_server = "http://localhost:8080";
let rpc_server = "http://localhost:9000";
let timeout = Duration::from_secs(30);
```

### After Phase 2:
```rust
// Environment-driven
let config = EndpointConfig::from_env(); // Reads env or auto-selects
let http_server = format!("http://{}:{}", config.bind_addr, config.http_port);
let timeout = TimeoutConfig::from_env().request;
```

### Benefits:
1. **Zero Port Conflicts** - Auto-selection prevents collisions
2. **Cloud Native** - Works in Kubernetes, Docker, etc.
3. **Easy Testing** - Each test gets unique ports
4. **Flexible Deployment** - Configure via env, not code
5. **12-Factor Compliant** - Configuration in environment

---

## 🚧 Known Challenges

### Challenge 1: Test Parallelization
**Problem**: Tests may conflict if using same ports  
**Solution**: Dynamic port allocation per test

### Challenge 2: Backward Compatibility
**Problem**: Existing deployments expect specific ports  
**Solution**: Keep defaults as fallback, document migration

### Challenge 3: Discovery Integration
**Problem**: How do peers find each other with dynamic ports?  
**Solution**: Use mDNS/DHT discovery (already implemented!)

---

## 📝 Files to Modify (Priority Order)

### 🔴 Critical (Production Code):
1. `crates/songbird-config/src/canonical/constants.rs` - Replace all constants
2. `crates/songbird-orchestrator/src/server/mod.rs` - HTTP server binding
3. `crates/songbird-orchestrator/src/rpc/tarpc_server.rs` - RPC server binding
4. `crates/songbird-types/src/constants.rs` - Type constants
5. `crates/songbird-config/src/config/constants.rs` - Config constants

### 🟡 Important (Infrastructure):
6. `crates/songbird-test-utils/src/fixtures/ports.rs` - Test port allocation
7. `crates/songbird-universal/src/unified_adapter.rs` - Discovery endpoints
8. `crates/songbird-discovery/src/discovery/core.rs` - Discovery config
9. `crates/songbird-network-federation/src/btsp/provider.rs` - BTSP endpoints

### 🟢 Nice to Have (Examples/Tests):
10-324. All test files, examples, showcase scripts

---

## 🔄 Rollout Strategy

### Phase 2A.1: Configuration Module (Week 1)
- Create zero_hardcoding config module
- Implement EndpointConfig, TimeoutConfig
- Add tests

### Phase 2A.2: Production Code (Week 1-2)
- Update critical files (1-5)
- Update important files (6-9)
- Run integration tests

### Phase 2B: Test Infrastructure (Week 2)
- Implement dynamic port allocation
- Convert high-priority tests
- Parallel test execution

### Phase 2C: Documentation & Examples (Week 2-3)
- Update all documentation
- Convert examples to use env vars
- Migration guide

### Phase 2D: Validation (Week 3)
- Full regression testing
- Performance benchmarks
- Production deployment testing

---

## 📈 Metrics

| Metric | Before | After (Target) |
|--------|--------|----------------|
| Hardcoded Ports | 1,536 | 0 |
| Hardcoded IPs | 1,048 | 0 |
| Hardcoded Timeouts | 1,145 | <100 (tests only) |
| Test Port Conflicts | Common | Never |
| Deployment Flexibility | Low | High |
| Cloud Native Score | 60% | 95% |

---

## 🎯 Next Steps

1. **Review this plan** with team
2. **Allocate time** (4-6 hours)
3. **Start with Step 1** (Configuration modules)
4. **Iterate through** Steps 2-6
5. **Validate** with full test suite
6. **Document** achievements

---

**Ready to Execute**: This plan is complete and ready for implementation when time permits.

**Estimated ROI**: High - Enables true zero-configuration deployment, cloud-native operation, and eliminates entire class of configuration bugs.

---

**Last Updated**: 2026-01-01  
**Status**: PLANNED  
**Prerequisite**: ✅ Phase 1 Complete

