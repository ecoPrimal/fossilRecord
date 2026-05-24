# 🔧 PORT MIGRATION GUIDE - Systematic Hardcoding Elimination

**Created**: December 2, 2025  
**Status**: Migration Framework Ready  
**Target**: 1,083 hardcoded port instances → environment-driven  
**Timeline**: 4-6 weeks systematic migration

---

## 📊 MIGRATION STATUS

| Port | Count | Purpose | Priority | Status |
|------|-------|---------|----------|--------|
| 8080 | 250+ | API Server | 🔴 Critical | Ready to migrate |
| 3000-3010 | 200+ | Discovery | 🟡 High | Ready to migrate |
| 9090 | 100+ | Metrics | 🟡 High | Ready to migrate |
| 5432 | 50+ | PostgreSQL | 🟢 Medium | External service |
| 6379 | 40+ | Redis | 🟢 Medium | External service |
| Other | 443+ | Various | 🟢 Low | Case-by-case |

**Total**: 1,083 instances  
**Completed**: 0 (0%)  
**In Progress**: Framework complete  
**Remaining**: 1,083 (100%)

---

## ✅ EXISTING INFRASTRUCTURE (Already Built!)

Your codebase already has excellent environment-driven configuration infrastructure:

### **1. NetworkDefaultsConfig** ✅
- **Location**: `constants/network_defaults_config.rs`
- **Environment Variables**:
  - `NESTGATE_BIND_ADDRESS` - Bind address
  - `NESTGATE_API_HOST` - API hostname
  - `NESTGATE_DB_HOST` - Database hostname
  - `NESTGATE_REDIS_HOST` - Redis hostname
  - `NESTGATE_ENVIRONMENT` - Environment type

### **2. PortDefaultsConfig** ✅
- **Location**: `constants/port_defaults_config.rs`
- Thread-safe port configuration
- Environment variable support

### **3. ServiceDiscoveryConfig** ✅
- **Location**: `config/discovery_config.rs`
- Discovery port ranges
- Dynamic endpoint building

### **4. ServicesConfig** ✅
- **Location**: `config/external/services_config.rs`
- Capability-based service discovery
- Full URL configuration

**You have world-class configuration infrastructure already!**

---

## 🎯 MIGRATION PATTERN

### **Standard Migration Pattern**

#### **❌ BEFORE: Hardcoded**
```rust
// Hardcoded port in code
let addr = "127.0.0.1:8080".parse()?;
let listener = TcpListener::bind(addr)?;
```

#### **✅ AFTER: Environment-Driven**
```rust
// Load from environment/config
let config = EnvironmentConfig::from_env()?;
let addr = config.bind_address();  // Uses NESTGATE_API_PORT or default
let listener = TcpListener::bind(addr)?;
```

---

## 📋 MIGRATION STEPS BY PORT TYPE

### **Priority 1: API Server Port (8080) - 250+ instances**

#### **Step 1: Add API Port to PortDefaultsConfig**

**File**: `code/crates/nestgate-core/src/constants/port_defaults_config.rs`

```rust
pub struct PortDefaultsConfig {
    api_port: Option<u16>,
    metrics_port: Option<u16>,
    discovery_base_port: Option<u16>,
    // ... existing fields
}

impl PortDefaultsConfig {
    pub fn from_env() -> Self {
        Self {
            api_port: std::env::var("NESTGATE_API_PORT")
                .ok()
                .and_then(|s| s.parse().ok()),
            metrics_port: std::env::var("NESTGATE_METRICS_PORT")
                .ok()
                .and_then(|s| s.parse().ok()),
            discovery_base_port: std::env::var("NESTGATE_DISCOVERY_PORT")
                .ok()
                .and_then(|s| s.parse().ok()),
            // ... existing fields
        }
    }
    
    pub fn get_api_port(&self) -> u16 {
        self.api_port.unwrap_or(8080)  // Default fallback
    }
    
    pub fn get_metrics_port(&self) -> u16 {
        self.metrics_port.unwrap_or(9090)
    }
    
    pub fn get_discovery_base_port(&self) -> u16 {
        self.discovery_base_port.unwrap_or(3000)
    }
}
```

