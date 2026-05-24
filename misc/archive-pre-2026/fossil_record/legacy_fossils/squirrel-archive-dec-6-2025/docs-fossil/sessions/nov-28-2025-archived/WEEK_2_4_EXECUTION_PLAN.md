# 🚀 Week 2-4 Execution Plan - Squirrel Universal AI Primal

**Created**: November 28, 2025  
**Scope**: Weeks 2-4 of 12-week roadmap  
**Total Effort**: 70-80 hours  
**Target Grade**: 80/100 (B-) → 84/100 (B)

---

## 📋 EXECUTION STATUS

**Phase**: IN PROGRESS  
**Started**: November 28, 2025  
**Completion**: 5% (directory structure created, plans documented)

---

## ✅ COMPLETED

1. ✅ Comprehensive audit report (COMPREHENSIVE_CODE_AUDIT_REPORT_NOV_27_2025.md)
2. ✅ Created directory structure: `crates/core/context/src/visualization/types/`
3. ✅ Created types/mod.rs with re-exports
4. ✅ This execution plan document

---

## 🎯 WEEK 2 TASKS (15-20 hours)

### Task 1: Refactor visualization/types.rs (3-4h) ⚠️ IN PROGRESS

**Status**: 20% complete (directory + mod.rs done)  
**Remaining**: Create core.rs, config.rs, theme.rs, display.rs

**Steps**:
```bash
cd /home/eastgate/Development/ecoPrimals/squirrel

# 1. Create core.rs (lines 12-323 from original)
# Contains: VisualizationType, VisualizationRequest, VisualizationResponse,
#           VisualizationConfig, DataPoint, VisualizationSeries,
#           InteractiveElement, FilterConfig, AxisConfig, TickConfig,
#           LegendConfig, TooltipConfig

# 2. Create theme.rs (lines 105-188 + defaults)
# Contains: VisualizationTheme, VisualizationLayout, MarginConfig, PaddingConfig

# 3. Create config.rs (lines 190-246 + defaults)
# Contains: GridConfig, AnimationConfig, ExportConfig, QualityConfig

# 4. Create display.rs (lines 507-537)
# Contains: Display impl, FromStr impl for VisualizationType

# 5. Move tests to appropriate modules or keep in types_tests.rs

# 6. Update imports throughout codebase
grep -r "use.*visualization::types::" crates/core/context/src/

# 7. Delete original types.rs
rm crates/core/context/src/visualization/types.rs

# 8. Verify
cargo build
cargo test visualization::types
```

**Success Criteria**:
- [ ] All new files <400 lines
- [ ] All tests passing
- [ ] No import errors
- [ ] Backward compatibility maintained

---

### Task 2: Refactor multi_agent/mod.rs (2-3h) ⚠️ PENDING

**Current**: 1,079 lines  
**Target**: <1000 lines split into 3 modules

**Plan**:
```bash
mkdir -p crates/core/mcp/src/enhanced/multi_agent/{coordinator,session,types}

# Split into:
# - coordinator.rs (~350 lines) - Agent coordination logic
# - session.rs (~350 lines) - Session management
# - types.rs (~350 lines) - Type definitions
# - mod.rs (~50 lines) - Re-exports
```

**P2 TODOs in this file**:
- Line 229: Implement collaboration session management
- Line 241: Implement conversation management

**Action**: Complete TODOs as part of refactoring

---

### Task 3: Refactor server.rs (2-3h) ⚠️ PENDING

**Current**: 1,040 lines  
**Target**: <1000 lines split into modules

**Plan**:
```bash
mkdir -p crates/core/mcp/src/server/{handlers,lifecycle}

# Split into:
# - handlers.rs (~400 lines) - Request handlers
# - lifecycle.rs (~300 lines) - Server lifecycle management  
# - mod.rs (~340 lines) - Core server logic (from 1040)
```

---

### Task 4: Refactor sync.rs (2-3h) ⚠️ PENDING

**Current**: 1,036 lines  
**Target**: <1000 lines split into modules

