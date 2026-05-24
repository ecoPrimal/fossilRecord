# 🧪 Test Expansion Plan - November 3, 2025

**Current Coverage**: 53.67% (Functions: 47.93%, Lines: 51.97%)  
**Target Coverage**: 90% (Functions: 90%+, Lines: 90%+)  
**Gap**: 36.33% (approximately 300-400 tests needed)  
**Timeline**: 2-4 weeks

---

## 📊 Coverage Report Location

```bash
# View HTML coverage report
open target/llvm-cov/html/index.html
# or
xdg-open target/llvm-cov/html/index.html
```

---

## 🎯 Priority 1: Zero/Low Coverage Modules (0-30%)

These modules have critical functionality but minimal tests. **Highest ROI for coverage gains.**

### **1. Learning System** (`core/context/src/learning/`) - **0-27% coverage**

**Modules Needing Tests**:
- ✅ `learning/mod.rs` - Learning system coordination (0%)
- ✅ `learning/engine.rs` - Core RL engine (27%)
- ✅ `learning/manager.rs` - Context learning manager (0%)
- ✅ `learning/adaptive.rs` - Adaptive rules (0%)
- ✅ `learning/experience.rs` - Experience replay (0%)
- ✅ `learning/policy.rs` - Policy network (0%)
- ✅ `learning/reward.rs` - Reward system (0%)
- ✅ `learning/metrics.rs` - Learning metrics (0%)
- ✅ `learning/integration/` - Integration layer (48-100% mixed)

**Test Strategy**:
```rust
// Example test structure for learning/engine.rs
#[cfg(test)]
mod tests {
    use super::*;
    
    #[tokio::test]
    async fn test_learning_engine_initialization() {
        let config = LearningEngineConfig::default();
        let engine = LearningEngine::new(config);
        assert!(engine.initialize().await.is_ok());
    }
    
    #[tokio::test]
    async fn test_rl_experience_creation() {
        let state = RLState { /* ... */ };
        let action = RLAction { /* ... */ };
        let experience = RLExperience::new(state, action, 1.0, None, false);
        assert!(!experience.id.is_empty());
    }
    
    #[tokio::test]
    async fn test_q_learning_update() {
        // Test Q-table updates
    }
    
    #[tokio::test]
    async fn test_neural_network_forward_pass() {
        // Test neural network functionality
    }
}
```

**Estimated Tests**: 50-60 tests  
**Estimated Time**: 3-4 days  
**Coverage Impact**: +15-20%

---

### **2. Visualization System** (`core/context/src/visualization/`) - **0% coverage**

**Modules Needing Tests**:
- ✅ `visualization/mod.rs` - Visualization coordination (0%)
- ✅ `visualization/manager.rs` - Visualization manager (0%)
- ✅ `visualization/renderers.rs` - Rendering engines (0%)
- ✅ `visualization/types.rs` - Type definitions (0%)
- ✅ `visualization/metrics.rs` - Metrics visualization (0%)
- ✅ `visualization/interactive.rs` - Interactive features (0%)
- ✅ `visualization/web.rs` - Web integration (0%)

**Test Strategy**:
```rust
#[cfg(test)]
mod tests {
    use super::*;
    
    #[tokio::test]
    async fn test_visualization_manager_creation() {
        let manager = VisualizationManager::new().await;
        assert!(manager.is_ok());
    }
    
    #[tokio::test]
    async fn test_graph_renderer_basic() {
        let renderer = GraphRenderer::new();
        let data = vec![1.0, 2.0, 3.0];
        let result = renderer.render(&data);
        assert!(result.is_ok());
    }
    
    #[tokio::test]
    async fn test_metrics_visualization_formats() {
        // Test different output formats (SVG, PNG, HTML)
    }
}
```

**Estimated Tests**: 25-30 tests  
**Estimated Time**: 1-2 days  
**Coverage Impact**: +5-8%

---

### **3. Rule System** (`core/context/src/rules/`) - **0% coverage**

**Modules Needing Tests**:
- ✅ `rules/mod.rs` - Rule coordination (0%)
- ✅ `rules/evaluator.rs` - Rule evaluation (0%)
- ✅ `rules/parser.rs` - Rule parsing (0%)
- ✅ `rules/models.rs` - Rule models (0%)
- ✅ `rules/directory.rs` - Rule directory (0%)
- ✅ `rules/repository.rs` - Rule repository (0%)
- ✅ `rules/plugin.rs` - Rule plugins (0%)
- ✅ `rules/error.rs` - Rule errors (0%)