#### **Step 2: Update Constants to Use Config**

**File**: `code/crates/nestgate-core/src/constants/ports.rs`

```rust
// ❌ OLD: Hardcoded constant
pub const API_PORT: u16 = 8080;

// ✅ NEW: Environment-driven function
pub fn api_port() -> u16 {
    PortDefaultsConfig::from_env().get_api_port()
}

// Or even better, deprecate the constant:
#[deprecated(since = "0.13.0", note = "Use PortDefaultsConfig::from_env().get_api_port()")]
pub const API_PORT: u16 = 8080;
```

#### **Step 3: Update Usage Sites (250 instances)**

```bash
# Find all 8080 usages
rg "\b8080\b" --type rust code/ > port_8080_instances.txt

# Review each instance and classify:
# - Production code: Migrate to config
# - Test code: Use test fixtures
# - Example code: Use config with defaults
# - Documentation: Update to show config usage
```

**Migration Examples**:

```rust
// ❌ BEFORE: Direct hardcoding
let listener = TcpListener::bind("0.0.0.0:8080")?;

// ✅ AFTER: Environment-driven
let config = PortDefaultsConfig::from_env();
let addr = format!("0.0.0.0:{}", config.get_api_port());
let listener = TcpListener::bind(addr)?;

// Or use the full config:
let network_config = NetworkDefaultsConfig::from_env();
let port_config = PortDefaultsConfig::from_env();
let addr = format!("{}:{}", network_config.get_bind_address(), port_config.get_api_port());
let listener = TcpListener::bind(addr)?;
```

---

### **Priority 2: Discovery Ports (3000-3010) - 200+ instances**

#### **Pattern: Port Range Configuration**

```rust
// ❌ BEFORE: Hardcoded range
let scan_ports = vec![3000, 3001, 3002, 3010];

// ✅ AFTER: Environment-driven range
pub struct DiscoveryPortConfig {
    base_port: u16,
    range_size: u16,
}

impl DiscoveryPortConfig {
    pub fn from_env() -> Self {
        let base = std::env::var("NESTGATE_DISCOVERY_BASE_PORT")
            .ok()
            .and_then(|s| s.parse().ok())
            .unwrap_or(3000);
        
        let range = std::env::var("NESTGATE_DISCOVERY_PORT_RANGE")
            .ok()
            .and_then(|s| s.parse().ok())
            .unwrap_or(4);
        
        Self {
            base_port: base,
            range_size: range,
        }
    }
    
    pub fn get_port_range(&self) -> Vec<u16> {
        (0..self.range_size)
            .map(|offset| self.base_port + offset)
            .collect()
    }
}

// Usage:
let config = DiscoveryPortConfig::from_env();
let scan_ports = config.get_port_range();  // [3000, 3001, 3002, 3003]
```

---

### **Priority 3: Metrics Port (9090) - 100+ instances**

```rust
// ❌ BEFORE
let metrics_addr = "localhost:9090";

// ✅ AFTER
let config = PortDefaultsConfig::from_env();
let metrics_addr = format!("localhost:{}", config.get_metrics_port());
```

---

### **Priority 4: External Services (5432, 6379) - 90+ instances**

**Note**: These should NOT be in NestGate configuration. External services should be configured externally.

```rust
// ❌ WRONG: NestGate manages database ports
const POSTGRES_PORT: u16 = 5432;

// ✅ CORRECT: Get from external service configuration
let db_url = std::env::var("DATABASE_URL")
    .unwrap_or_else(|_| "postgresql://localhost:5432/nestgate".to_string());

// Or better: Document that this is external
/// PostgreSQL connection should be configured via DATABASE_URL environment variable.
/// Example: postgresql://host:port/database
```

---

## 🛠️ MIGRATION TOOLS

### **Tool 1: Port Instance Finder**