**Plan**:
```bash
mkdir -p crates/core/context/src/sync/{state,handlers}

# Split into:
# - state.rs (~400 lines) - State management
# - handlers.rs (~350 lines) - Event handlers
# - mod.rs (~286 lines) - Core sync logic
```

---

### Task 5: Fix visualization test compilation (2-3h) ⚠️ PENDING

**Issue**: 25 test compilation errors  
**Location**: `crates/core/context/src/visualization/mod.rs:16`

**TODO Comment**:
```rust
// TODO: Fix 25 test compilation errors (P2, 2-3h effort)
```

**Action**:
1. Uncomment tests in mod.rs
2. Fix API mismatches
3. Update test expectations
4. Ensure all pass

---

### Task 6: Resolve module structure ambiguities (3-4h) ⚠️ PENDING

**Location**: `crates/core/mcp/src/error/types/mod.rs:75`

**TODO Comment**:
```rust
// TODO(module-structure): Fix enhanced module structure ambiguities
```

**Action**:
1. Review enhanced module exports
2. Fix ambiguous re-exports
3. Clarify public API surface
4. Document module organization

---

### Task 7: Unwrap Reduction Phase 1 (5-8h) ⚠️ PENDING

**Goal**: Reduce unwraps from 2,963 → 2,663 (-300)

**Strategy** (from UNWRAP_REDUCTION_PLAN.md):
1. Configuration files - Replace with `unwrap_or_default()`
2. String conversions - Add fallbacks
3. Test utilities - Move to test helpers

**Target Files**:
```
config.rs: 12 unwraps → 0
monitoring/metrics.rs: 38 unwraps → 20 (-18)
universal_adapters/registry.rs: 5 unwraps → 0
[Other files]: ~270 unwraps
```

**Pattern**:
```rust
// BAD
let value = map.get("key").unwrap();

// GOOD
let value = map.get("key").ok_or(Error::KeyNotFound)?;
```

**Automation Script**:
```bash
#!/bin/bash
# unwrap_reducer_phase1.sh

echo "Phase 1: Unwrap Reduction"
echo "=========================="

# Find all unwraps in production code
echo "Finding unwraps in production code..."
find crates/main/src crates/core -name "*.rs" \
  ! -path "*/tests/*" ! -name "*_test*.rs" \
  -exec grep -l "\.unwrap()" {} \; > unwrap_files.txt

echo "Found $(wc -l < unwrap_files.txt) files with unwraps"

# Priority files
PRIORITY_FILES=(
  "crates/main/src/config.rs"
  "crates/main/src/monitoring/metrics.rs"
  "crates/main/src/universal_adapters/registry.rs"
)

echo "
Priority files for Phase 1:
"
for file in "${PRIORITY_FILES[@]}"; do
  count=$(grep -c "\.unwrap()" "$file" 2>/dev/null || echo "0")
  echo "  $file: $count unwraps"
done

echo "
Run manual review and replacement for each file.
"
```

---

## 🎯 WEEK 3 TASKS (25-30 hours)

### Task 8: Implement AI Inference Integration (6-8h) ⚠️ PENDING

**Location**: `crates/main/src/primal_provider/ai_inference.rs:134`  
**Priority**: P2 (High)

**TODO Comment**:
```rust
// TODO: Integrate with squirrel-ai-tools for real AI inference
```

**Current**: Using template stubs  
**Target**: Real AI inference with squirrel-ai-tools

**Implementation**:
```rust
// Replace in ai_inference.rs
use crates::tools::ai_tools::{AnthropicClient, OpenAIClient, GeminiClient};

async fn handle_inference(request: InferenceRequest) -> Result<InferenceResponse> {
    let client = match request.provider {
        "anthropic" => Box::new(AnthropicClient::new(api_key)?),
        "openai" => Box::new(OpenAIClient::new(api_key)?),
        "gemini" => Box::new(GeminiClient::new(api_key)?),
        _ => return Err(Error::UnsupportedProvider),
    };
    
    client.complete(request.prompt, request.options).await
}
```

