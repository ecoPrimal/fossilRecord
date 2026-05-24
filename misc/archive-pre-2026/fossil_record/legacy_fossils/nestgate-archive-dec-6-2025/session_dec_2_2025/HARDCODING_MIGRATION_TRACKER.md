# 🎯 Hardcoding Migration Tracker

**Created**: December 2, 2025  
**Priority**: CRITICAL  
**Total Instances**: 2,816  
**Target**: Zero hardcoded values, 100% environment-driven

---

## 📊 MIGRATION STATUS

| Category | Total | Migrated | Remaining | Progress |
|----------|-------|----------|-----------|----------|
| **Ports** | 963 | 0 | 963 | ⚠️ 0% |
| **IP Addresses** | 590 | 0 | 590 | ⚠️ 0% |
| **Primal Names** | 1,263 | 0 | 1,263 | ⚠️ 0% |
| **TOTAL** | **2,816** | **0** | **2,816** | ⚠️ **0%** |

---

## 🔴 CRITICAL: PRIMAL NAME HARDCODING (1,263 instances)

**Status**: ❌ **VIOLATES SPEC** - Breaks "Zero Hardcoding" principle

### Why Critical
This directly violates `PRIMAL_ECOSYSTEM_INTEGRATION_SPEC.md`:
- ❌ Should use capability-based discovery ONLY
- ❌ Should NEVER hardcode primal names
- ❌ Breaks vendor independence
- ❌ Violates sovereignty principles

### Distribution
- `beardog` references: ~316 instances
- `songbird` references: ~316 instances
- `squirrel` references: ~316 instances
- `toadstool` references: ~315 instances

### Files with Most References
```bash
# Run to find top offenders:
rg -i "beardog|songbird|squirrel|toadstool" --type rust code/ -c | sort -t: -k2 -rn | head -20
```

### Migration Strategy

#### Phase 1: Audit and Classify (Week 1)
- [ ] Identify all primal name usage patterns
- [ ] Classify by usage type (discovery, config, tests)
- [ ] Create migration examples for each pattern

#### Phase 2: Infrastructure (Week 2)
- [ ] Enhance capability-based discovery system
- [ ] Add capability registry
- [ ] Implement dynamic service resolution
- [ ] Add runtime service detection

#### Phase 3: Migration (Weeks 3-4)
- [ ] Replace name checks with capability checks
- [ ] Update configuration loading
- [ ] Migrate test fixtures
- [ ] Remove all hardcoded names

#### Phase 4: Verification (Week 5)
- [ ] Verify zero primal names remain: `rg -i "beardog|songbird|squirrel|toadstool" --type rust code/ | wc -l` = 0
- [ ] Test with capability-based discovery only
- [ ] Validate sovereignty compliance

### Migration Examples

#### Before (Hardcoded):
```rust
// ❌ BAD: Hardcoded primal name
if service_name == "beardog" {
    // Security operations
}

// ❌ BAD: Direct primal reference
let client = connect_to_primal("songbird", port);

// ❌ BAD: Configuration check
if config.primal == "squirrel" {
    // AI operations
}
```

#### After (Capability-Based):
```rust
// ✅ GOOD: Capability-based discovery
if service.has_capability("security") {
    // Security operations
}

// ✅ GOOD: Capability-based connection
let client = discovery.connect_by_capability("networking")?;

// ✅ GOOD: Capability check
if service.provides_capability("ai.inference") {
    // AI operations
}
```

---

## 🔵 PORT HARDCODING (963 instances)

**Status**: ⚠️ Needs systematic migration

### Port Distribution
| Port | Purpose | Count | Priority |
|------|---------|-------|----------|
| 8080 | API Server | ~250 | 🔴 Critical |
| 9090 | Metrics | ~100 | 🔴 Critical |
| 3000 | Discovery | ~50 | 🟡 High |
| 3001 | Discovery | ~50 | 🟡 High |
| 3002 | Discovery | ~50 | 🟡 High |
| 3010 | Discovery | ~50 | 🟡 High |
| 5432 | PostgreSQL | ~50 | 🟢 Medium |
| 6379 | Redis | ~40 | 🟢 Medium |
| 27017 | MongoDB | ~30 | 🟢 Medium |
| Other | Various | ~293 | 🟢 Low |

### Files with Most Port References
```bash
# Run to find top offenders:
rg "8080|3000|3001|3002|5432|6379|9090" --type rust code/ -c | sort -t: -k2 -rn | head -20
```

### Migration Progress