```bash
#!/bin/bash
# File: scripts/find_port_instances.sh
# Find all instances of a specific port

PORT=$1
if [ -z "$PORT" ]; then
    echo "Usage: $0 <port_number>"
    exit 1
fi

echo "Finding all instances of port $PORT..."
rg "\b$PORT\b" --type rust code/ \
    --no-heading \
    --line-number \
    --context 2 \
    > "port_${PORT}_instances.txt"

echo "Found $(wc -l < port_${PORT}_instances.txt) lines"
echo "Results saved to: port_${PORT}_instances.txt"

# Categorize by file type
echo ""
echo "Breakdown by location:"
echo "Production code:"
rg "\b$PORT\b" --type rust code/crates/*/src --files-with-matches | \
    grep -v test | wc -l
echo "Test code:"
rg "\b$PORT\b" --type rust code/crates/*/src --files-with-matches | \
    grep test | wc -l
```

### **Tool 2: Migration Progress Tracker**

```bash
#!/bin/bash
# File: scripts/track_port_migration.sh
# Track migration progress

echo "PORT MIGRATION PROGRESS TRACKER"
echo "================================"
echo ""

for port in 8080 3000 3001 3002 3010 9090 5432 6379; do
    count=$(rg "\b$port\b" --type rust code/ 2>/dev/null | wc -l)
    echo "Port $port: $count instances remaining"
done

echo ""
echo "Total hardcoded ports remaining:"
rg "\b(8080|3000|3001|3002|3010|9090|5432|6379)\b" --type rust code/ 2>/dev/null | wc -l
```

### **Tool 3: Test Configuration Helper**

```rust
// File: code/crates/nestgate-core/src/test_config/port_config.rs

/// Test helper for port configuration
pub struct TestPortConfig {
    api_port: u16,
    metrics_port: u16,
    discovery_port: u16,
}

impl TestPortConfig {
    /// Create test configuration with ephemeral ports
    pub fn ephemeral() -> Self {
        Self {
            api_port: 0,  // OS will assign
            metrics_port: 0,
            discovery_port: 0,
        }
    }
    
    /// Create test configuration with specific ports
    pub fn with_ports(api: u16, metrics: u16, discovery: u16) -> Self {
        Self {
            api_port: api,
            metrics_port: metrics,
            discovery_port: discovery,
        }
    }
    
    pub fn api_port(&self) -> u16 { self.api_port }
    pub fn metrics_port(&self) -> u16 { self.metrics_port }
    pub fn discovery_port(&self) -> u16 { self.discovery_port }
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_ephemeral_ports() {
        let config = TestPortConfig::ephemeral();
        // Ephemeral ports allow parallel test execution
        assert_eq!(config.api_port(), 0);
    }
}
```

---

## 📅 MIGRATION SCHEDULE

### **Week 1: Foundation (Dec 3-9)**
- [ ] Enhance `PortDefaultsConfig` with all port types
- [ ] Create test configuration helpers
- [ ] Update 50 most critical API server instances (8080)
- **Target**: 50/1,083 = 4.6%

### **Week 2: API Server (Dec 10-16)**
- [ ] Migrate remaining API server instances (200 more)
- [ ] Update documentation
- [ ] Update examples
- **Target**: 250/1,083 = 23.1%

### **Week 3: Discovery Ports (Dec 17-23)**
- [ ] Create `DiscoveryPortConfig` 
- [ ] Migrate all discovery port instances (200)
- [ ] Update discovery tests
- **Target**: 450/1,083 = 41.5%