**Test Strategy**:
```rust
#[cfg(test)]
mod tests {
    use super::*;
    
    #[tokio::test]
    async fn test_rule_parser_valid_syntax() {
        let parser = RuleParser::new();
        let rule_str = "if context.value > 10 then action.alert()";
        let result = parser.parse(rule_str);
        assert!(result.is_ok());
    }
    
    #[tokio::test]
    async fn test_rule_evaluator_execution() {
        let evaluator = RuleEvaluator::new();
        let rule = create_test_rule();
        let context = create_test_context();
        let result = evaluator.evaluate(&rule, &context).await;
        assert!(result.is_ok());
    }
    
    #[tokio::test]
    async fn test_rule_repository_crud() {
        // Test create, read, update, delete
    }
}
```

**Estimated Tests**: 40-50 tests  
**Estimated Time**: 2-3 days  
**Coverage Impact**: +10-15%

---

### **4. Plugin System** (`core/plugins/src/`) - **0-20% coverage**

**Modules Needing Tests**:
- ✅ `lib.rs` - Main plugin API (0%)
- ✅ `manager.rs` - Plugin manager (0%)
- ✅ `unified_manager.rs` - Unified manager (0%)
- ✅ `default_manager.rs` - Default manager (0%)
- ✅ `discovery.rs` - Plugin discovery (0%)
- ✅ `state.rs` - State management (0%)
- ✅ `zero_copy.rs` - Zero-copy plugins (0%)
- ✅ `zero_cost_plugin.rs` - Zero-cost plugins (0%)
- ✅ `zero_cost_plugin_dispatch.rs` - Dispatch system (0%)
- ✅ `web/` - Web plugins (0%)
- ✅ `cli/` - CLI plugins (0%)
- ✅ `mcp/` - MCP plugins (0%)
- ✅ `canonical_metadata.rs` - Metadata (20%)

**Test Strategy**:
```rust
#[cfg(test)]
mod tests {
    use super::*;
    
    #[tokio::test]
    async fn test_plugin_manager_register() {
        let manager = UnifiedPluginManager::new(config).await.unwrap();
        let plugin = create_test_plugin();
        assert!(manager.register_plugin(plugin).await.is_ok());
    }
    
    #[tokio::test]
    async fn test_plugin_discovery_scan() {
        let discovery = PluginDiscovery::new();
        let plugins = discovery.scan_directory("./plugins").await;
        assert!(plugins.is_ok());
    }
    
    #[tokio::test]
    async fn test_zero_cost_plugin_dispatch() {
        let plugin = ZeroCostPluginRegistry::Core(CorePlugin::new());
        let result = plugin.execute("test").await;
        assert!(result.is_ok());
    }
    
    #[tokio::test]
    async fn test_plugin_lifecycle() {
        // Test init -> start -> execute -> stop -> shutdown
    }
}
```

**Estimated Tests**: 60-70 tests  
**Estimated Time**: 4-5 days  
**Coverage Impact**: +15-20%

---

### **5. Canonical Config** (`canonical-config/src/`) - **Mixed 0-100%**

**Modules Needing Tests** (0-50% coverage):
- ✅ `lib.rs` - Main config API (0%)
- ✅ `network.rs` - Network config (0%)
- ✅ `orchestration.rs` - Orchestration config (0%)
- ✅ `performance.rs` - Performance config (0%)
- ✅ `system.rs` - System config (0%)
- ✅ `services.rs` - Services config (5%)
- ✅ `biomeos.rs` - BiomeOS config (0%)
- ✅ `monitoring.rs` - Monitoring config (5%)
- ✅ `unified/mod.rs` - Unified config (35%)
- ✅ `unified/network/mod.rs` - Network unified (12%)

**Already Well-Tested** (90-100% coverage):
- ✅ `unified/network/http.rs` (100%)
- ✅ `unified/network/websocket.rs` (99%)
- ✅ `unified/network/timeouts.rs` (100%)
- ✅ `unified/network/grpc.rs` (99%)
- ✅ `unified/security.rs` (92%)
- ✅ `unified/system.rs` (96%)

**Test Strategy**:
```rust
#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_unified_config_builder() {
        let config = UnifiedSquirrelConfig::builder()
            .http_port(8080)
            .grpc_port(9090)
            .build();
        assert!(config.is_ok());
    }
    
    #[test]
    fn test_config_from_env() {
        std::env::set_var("SQUIRREL_HTTP_PORT", "8888");
        let config = UnifiedSquirrelConfig::from_env();
        assert_eq!(config.http_port(), 8888);
    }
    
    #[test]
    fn test_config_validation() {
        let config = create_invalid_config();
        assert!(config.validate().is_err());
    }
}
```

**Estimated Tests**: 40-50 tests  
**Estimated Time**: 2-3 days  
**Coverage Impact**: +8-12%