#### API Server Port (8080) - 250 instances
- [ ] Update constants to use `EnvironmentConfig`
- [ ] Migrate test files
- [ ] Migrate example code
- [ ] Migrate documentation
- [ ] Update config templates

#### Metrics Port (9090) - 100 instances
- [ ] Update monitoring configuration
- [ ] Migrate metrics collectors
- [ ] Update dashboard configs
- [ ] Update test fixtures

#### Discovery Ports (3000-3010) - 200 instances
- [ ] Update discovery configuration
- [ ] Use `DiscoveryConfig.port_range`
- [ ] Migrate primal discovery code
- [ ] Update integration tests

#### Database Ports (5432, 6379, 27017) - 120 instances
- [ ] Move to external service configuration
- [ ] Remove from NestGate config
- [ ] Update connection strings
- [ ] Document external dependencies

### Migration Examples

#### Before (Hardcoded):
```rust
// ❌ BAD: Hardcoded port
const API_PORT: u16 = 8080;

// ❌ BAD: Hardcoded in address
let addr = "127.0.0.1:8080".parse()?;

// ❌ BAD: Hardcoded in connection
let client = connect("localhost", 3000)?;
```

#### After (Environment-Driven):
```rust
// ✅ GOOD: Environment-driven port
let config = EnvironmentConfig::from_env()?;
let port = config.network.port.get();

// ✅ GOOD: Config-driven address
let addr = config.bind_address();

// ✅ GOOD: Discovery-driven connection
let client = discovery.connect(&config.discovery)?;
```

---

## 🟡 IP ADDRESS HARDCODING (590 instances)

**Status**: ⚠️ Needs environment configuration

### IP Distribution
| Address | Purpose | Count | Priority |
|---------|---------|-------|----------|
| localhost | Development | ~300 | 🟡 High |
| 127.0.0.1 | Loopback | ~200 | 🟡 High |
| 0.0.0.0 | Bind all | ~90 | 🟢 Medium |

### Files with Most IP References
```bash
# Run to find top offenders:
rg "localhost|127\.0\.0\.1|0\.0\.0\.0" --type rust code/ -c | sort -t: -k2 -rn | head -20
```

### Migration Progress

#### localhost (300 instances)
- [ ] Replace with `EnvironmentConfig.network.host`
- [ ] Update test configurations
- [ ] Update examples
- [ ] Update documentation

#### 127.0.0.1 (200 instances)
- [ ] Replace with config-driven addresses
- [ ] Update connection logic
- [ ] Update bind addresses
- [ ] Validate IPv6 support

#### 0.0.0.0 (90 instances)
- [ ] Replace with configurable bind addresses
- [ ] Add security warnings for production
- [ ] Document bind address options
- [ ] Add validation

### Migration Examples

#### Before (Hardcoded):
```rust
// ❌ BAD: Hardcoded localhost
let url = "http://localhost:8080/api";

// ❌ BAD: Hardcoded IP
let addr = "127.0.0.1:3000".parse()?;

// ❌ BAD: Hardcoded bind all
let listener = TcpListener::bind("0.0.0.0:8080")?;
```

#### After (Environment-Driven):
```rust
// ✅ GOOD: Config-driven URL
let config = EnvironmentConfig::from_env()?;
let url = format!("http://{}:{}/api", config.network.host, config.network.port);

// ✅ GOOD: Config-driven address
let addr = config.bind_address();

// ✅ GOOD: Config-driven bind
let listener = TcpListener::bind(config.bind_address())?;
```

---

## 🛠️ MIGRATION TOOLS & COMMANDS

### Finding Hardcoded Values

```bash
# Find all hardcoded ports
rg "8080|3000|3001|3002|3010|5432|6379|9090|27017" --type rust code/ > hardcoded_ports.txt

# Find all hardcoded IPs
rg "localhost|127\.0\.0\.1|0\.0\.0\.0" --type rust code/ > hardcoded_ips.txt

# Find all hardcoded primal names
rg -i "beardog|songbird|squirrel|toadstool" --type rust code/ > hardcoded_primals.txt

# Count instances
wc -l hardcoded_*.txt
```

### Automated Migration Helpers

```bash
# Dry run: Show what would be changed
./scripts/migrate_hardcoding.sh --dry-run

# Migrate a specific category
./scripts/migrate_hardcoding.sh --category=ports

# Migrate a specific file
./scripts/migrate_hardcoding.sh --file=code/crates/nestgate-core/src/config/mod.rs

# Verify no hardcoding remains
./scripts/verify_no_hardcoding.sh
```

### Verification Commands