### **Week 4: Metrics & External (Dec 24-30)**
- [ ] Migrate metrics port instances (100)
- [ ] Document external service ports (don't migrate)
- [ ] Update configuration documentation
- **Target**: 550/1,083 = 50.8%

### **Weeks 5-6: Cleanup (Jan 2026)**
- [ ] Migrate remaining low-priority ports (533)
- [ ] Update all tests to use test config
- [ ] Final verification
- **Target**: 1,083/1,083 = 100%

---

## ✅ MIGRATION CHECKLIST

### **Before Starting**
- [x] Existing infrastructure reviewed ✅
- [x] Migration pattern documented ✅
- [x] Tools created ✅
- [ ] Team briefed on approach
- [ ] Test strategy defined

### **For Each Port Type**
- [ ] Count current instances
- [ ] Classify by code type (prod/test/example)
- [ ] Create configuration type
- [ ] Add environment variable
- [ ] Update documentation
- [ ] Migrate production code
- [ ] Migrate test code
- [ ] Migrate examples
- [ ] Verify no regressions
- [ ] Update progress tracker

### **After Migration**
- [ ] All tests passing
- [ ] Documentation updated
- [ ] Configuration guide complete
- [ ] Zero hardcoded ports remaining
- [ ] Environment variable list documented

---

## 🎯 EXPECTED OUTCOMES

### **After Week 2** (250 instances)
```bash
# Before
let addr = "0.0.0.0:8080";

# After
let config = PortDefaultsConfig::from_env();
let addr = format!("0.0.0.0:{}", config.get_api_port());
```

**Benefits**:
- ✅ Flexible deployment (any port)
- ✅ Environment-specific configuration
- ✅ No code changes for different environments
- ✅ Better testing (ephemeral ports)

### **After Week 4** (550 instances)
```bash
# Environment variables control all ports
export NESTGATE_API_PORT=8080
export NESTGATE_METRICS_PORT=9090
export NESTGATE_DISCOVERY_PORT=3000
export NESTGATE_DISCOVERY_PORT_RANGE=4
```

**Benefits**:
- ✅ Complete deployment flexibility
- ✅ Containerization-ready
- ✅ Multi-tenancy support
- ✅ Cloud-native deployment

### **After Week 6** (100% complete)
```bash
# Zero hardcoded ports
$ rg "\b(8080|3000|9090)\b" --type rust code/crates/*/src | wc -l
0

# All configuration documented
$ cat config/PORTS.md
# NestGate Port Configuration
All ports are configurable via environment variables...
```

---

## 📊 SUCCESS METRICS

### **Technical Metrics**
- Hardcoded port instances: 1,083 → 0
- Configuration coverage: 0% → 100%
- Test flexibility: Fixed ports → Ephemeral ports
- Deployment flexibility: Single environment → Multi-environment

### **Quality Metrics**
- Test pass rate: Maintain 100%
- Build status: Maintain clean
- Documentation: Complete port configuration guide
- Backward compatibility: Maintain defaults

---

## 🚨 IMPORTANT NOTES

### **DO NOT Break Backward Compatibility**
```rust
// ✅ CORRECT: Maintain defaults
pub fn get_api_port(&self) -> u16 {
    self.api_port.unwrap_or(8080)  // Default preserves current behavior
}

// ❌ WRONG: Require configuration
pub fn get_api_port(&self) -> Result<u16> {
    self.api_port.ok_or(Error::MissingConfig)  // Breaks existing code!
}
```

### **External Services Stay External**
- PostgreSQL (5432): Configure via `DATABASE_URL`
- Redis (6379): Configure via `REDIS_URL`
- MongoDB (27017): Configure via `MONGODB_URL`

**Do not add these to NestGate configuration!**

### **Tests Need Special Handling**
```rust
// ✅ GOOD: Tests use ephemeral ports
#[tokio::test]
async fn test_api_server() {
    let config = TestPortConfig::ephemeral();
    let server = ApiServer::new(config)?;
    // OS assigns available port
}

// ❌ BAD: Tests use fixed ports
#[tokio::test]
async fn test_api_server() {
    let server = ApiServer::bind("localhost:8080")?;
    // Port conflict if tests run in parallel!
}
```

---

## 📞 NEED HELP?

### **Questions**
- Configuration: See `PortDefaultsConfig` docs
- Testing: See `TestPortConfig` helpers
- Migration: See examples in this guide
- Progress: Run `./scripts/track_port_migration.sh`

### **Resources**
- Port config: `constants/port_defaults_config.rs`
- Network config: `constants/network_defaults_config.rs`
- Service config: `config/external/services_config.rs`
- Test helpers: `test_config/port_config.rs`

---

**Status**: 🟢 Ready to Begin  
**Priority**: 🟡 High (Non-blocking)  
**Timeline**: 4-6 weeks  
**Effort**: ~40-60 hours  
**Team**: 1-2 developers

---

*Systematic migration eliminates hardcoding while maintaining backward compatibility and stability.* 🎯