---

### **6. Health Monitoring** (`canonical-modernization/src/health_monitoring.rs`) - **0% coverage**

**Test Strategy**:
```rust
#[cfg(test)]
mod tests {
    use super::*;
    
    #[tokio::test]
    async fn test_health_check_system() {
        let monitor = HealthMonitor::new();
        let status = monitor.check().await;
        assert!(matches!(status, HealthStatus::Healthy));
    }
    
    #[tokio::test]
    async fn test_health_degradation_detection() {
        // Test detecting unhealthy states
    }
}
```

**Estimated Tests**: 15-20 tests  
**Estimated Time**: 1 day  
**Coverage Impact**: +3-5%

---

## 🎯 Priority 2: Medium Coverage Modules (30-70%)

These modules have some tests but need more comprehensive coverage.

### **7. Context Manager** (`core/context/src/manager/mod.rs`) - **18% coverage**

**Estimated Tests**: 20-25 tests  
**Estimated Time**: 1-2 days  
**Coverage Impact**: +5-8%

### **8. Canonical Errors** (`canonical-errors/src/`) - **Mixed 16-92%**

**Modules Needing More Tests**:
- `implementations.rs` (16%) - Needs 20-25 tests
- `domain_bridges.rs` (40%) - Needs 15-20 tests
- `safe_operations.rs` (45%) - Needs 15-20 tests

**Estimated Tests**: 50-65 tests  
**Estimated Time**: 2-3 days  
**Coverage Impact**: +8-10%

### **9. Service Discovery Client** (`service-discovery/src/lib.rs`) - **35% coverage**

**Estimated Tests**: 30-35 tests  
**Estimated Time**: 1-2 days  
**Coverage Impact**: +5-8%

### **10. Capability Discovery** (`universal-patterns/src/capability_discovery.rs`) - **17% coverage**

**Estimated Tests**: 25-30 tests  
**Estimated Time**: 1-2 days  
**Coverage Impact**: +5-7%

---

## 📊 Coverage Roadmap

### **Week 1: High-Priority Zero Coverage** (+25-30% coverage)
- Day 1-2: Learning engine (50-60 tests)
- Day 3-4: Plugin system (60-70 tests)
- Day 5: Canonical config (40-50 tests)
- **Result**: 53.67% → 78-83%

### **Week 2: Complete Priority 1** (+8-10% coverage)
- Day 1-2: Rule system (40-50 tests)
- Day 3: Visualization system (25-30 tests)
- Day 4: Health monitoring (15-20 tests)
- Day 5: Buffer/Polish
- **Result**: 78-83% → 86-93%

### **Week 3: Priority 2 + Integration** (+4-7% coverage)
- Day 1-2: Canonical errors, context manager
- Day 3-4: Service discovery, capability discovery
- Day 5: Integration tests (cross-module)
- **Result**: 86-93% → 90%+

### **Week 4: Polish & E2E** (Maintain 90%+)
- E2E workflow tests
- Chaos/fault injection tests
- Load testing scenarios
- Documentation updates

---

## 🛠️ Test Infrastructure Already Available

✅ **Mock Infrastructure** (2,184 instances):
- `test-utils/src/ai_mocks.rs` (161 AI provider mocks)
- `test-utils/src/ai_provider_mocks.rs` (80 provider mocks)
- `test-utils/src/mock_factories.rs` (70 mock factories)
- `test-utils/src/adapter_helpers.rs` (22 adapter mocks)
- `universal-patterns/src/helpers/mock.rs` (27 pattern mocks)

✅ **Test Helpers**:
- `test-utils/src/integration_helpers.rs`
- `test-utils/src/network_fixtures.rs`
- `test-utils/src/fixtures.rs`
- `test-utils/src/assertions.rs`

✅ **Testing Patterns**: 665 existing tests to reference

---

## 📝 Test Writing Guidelines

### **1. Use Existing Mocks**
```rust
use test_utils::ai_mocks::MockAIProvider;
use test_utils::network_fixtures::create_test_config;

#[tokio::test]
async fn test_with_mocks() {
    let provider = MockAIProvider::new();
    let config = create_test_config();
    // Test logic
}
```

### **2. Follow Existing Patterns**
Look at well-tested modules for patterns:
- `canonical-config/src/unified/network/http.rs` (100%)
- `universal-constants/src/` (92-100%)
- `services/commands/src/` (75-99%)
- `universal-patterns/src/types/canonical_health.rs` (99.63%)

### **3. Test Categories**
- **Unit Tests**: Test individual functions
- **Integration Tests**: Test module interactions
- **Property Tests**: Test invariants (use proptest if needed)
- **Error Cases**: Test error handling
- **Edge Cases**: Test boundary conditions