**Tests Required**:
- Integration tests with mock AI clients
- Error handling for API failures
- Rate limiting tests
- Token usage tracking

---

### Task 9: Enable 5 Chaos Tests with Mocks (6-8h) ⚠️ PENDING

**Reference**: CHAOS_TEST_IMPLEMENTATION_GUIDE.md

**Current**: 15 chaos tests all #[ignore]d  
**Target**: 5 runnable with lightweight mocks

**Implementation Plan**:

1. **Create Mock Service Framework** (2h)
```rust
// tests/chaos/mock_services.rs

pub struct MockService {
    port: u16,
    responses: Arc<RwLock<HashMap<String, String>>>,
    shutdown_tx: Option<oneshot::Sender<()>>,
}

impl MockService {
    pub async fn start(port: u16) -> Self {
        // Implement lightweight HTTP mock server
    }
    
    pub fn set_response(&mut self, path: &str, response: &str) {
        // Set mock responses
    }
    
    pub async fn shutdown(self) {
        // Graceful shutdown
    }
}
```

2. **Enable Tests** (4-6h)
```rust
// tests/chaos_testing.rs

#[tokio::test] // Remove #[ignore]
async fn chaos_01_basic_timeout() -> ChaosResult<()> {
    let mock = MockService::start_with_delay(8080, Duration::from_secs(5)).await;
    // Test implementation
}

#[tokio::test] // Remove #[ignore]
async fn chaos_02_connection_refused() -> ChaosResult<()> {
    // No service needed - test connection refused
}

// Enable 3 more tests...
```

**Tests to Enable**:
1. ✅ chaos_01_basic_timeout
2. ✅ chaos_02_connection_refused
3. ✅ chaos_03_invalid_response
4. ✅ chaos_04_rate_limiting
5. ✅ chaos_05_intermittent_failures

---

### Task 10-11: Add 200 Unit Tests (20-25h) ⚠️ PENDING

**Goal**: Add 200 unit tests (2 batches of 100 each)

**Strategy**:
1. Focus on uncovered modules (from llvm-cov report)
2. Prioritize business logic
3. Cover error paths
4. Test edge cases

**Priority Modules** (from audit, <50% coverage):
- `crates/core/mcp/src/enhanced/multi_agent/` (~40%)
- `crates/providers/local/src/native/runtime.rs` (stubs)
- `crates/tools/ai-tools/src/local/native.rs` (~50%)
- `crates/core/mcp/src/enhanced/workflow/` (~40%)

**Test Template**:
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_[feature]_[scenario]_[expected_result]() {
        // Arrange
        let input = setup_test_data();
        
        // Act
        let result = function_under_test(input);
        
        // Assert
        assert!(result.is_ok());
        assert_eq!(result.unwrap(), expected_value);
    }
    
    #[tokio::test]
    async fn test_async_[feature]_[scenario]() {
        // Async test implementation
    }
}
```

**Coverage Target**: 55.5% → 60% (+4.5pp)

---

## 🎯 WEEK 4 TASKS (30-35 hours)

### Task 12-13: Add 200 More Unit Tests (20-25h) ⚠️ PENDING

**Goal**: Add another 200 unit tests (2 batches of 100)

**Focus Areas**:
- Configuration edge cases
- Error recovery paths
- Resilience patterns
- Integration points

**Coverage Target**: 60% → 65% (+5pp)

---

### Task 14: Migrate Hardcoded Values (6-8h) ⚠️ PENDING

**Current**: 840 hardcoded values (localhost, ports, IPs)  
**Target**: Migrate to universal-constants or config

**Pattern**:
```rust
// BAD
let endpoint = "http://localhost:8080";

// GOOD
use universal_constants::network::*;
let endpoint = format!("http://{}:{}", DEFAULT_HOST, get_port_from_config());
```

**Files to Update**:
```bash
# Find hardcoded values
grep -rn "localhost\|127\.0\.0\.1\|:8080\|:3000" crates/main/src crates/core

