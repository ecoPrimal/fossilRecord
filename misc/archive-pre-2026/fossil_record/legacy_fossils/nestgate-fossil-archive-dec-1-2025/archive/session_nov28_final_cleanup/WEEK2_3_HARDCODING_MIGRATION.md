# 🚀 WEEK 2-3 EXECUTION: HARDCODING MIGRATION

**Started**: November 28, 2025  
**Phase**: Hardcoding Migration (Week 2-3)  
**Status**: ✅ IN PROGRESS

---

## 📊 MIGRATION OVERVIEW

### Targets Identified:
```
Hardcoded Ports:        1,132 instances
Hardcoded IPs:          469 instances (127.0.0.1, localhost)
Files to Process:       100+ files
Priority Files:         20+ production files
Test Files:             80+ test files
```

### Port Mappings Configured:
```
8080  -> crate::config::port_config::api_port()
8081  -> crate::config::port_config::admin_port()
8082  -> crate::config::port_config::health_port()
8083  -> crate::config::port_config::websocket_port()
3000  -> crate::config::port_config::grafana_port()
5000  -> crate::config::port_config::storage_port()
5432  -> crate::config::port_config::postgres_port()
6379  -> crate::config::port_config::redis_port()
9090  -> crate::config::port_config::prometheus_port()
9100  -> crate::config::port_config::metrics_port()
27017 -> crate::config::port_config::mongodb_port()
50051 -> crate::config::port_config::grpc_port()
... and 6 more
```

---

## 🎯 EXECUTION PLAN

### Phase 1: Dry-Run Analysis (30 minutes) ✅ IN PROGRESS
- [x] Run migration script in dry-run mode
- [ ] Review potential changes
- [ ] Identify any issues
- [ ] Validate approach

### Phase 2: Core Files Migration (2-3 hours)
- [ ] Backup existing files
- [ ] Migrate priority production files
- [ ] Run tests after each file
- [ ] Validate functionality

### Phase 3: Test Files Migration (3-4 hours)
- [ ] Migrate test files systematically
- [ ] Validate test suite still passes
- [ ] Fix any broken tests

### Phase 4: Localhost References (3-4 hours)
- [ ] Create localhost migration strategy
- [ ] Migrate 81 files with localhost
- [ ] Test multi-environment configs

### Phase 5: Validation & Testing (2-3 hours)
- [ ] Full test suite execution
- [ ] Multi-environment testing
- [ ] Docker/K8s validation
- [ ] Documentation updates

**Total Estimated Time**: 10-15 hours

---

## 📋 PRIORITY FILES LIST

### High Priority (Production Code):
1. `nestgate-api/src/bin/nestgate-api-server.rs`
2. `nestgate-core/src/defaults.rs`
3. `nestgate-core/src/network/client.rs`
4. `nestgate-core/src/universal_primal_discovery/fallbacks.rs`
5. `nestgate-core/src/universal_primal_discovery/registry.rs`

### Medium Priority (Configuration):
6. `nestgate-core/src/config/network_defaults_tests.rs`
7. `nestgate-core/src/config/defaults_config.rs`
8. `nestgate-core/src/config/runtime.rs`

### Lower Priority (Tests):
9-100. Various test files (can keep some hardcoded values)

---

## 🔍 DRY-RUN RESULTS

**Status**: Running...

(Results will be logged here)

---

## ✅ SUCCESS CRITERIA

### Must Have:
- [ ] All production ports use port_config functions
- [ ] Tests pass with default configuration
- [ ] Tests pass with custom port configuration
- [ ] No hardcoded 8080, 5432, 6379, 9090 in production code
- [ ] Backup files created (.bak)

### Should Have:
- [ ] 80%+ of all hardcoded ports migrated
- [ ] localhost references use config system
- [ ] Multi-environment testing complete
- [ ] Documentation updated

### Nice to Have:
- [ ] 100% of all hardcoded values migrated
- [ ] All test files migrated
- [ ] Performance validated
- [ ] Grade improved to A- (89/100)

---

## 📊 PROGRESS TRACKING

### Files Processed: 0 / ~100
### Replacements Made: 0 / 1,132
### Tests Passing: ✅ YES (baseline)
### Errors: 0

---

**Last Updated**: November 28, 2025  
**Status**: Phase 1 - Dry-Run Analysis  
**Next**: Review dry-run results and proceed with migration