### **4. Coverage Focus**
Prioritize:
1. Public API functions (most important)
2. Business logic (high value)
3. Error paths (often missed)
4. Edge cases (prevent bugs)
5. Happy paths (baseline)

---

## 🚀 Quick Start Commands

### **Run Tests for Specific Module**
```bash
# Test learning system
cargo test --package squirrel-context --lib learning

# Test plugin system  
cargo test --package squirrel-plugins --lib

# Test canonical config
cargo test --package canonical-config --lib

# Test with coverage
cargo llvm-cov --package squirrel-context --lib --html
```

### **Add Tests Incrementally**
```bash
# 1. Create test file (if doesn't exist)
touch crates/core/context/src/learning/tests.rs

# 2. Add to mod.rs
# mod tests;  (in learning/mod.rs with #[cfg(test)])

# 3. Write tests
# Use existing test patterns as reference

# 4. Run tests
cargo test --package squirrel-context --lib learning::tests

# 5. Check coverage
cargo llvm-cov --package squirrel-context --lib --html
```

---

## 📈 Expected Outcomes

### **End of Week 1** (Target: 78-83%)
- ✅ Learning engine fully tested
- ✅ Plugin system core tested
- ✅ Canonical config tested
- ✅ ~150-180 new tests
- 🎯 Grade: A → A+ (93/100)

### **End of Week 2** (Target: 86-93%)
- ✅ Rule system tested
- ✅ Visualization tested
- ✅ Health monitoring tested
- ✅ ~230-260 total new tests
- 🎯 Grade: A+ (95/100)

### **End of Week 3** (Target: 90%+)
- ✅ All P1 modules at 90%+
- ✅ P2 modules improved
- ✅ Integration tests added
- ✅ ~300-350 total new tests
- 🎯 Grade: A++ (98/100)

### **End of Week 4** (Target: 90%+ maintained)
- ✅ E2E tests complete
- ✅ Chaos tests implemented
- ✅ Load tests validated
- ✅ ~350-400 total new tests
- 🎯 **Production Ready** 🚀

---

## 🎯 Success Metrics

| Week | Coverage Target | New Tests | Grade | Status |
|------|----------------|-----------|-------|--------|
| 0 (Now) | 53.67% | 665 | A (91.1) | ✅ Current |
| 1 | 78-83% | +150-180 | A+ (93) | 🎯 Target |
| 2 | 86-93% | +230-260 | A+ (95) | 🎯 Target |
| 3 | 90%+ | +300-350 | A++ (98) | 🎯 Target |
| 4 | 90%+ | +350-400 | S (99) | 🚀 Production |

---

## 📁 Key Files to Reference

### **Well-Tested Examples** (Copy Patterns)
1. `crates/canonical-config/src/unified/network/http.rs` (100%)
2. `crates/universal-patterns/src/types/canonical_health.rs` (99.63%)
3. `crates/services/commands/src/journal/recovery.rs` (100%)
4. `crates/services/commands/src/journal/entry.rs` (99.33%)
5. `crates/universal-constants/src/api.rs` (100%)

### **Modules to Test** (Low Coverage)
1. `crates/core/context/src/learning/` (0-27%)
2. `crates/core/plugins/src/` (0-20%)
3. `crates/core/context/src/rules/` (0%)
4. `crates/core/context/src/visualization/` (0%)
5. `crates/canonical-config/src/lib.rs` (0%)

---

## 💡 Pro Tips

1. **Start with easy wins**: Test pure functions first
2. **Use existing mocks**: Don't recreate infrastructure
3. **Copy test patterns**: Reference well-tested modules
4. **Run tests frequently**: `cargo test --lib` after each test
5. **Check coverage**: `cargo llvm-cov --html` to verify impact
6. **Focus on value**: Test critical business logic first
7. **Test errors**: Error paths are often missed
8. **Document tests**: Clear test names and comments

---

## 🎯 Next Action

```bash
# 1. Open coverage report
xdg-open target/llvm-cov/html/index.html

# 2. Start with learning engine tests (highest impact)
cd crates/core/context/src/learning/
# Add tests to engine.rs, manager.rs, etc.

# 3. Run tests
cargo test --package squirrel-context --lib learning

# 4. Check progress
cargo llvm-cov --package squirrel-context --lib --html
```

---

**Created**: November 3, 2025  
**Status**: Ready to execute  
**Timeline**: 2-4 weeks to 90% coverage  
**Confidence**: High (infrastructure ready, clear targets)

🚀 **Let's reach 90% coverage!** 🚀