# Common patterns:
# - localhost → from config or env
# - 8080 → PORT env var or config
# - 127.0.0.1 → BIND_ADDR env var
# - Hardcoded timeouts → TIMEOUT_MS constants
```

---

### Task 15: Final Week 4 Verification (2-3h) ⚠️ PENDING

**Verification Checklist**:

```bash
#!/bin/bash
# week4_verification.sh

echo "Week 4 Verification"
echo "=================="

# 1. Build check
echo "1. Checking build..."
cargo build --workspace 2>&1 | tee build.log
if [ $? -eq 0 ]; then
    echo "✅ Build passing"
else
    echo "❌ Build failing"
    exit 1
fi

# 2. Test check
echo "2. Running tests..."
cargo test --workspace --lib 2>&1 | tee test.log
TESTS_PASSED=$(grep "test result:" test.log | grep -o "[0-9]* passed" | cut -d' ' -f1)
echo "✅ $TESTS_PASSED tests passing"

# 3. Coverage check
echo "3. Checking coverage..."
cargo llvm-cov --workspace --lib --html
COVERAGE=$(grep -o '[0-9]*\.[0-9]*%' target/llvm-cov/html/index.html | head -1)
echo "📊 Coverage: $COVERAGE (target: 60%)"

# 4. File size compliance
echo "4. Checking file sizes..."
FILES_OVER_1000=$(find crates -name "*.rs" -not -path "*/target/*" -exec wc -l {} \; | awk '$1 > 1000' | wc -l)
echo "📏 Files >1000 lines: $FILES_OVER_1000 (target: 0)"

# 5. Unwrap count
echo "5. Counting unwraps..."
UNWRAPS=$(find crates/main/src crates/core -name "*.rs" ! -path "*/tests/*" -exec grep -o "\.unwrap()" {} \; | wc -l)
echo "⚠️  Production unwraps: $UNWRAPS (target: <2000)"

# 6. Linting
echo "6. Running clippy..."
cargo clippy --workspace 2>&1 | grep "warning\|error" | wc -l
echo "✅ Clippy check complete"

# 7. Formatting
echo "7. Checking formatting..."
cargo fmt --all -- --check
if [ $? -eq 0 ]; then
    echo "✅ Formatting compliant"
else
    echo "⚠️  Formatting issues found"
fi

echo "
Summary:
========
Build: ✅
Tests: $TESTS_PASSED passing
Coverage: $COVERAGE
Files >1000 lines: $FILES_OVER_1000
Unwraps: $UNWRAPS
"
```

**Expected Results**:
- ✅ Build passing (0 errors)
- ✅ 454+ tests passing (254 + 200 new)
- ✅ 60-65% test coverage
- ✅ 0 files >1000 lines
- ✅ <2,663 unwraps in production
- ✅ 0 clippy errors
- ✅ 100% formatting compliance

**Grade Target**: 84/100 (B)

---

## 📊 PROGRESS TRACKING

### Weekly Milestones

| Week | Tasks | Hours | Grade | Status |
|------|-------|-------|-------|--------|
| 2 | File refactoring + fixes | 15-20 | 81/100 | 🟡 In Progress |
| 3 | AI integration + tests | 25-30 | 82/100 | ⚪ Pending |
| 4 | More tests + hardcoding | 30-35 | 84/100 | ⚪ Pending |
| **Total** | **15 tasks** | **70-85h** | **+4 points** | **5% Done** |

### Task Completion

- [x] Task 0: Audit complete (pre-work)
- [ ] Task 1: visualization/types.rs (20% done)
- [ ] Task 2: multi_agent/mod.rs
- [ ] Task 3: server.rs
- [ ] Task 4: sync.rs
- [ ] Task 5: Visualization tests
- [ ] Task 6: Module structure
- [ ] Task 7: Unwrap reduction
- [ ] Task 8: AI inference
- [ ] Task 9: Chaos tests
- [ ] Task 10: Tests batch 1
- [ ] Task 11: Tests batch 2
- [ ] Task 12: Tests batch 3
- [ ] Task 13: Tests batch 4
- [ ] Task 14: Hardcoding migration
- [ ] Task 15: Verification

**Completion**: 1/16 tasks (6%)

---

## 🔧 QUICK REFERENCE COMMANDS

### Build & Test
```bash
cd /home/eastgate/Development/ecoPrimals/squirrel

