# MONTH 2: HARDCODING MIGRATION STRATEGY

**Date**: November 28, 2025  
**Status**: 🎯 READY TO EXECUTE

---

## 📊 CURRENT STATE ANALYSIS

### Hardcoded Values Found:
```
Ports (by type):
  8080 (HTTP Alt):     423 instances
  80 (HTTP):           242 instances
  3000 (Dev Server):   120 instances
  9090 (Prometheus):   107 instances
  5432 (PostgreSQL):    39 instances
  6379 (Redis):         30 instances
  443 (HTTPS):          51 instances
  
IPs:
  127.0.0.1:           175 instances
  localhost:           302 instances
  
Total: ~1,489 hardcoded values
```

### Hot Spots (Files with Most Hardcoding):
1. `config/network_defaults.rs` - 40 instances
2. `network/api_tests.rs` - 30 instances
3. `constants/consolidated.rs` - 28 instances
4. `config/defaults.rs` - 23 instances
5. `constants/sovereignty_helpers_config.rs` - 21 instances

---

## 🎯 MIGRATION STRATEGY

### Phase 1: Infrastructure Ready ✅
- **Status**: COMPLETE
- **Assets**:
  - `port_config.rs` - Comprehensive port configuration system
  - Environment variable support for all ports
  - Centralized defaults with override capability

### Phase 2: Automated Migration (Week 5)
- **Tool**: `scripts/migrate_hardcoded_ports.py`
- **Approach**: Conservative, file-by-file migration
- **Safety**: Dry-run first, verify tests pass after each batch

### Phase 3: Manual Review (Week 6)
- **Focus**: Complex cases, test files, configuration
- **Validation**: Ensure semantic correctness
- **Testing**: Multi-environment validation

### Phase 4: Documentation & Deployment (Week 7-8)
- **Update**: Configuration guides
- **Create**: Migration runbook
- **Test**: Production deployment scenarios

---

## 🔧 MIGRATION TOOL

### migrate_hardcoded_ports.py

**Features**:
- Automatic port literal replacement
- Smart import injection
- Context-aware host migration
- Dry-run mode for safety
- Comprehensive reporting

**Port Mappings**:
```
8080 → port_config::api_port()
8081 → port_config::admin_port()
8082 → port_config::health_port()
8083 → port_config::websocket_port()
9090 → port_config::metrics_port()
5432 → port_config::postgres_port()
6379 → port_config::redis_port()
3000 → port_config::grafana_port()
```

**Usage**:
```bash
# Dry run (shows what would change)
python3 scripts/migrate_hardcoded_ports.py

# Apply changes
python3 scripts/migrate_hardcoded_ports.py --apply
```

---

## 📋 EXECUTION PLAN

### Week 5: Core Services
- [x] Day 1: Create migration tools
- [ ] Day 2-3: Migrate core service files (not tests)
- [ ] Day 4: Migrate network layer
- [ ] Day 5: Run full test suite, fix breakages

### Week 6: Configuration & Tests
- [ ] Day 1-2: Migrate configuration files
- [ ] Day 3-4: Migrate test files (conservative)
- [ ] Day 5: Multi-environment testing

### Week 7: Validation
- [ ] Day 1-2: Manual review of complex cases
- [ ] Day 3-4: Integration testing
- [ ] Day 5: Performance validation

### Week 8: Documentation & Polish
- [ ] Day 1-2: Update documentation
- [ ] Day 3: Create deployment guide
- [ ] Day 4-5: Final validation and handoff

---

## ⚠️ SAFETY GUIDELINES

### DO Migrate:
- ✅ Hardcoded port literals in production code
- ✅ Hardcoded IP addresses in config
- ✅ Environment-specific values
- ✅ Service discovery endpoints

### DON'T Migrate (Yet):
- ❌ Test fixtures that verify specific ports
- ❌ Example/demo code that needs specific ports
- ❌ Protocol standards (80, 443 in comments/docs)
- ❌ Port validation ranges (0-65535)

### Review Manually:
- 🔍 Config default files
- 🔍 Constants that define port ranges
- 🔍 Network utility functions
- 🔍 Discovery mechanisms

---

## 🧪 TESTING STRATEGY

### After Each Batch:
1. Run full test suite: `cargo test --workspace --lib`
2. Check compilation: `cargo check --workspace`
3. Verify formatting: `cargo fmt --all -- --check`
4. Run clippy: `cargo clippy --workspace --lib`

### Multi-Environment Testing:
```bash
# Test with default ports
cargo test --workspace

# Test with custom ports
export NESTGATE_API_PORT=9080
export NESTGATE_POSTGRES_PORT=5433
cargo test --workspace

# Test with production-like config
source deploy/production.env
cargo test --workspace
```

---

## 📈 SUCCESS CRITERIA

### Week 5-6:
- [ ] 80%+ of hardcoded ports migrated
- [ ] All tests passing
- [ ] No regressions in functionality

### Week 7-8:
- [ ] 95%+ of production code migrated
- [ ] Multi-environment validation complete
- [ ] Documentation updated
- [ ] Deployment guide created

### Final Metrics:
- [ ] Hardcoded ports: <50 (down from ~1,000)
- [ ] Hardcoded IPs: <10 (down from ~477)
- [ ] All services support env overrides
- [ ] Zero test failures

---

## 🎁 BENEFITS

### Immediate:
- Environment-specific configuration
- No code changes for deployment
- Easier testing (port conflicts)
- Docker/K8s friendly

### Long-term:
- Service mesh ready
- Multi-tenant capable
- Federation friendly
- Zero-downtime reconfiguration

---

## 📚 REFERENCE

### Configuration System:
- `code/crates/nestgate-core/src/config/port_config.rs`
- Environment variables: `NESTGATE_*_PORT`
- Defaults in `constants/hardcoding.rs`

### Migration Tools:
- `scripts/migrate_hardcoded_ports.py` - Automated migration
- `scripts/analyze_hardcoded_ports.sh` - Analysis tool

### Testing:
- `deploy/production.env` - Production config example
- `config/production-template.toml` - TOML config template

---

**Status**: 🎯 STRATEGY COMPLETE - READY FOR EXECUTION  
**Tools**: ✅ CREATED AND TESTED  
**Timeline**: 4 weeks (realistic)  
**Risk**: LOW (comprehensive testing, incremental approach)

*Smart automation. Safe migration. Production ready.* ✅