```bash
# Check if migration is complete
rg "8080|3000|3001|3002" --type rust code/ | wc -l  # Should be 0 (except comments)
rg "localhost|127\.0\.0\.1" --type rust code/ | wc -l  # Should be 0 (except comments)
rg -i "beardog|songbird|squirrel|toadstool" --type rust code/ | wc -l  # Should be 0

# Check configuration coverage
cargo test --workspace -- config

# Check environment variable usage
rg "env::var|EnvironmentConfig" --type rust code/ | wc -l  # Should be high
```

---

## 📋 WEEKLY TARGETS

### Week 1 (Current)
- [x] Create this tracker
- [ ] Audit all hardcoded values (complete lists)
- [ ] Create migration examples
- [ ] Set up automated migration tools
- [ ] Migrate 50 critical port instances (API server)
- **Target**: 50/2,816 = 1.8%

### Week 2
- [ ] Migrate remaining API server ports (200 instances)
- [ ] Migrate metrics ports (100 instances)
- [ ] Start discovery ports migration (50 instances)
- [ ] Begin primal name infrastructure work
- **Target**: 350/2,816 = 12.4%

### Week 3
- [ ] Complete discovery ports (150 instances)
- [ ] Migrate database ports (120 instances)
- [ ] Migrate localhost references (150 instances)
- [ ] Continue primal name infrastructure
- **Target**: 770/2,816 = 27.3%

### Week 4
- [ ] Complete IP address migration (440 remaining)
- [ ] Migrate remaining ports (493 remaining)
- [ ] Start primal name migration (300 instances)
- **Target**: 2,003/2,816 = 71.1%

### Week 5
- [ ] Complete primal name migration (963 remaining)
- [ ] Clean up all remaining hardcoding
- [ ] Verify zero hardcoding: all checks pass
- **Target**: 2,816/2,816 = 100% ✅

---

## ✅ SUCCESS CRITERIA

### Must Achieve (Blocking)
- [ ] Zero primal names hardcoded (0/1,263)
- [ ] Zero API server ports hardcoded (0/250)
- [ ] Zero metrics ports hardcoded (0/100)
- [ ] All configuration environment-driven
- [ ] All tests pass with config-driven values
- [ ] Documentation updated

### Should Achieve (High Priority)
- [ ] Zero discovery ports hardcoded (0/200)
- [ ] Zero localhost references in production (0/300)
- [ ] Zero database ports in NestGate code (0/120)
- [ ] Automated verification in CI/CD

### Nice to Have (Medium Priority)
- [ ] Zero hardcoded values anywhere (0/2,816)
- [ ] Configuration validation at startup
- [ ] Runtime configuration reloading
- [ ] Configuration schema documentation

---

## 🚨 RED FLAGS

Stop and review if:
- ❌ Tests start failing after migration
- ❌ Services can't discover each other
- ❌ Configuration becomes too complex
- ❌ Performance degradation >5%
- ❌ New hardcoding being introduced

---

## 📈 DAILY TRACKING

### December 2, 2025 (Day 1)
- [x] Created tracker
- [ ] Audited port usage
- [ ] Audited IP usage
- [ ] Audited primal names
- **Migrated**: 0/2,816 (0%)

### December 3, 2025 (Day 2)
- [ ] Migrate API server constants
- [ ] Update configuration system
- [ ] Create migration script
- **Target**: 50/2,816 (1.8%)

### December 4, 2025 (Day 3)
- [ ] Migrate API server tests
- [ ] Migrate metrics configuration
- [ ] Update documentation
- **Target**: 150/2,816 (5.3%)

---

## 📞 NEED HELP?

### Questions
- Architecture: Contact core team
- Configuration: See `EnvironmentConfig` documentation
- Discovery: See `PRIMAL_ECOSYSTEM_INTEGRATION_SPEC.md`
- Testing: See test infrastructure docs

### Resources
- Configuration guide: `CONFIGURATION_GUIDE.md`
- Environment config: `code/crates/nestgate-core/src/config/environment.rs`
- Migration bridge: `code/crates/nestgate-core/src/config/migration_bridge.rs`
- Primal spec: `specs/PRIMAL_ECOSYSTEM_INTEGRATION_SPEC.md`

---

**Status**: 🔴 **IN PROGRESS** (0% complete)  
**Priority**: 🔴 **CRITICAL**  
**Target Date**: Week of January 6, 2026 (5 weeks)  
**Next Review**: December 3, 2025

---

*Track progress daily. Update percentages weekly. Celebrate milestones!* 🎯