# Full build
cargo build --workspace

# Run tests
cargo test --workspace --lib

# Run specific test
cargo test --package squirrel-context --lib visualization::types

# Coverage
cargo llvm-cov --workspace --lib --html
firefox target/llvm-cov/html/index.html

# Formatting
cargo fmt --all

# Linting
cargo clippy --workspace --all-targets
```

### Analysis
```bash
# Count unwraps in production
find crates/main/src crates/core -name "*.rs" \
  ! -path "*/tests/*" ! -name "*_test*.rs" \
  -exec grep -c "\.unwrap()" {} + | awk -F: '{sum+=$2} END {print sum}'

# Find files >1000 lines
find crates -name "*.rs" -not -path "*/target/*" \
  -exec wc -l {} \; | awk '$1 > 1000 {print $2 ": " $1 " lines"}'

# Find hardcoded values
grep -rn "localhost\|127\.0\.0\.1\|:8080" crates/main/src

# Count tests
grep -rn "#\[test\]\\|#\[tokio::test\]" crates/ --include="*.rs" | wc -l
```

---

## 📝 NOTES

### Critical Paths
1. File refactoring MUST complete before other work (reduces merge conflicts)
2. Visualization tests MUST be fixed before adding coverage
3. AI inference integration BLOCKS local model work
4. Chaos test framework ENABLES remaining chaos tests

### Dependencies
- Task 1-4 (file refactoring) are independent, can be parallelized
- Task 5 depends on Task 1
- Task 8 blocks local AI work
- Task 9 provides framework for future chaos tests
- Tasks 10-13 (tests) are mostly independent

### Risks
1. **Scope Creep**: 70-80 hours is substantial - resist adding more
2. **Test Quality**: Don't sacrifice quality for quantity
3. **Breaking Changes**: File refactoring could break imports
4. **Integration**: AI inference needs real API testing

### Success Factors
1. ✅ Clear, mechanical tasks (file refactoring)
2. ✅ Detailed plans exist (UNWRAP_REDUCTION_PLAN.md, CHAOS_TEST_IMPLEMENTATION_GUIDE.md)
3. ✅ Baseline established (audit report)
4. ✅ Automation scripts provided
5. ⚠️ Requires sustained effort over 3 weeks

---

## 🚀 NEXT STEPS

### Immediate (This Week)
1. Complete visualization/types.rs refactoring
2. Refactor remaining 3 files
3. Fix visualization tests
4. Start unwrap reduction

### Week 3
1. Implement AI inference integration
2. Create chaos test framework
3. Add 200 unit tests

### Week 4
1. Add 200 more unit tests
2. Migrate hardcoded values
3. Run final verification
4. Update STATUS.md with progress

---

## ✅ DEFINITION OF DONE

**Week 4 Complete When**:
- [ ] All 5 files <1000 lines (100% compliance)
- [ ] 454+ tests passing (254 → 454+)
- [ ] 60-65% test coverage (from 55.5%)
- [ ] <2,663 unwraps in production (from 2,963)
- [ ] 5 chaos tests enabled and passing
- [ ] AI inference using real clients (not stubs)
- [ ] <840 hardcoded values migrated to config
- [ ] Build passing, 0 errors
- [ ] Clippy clean (warnings only)
- [ ] Grade 84/100 (B) achieved

---

**Document Created**: November 28, 2025  
**Author**: AI Code Analysis System  
**Status**: Living document - update as work progresses  
**Next Review**: After Week 2 completion

*"Reality > Hype. Truth > Marketing. Safety > Speed."* ✅

