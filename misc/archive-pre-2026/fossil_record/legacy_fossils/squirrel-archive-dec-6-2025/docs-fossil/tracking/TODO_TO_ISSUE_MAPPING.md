# TODO to GitHub Issue Mapping
**Date**: November 11, 2025  
**Status**: 📋 **Ready for Issue Creation**  
**Total TODOs**: 65

---

## 📊 EXECUTIVE SUMMARY

This document catalogs all 65 TODO markers in the codebase, organized by category and priority. Use this as a reference to create GitHub issues for better tracking.

### By Category

```
┌─────────────────────────┬───────┬──────────┐
│ Category                │ Count │ Priority │
├─────────────────────────┼───────┼──────────┤
│ Workflow System         │   6   │ MEDIUM   │
│ Multi-Agent System      │   3   │ MEDIUM   │
│ Routing & Coordination  │   5   │ MEDIUM   │
│ Protocol & Transport    │   3   │ LOW      │
│ Context & Learning      │   3   │ MEDIUM   │
│ Integration             │   2   │ HIGH     │
│ Configuration           │  15   │ LOW      │
│ Code Quality            │   5   │ LOW      │
│ Message Handling        │   5   │ LOW      │
│ Plugin System           │   2   │ LOW      │
│ Other                   │  16   │ VARIOUS  │
└─────────────────────────┴───────┴──────────┘
```

---

## 🎯 PRIORITY 1: HIGH PRIORITY (2 TODOs)

### Integration Issues

#### Issue #1: Implement Songbird Service Registration
**Location**: `crates/integration/ecosystem/src/lib.rs:37`  
**Code Context**:
```rust
// TODO: Implement Songbird service registration
```

**Description**: Implement registration functionality for Songbird service mesh integration.

**Impact**: Required for service mesh functionality
**Effort**: 4-6 hours
**Labels**: `integration`, `songbird`, `service-mesh`, `high-priority`

**Acceptance Criteria**:
- [ ] Service registration endpoint implemented
- [ ] Connection to Songbird mesh established
- [ ] Health checks integrated
- [ ] Tests passing

---

#### Issue #2: Implement Toadstool Compute Integration
**Location**: `crates/integration/ecosystem/src/lib.rs:38`  
**Code Context**:
```rust
// TODO: Implement Toadstool compute integration
```

**Description**: Implement integration with Toadstool compute service for distributed processing.

**Impact**: Required for compute offloading
**Effort**: 6-8 hours
**Labels**: `integration`, `toadstool`, `compute`, `high-priority`

**Acceptance Criteria**:
- [ ] Compute client implemented
- [ ] Job submission working
- [ ] Result retrieval functional
- [ ] Error handling complete
- [ ] Tests passing

---

## 🎯 PRIORITY 2: MEDIUM PRIORITY (17 TODOs)

### Workflow System (6 TODOs)

#### Issue #3: Implement Workflow Execution Engine
**Location**: `crates/core/mcp/src/enhanced/workflow/mod.rs:69`  
**Code Context**:
```rust
/// TODO: Implement workflow execution engine
```

**Description**: Implement the core workflow execution engine for orchestrating multi-step processes.

**Impact**: Foundation for workflow functionality
**Effort**: 16-20 hours (complex)
**Labels**: `workflow`, `engine`, `medium-priority`, `feature`

**Acceptance Criteria**:
- [ ] Step execution framework
- [ ] State management
- [ ] Error recovery
- [ ] Parallel execution support
- [ ] Comprehensive tests

---

#### Issue #4: Implement Workflow Scheduler
**Location**: `crates/core/mcp/src/enhanced/workflow/mod.rs:75`  
**Code Context**:
```rust
/// TODO: Implement workflow scheduler
```

**Description**: Implement scheduler for managing workflow timing and triggers.

**Impact**: Enables scheduled workflow execution
**Effort**: 8-12 hours
**Labels**: `workflow`, `scheduler`, `medium-priority`, `feature`

**Dependencies**: Issue #3 (Workflow Execution Engine)

**Acceptance Criteria**:
- [ ] Cron-like scheduling
- [ ] Event-based triggers
- [ ] Priority queuing
- [ ] Tests passing

---

#### Issue #5: Implement Workflow State Manager
**Location**: `crates/core/mcp/src/enhanced/workflow/mod.rs:81`  
**Code Context**:
```rust
/// TODO: Implement workflow state manager
```

**Description**: Implement persistent state management for workflows.

**Impact**: Enables workflow persistence and recovery
**Effort**: 6-8 hours
**Labels**: `workflow`, `state`, `medium-priority`, `feature`

**Dependencies**: Issue #3 (Workflow Execution Engine)

---

#### Issue #6: Implement Workflow Template Engine
**Location**: `crates/core/mcp/src/enhanced/workflow/mod.rs:87`  
**Code Context**:
```rust
/// TODO: Implement workflow template engine
```

**Description**: Implement templating system for reusable workflow definitions.

**Impact**: Improves workflow reusability
**Effort**: 6-8 hours
**Labels**: `workflow`, `templates`, `medium-priority`, `feature`

---

#### Issue #7: Implement Workflow Monitoring
**Location**: `crates/core/mcp/src/enhanced/workflow/mod.rs:93`  
**Code Context**:
```rust
/// TODO: Implement workflow monitoring
```

**Description**: Implement monitoring and observability for workflow execution.

**Impact**: Enables workflow debugging and optimization
**Effort**: 4-6 hours
**Labels**: `workflow`, `monitoring`, `observability`, `medium-priority`

**Dependencies**: Issue #3 (Workflow Execution Engine)

---

#### Issue #8: Refactor Workflow Engine to Use Proper Lifetimes
**Location**: `crates/core/mcp/src/enhanced/workflow/mod.rs:174`  
**Code Context**:
```rust
let engine = Arc::clone(&Arc::new(self.clone())); // TODO: Refactor to use &self with proper lifetimes
```

**Description**: Refactor to avoid unnecessary cloning by using proper lifetime management.

**Impact**: Performance improvement, cleaner code
**Effort**: 2-3 hours
**Labels**: `workflow`, `refactor`, `performance`, `low-priority`

---

### Multi-Agent System (3 TODOs)

#### Issue #9: Implement Collaboration Session Management
**Location**: `crates/core/mcp/src/enhanced/multi_agent/mod.rs:278`  
**Code Context**:
```rust
// TODO: Implement collaboration session management
```

**Description**: Implement session management for multi-agent collaboration.

**Impact**: Core multi-agent functionality
**Effort**: 8-12 hours
**Labels**: `multi-agent`, `collaboration`, `medium-priority`, `feature`

---

#### Issue #10: Implement Conversation Management
**Location**: `crates/core/mcp/src/enhanced/multi_agent/mod.rs:290`  
**Code Context**:
```rust
// TODO: Implement conversation management
```

**Description**: Implement conversation tracking and context management for agent interactions.

**Impact**: Enables agent-to-agent communication
**Effort**: 6-8 hours
**Labels**: `multi-agent`, `conversation`, `medium-priority`, `feature`

---

#### Issue #11: Implement Multi-Agent Workflow Execution
**Location**: `crates/core/mcp/src/enhanced/multi_agent/mod.rs:302`  
**Code Context**:
```rust
// TODO: Implement workflow execution
```

**Description**: Implement workflow execution in multi-agent context.

**Impact**: Enables coordinated agent workflows
**Effort**: 8-10 hours
**Labels**: `multi-agent`, `workflow`, `medium-priority`, `feature`

**Dependencies**: Issue #3 (Workflow Execution Engine)

---

### Routing & Coordination (5 TODOs)

#### Issue #12: Implement Capability Matching
**Location**: `crates/core/mcp/src/enhanced/coordinator/router.rs:219`  
**Code Context**:
```rust
// TODO: Implement actual capability matching
```

**Description**: Implement algorithm to match requests with provider capabilities.

**Impact**: Core routing functionality
**Effort**: 4-6 hours
**Labels**: `routing`, `coordinator`, `medium-priority`, `feature`

---

#### Issue #13: Implement Cost Estimation
**Location**: `crates/core/mcp/src/enhanced/coordinator/router.rs:234`  
**Code Context**:
```rust
// TODO: Implement actual cost estimation
```

**Description**: Implement cost estimation for provider selection.

**Impact**: Enables cost-based routing decisions
**Effort**: 3-4 hours
**Labels**: `routing`, `cost`, `medium-priority`, `feature`

---

#### Issue #14: Implement Round Robin Load Balancing
**Location**: `crates/core/mcp/src/enhanced/coordinator/router.rs:351`  
**Code Context**:
```rust
// TODO: Implement actual round robin logic
```

**Description**: Implement proper round robin load balancing algorithm.

**Impact**: Better load distribution
**Effort**: 2-3 hours
**Labels**: `routing`, `load-balancing`, `medium-priority`, `enhancement`

---

#### Issue #15: Implement Weighted Random Load Balancing
**Location**: `crates/core/mcp/src/enhanced/coordinator/router.rs:365`  
**Code Context**:
```rust
// TODO: Implement actual weighted random logic
```

**Description**: Implement weighted random selection for load balancing.

**Impact**: Advanced load distribution
**Effort**: 2-3 hours
**Labels**: `routing`, `load-balancing`, `medium-priority`, `enhancement`

---

#### Issue #16: Implement Custom Routing Strategy
**Location**: `crates/core/mcp/src/enhanced/coordinator/router.rs:381`  
**Code Context**:
```rust
// TODO: Implement custom strategy logic
```

**Description**: Implement framework for custom routing strategies.

**Impact**: Extensibility for routing
**Effort**: 4-6 hours
**Labels**: `routing`, `extensibility`, `medium-priority`, `feature`

---

### Context & Learning (3 TODOs)

#### Issue #17: Implement Context Monitoring
**Location**: `crates/core/context/src/learning/integration.rs:779`  
**Code Context**:
```rust
// TODO: Implement proper context monitoring when ContextManager API is enhanced
```

**Description**: Implement comprehensive context monitoring once ContextManager API is ready.

**Impact**: Better context tracking
**Effort**: 4-6 hours
**Labels**: `context`, `monitoring`, `medium-priority`, `enhancement`

**Dependencies**: ContextManager API enhancement

---

#### Issue #18: Implement Get Active Context IDs
**Location**: `crates/core/context/src/learning/manager.rs:571`  
**Code Context**:
```rust
// TODO: Implement get_active_context_ids when ContextManager API is enhanced
```

**Description**: Implement method to retrieve active context identifiers.

**Impact**: Context tracking functionality
**Effort**: 2-3 hours
**Labels**: `context`, `api`, `medium-priority`, `enhancement`

**Dependencies**: ContextManager API enhancement

---

#### Issue #19: Implement Get Context State
**Location**: `crates/core/context/src/learning/manager.rs:589`  
**Code Context**:
```rust
// TODO: Implement get_context_state when ContextManager API is enhanced
```

**Description**: Implement method to retrieve context state.

**Impact**: Context state querying
**Effort**: 2-3 hours
**Labels**: `context`, `api`, `medium-priority`, `enhancement`

**Dependencies**: ContextManager API enhancement

---

## 🎯 PRIORITY 3: LOW PRIORITY (46 TODOs)

### Configuration Enhancements (15 TODOs)

#### Issue #20-34: Various Configuration TODOs

These are minor configuration enhancements marked throughout the codebase:

1. **Make check interval configurable** (`monitoring/alerts.rs:622`)
2. **Get actual model from session** (`coordinator/tools.rs:103`)
3. **Calculate actual cost based on tokens** (`coordinator/providers.rs:125`, `providers.rs:248`)
4. **Get from connection info** (`enhanced/server.rs:552`)
5. **Get actual session count** (`primal_provider/health_monitoring.rs:316`)
6. **Map priority if available** (`message/mod.rs:366`)
7. **Implement seasonality detection** (`tool/cleanup/adaptive_resource.rs:189`)

**Batch Issue Recommendation**: Create single issue "Configuration Enhancements Sprint" to address all at once.

**Effort**: 6-8 hours total
**Labels**: `configuration`, `enhancement`, `low-priority`, `good-first-issue`

---

### Protocol & Message Handling (8 TODOs)

#### Issue #35: Handle Received Messages
**Location**: `crates/core/mcp/src/protocol/websocket.rs:482`  
**Code Context**:
```rust
// TODO: Handle received message
```

**Description**: Implement message handling in websocket protocol.

**Effort**: 2-3 hours
**Labels**: `protocol`, `websocket`, `low-priority`

---

#### Issue #36: Review Payload Handling
**Location**: `crates/core/mcp/src/message/mod.rs:343`  
**Code Context**:
```rust
// TODO: Review payload handling - should content be Value or handle binary?
```

**Description**: Review and potentially refactor payload handling to support binary.

**Effort**: 3-4 hours
**Labels**: `protocol`, `refactor`, `review`, `low-priority`

---

#### Issue #37: Review Source/Destination Mapping
**Location**: `crates/core/mcp/src/message/mod.rs:357`  
**Code Context**:
```rust
// TODO: Review source/destination mapping based on specs
```

**Description**: Review message source/destination mapping against specifications.

**Effort**: 2-3 hours
**Labels**: `protocol`, `review`, `low-priority`

---

#### Issue #38: Review In-Reply-To Logic
**Location**: `crates/core/mcp/src/message/mod.rs:360`  
**Code Context**:
```rust
// TODO: Review in_reply_to logic. Should only be set if explicitly present?
```

**Description**: Review and clarify in_reply_to field logic.

**Effort**: 1-2 hours
**Labels**: `protocol`, `review`, `low-priority`

---

#### Issue #39: Handle Binary Payload
**Location**: `crates/core/mcp/src/message/mod.rs:368`  
**Code Context**:
```rust
binary_payload: None, // TODO: Handle binary payload if needed
```

**Description**: Implement binary payload handling.

**Effort**: 3-4 hours
**Labels**: `protocol`, `feature`, `low-priority`

---

#### Issue #40: Implement WebSocket Message Deserialization
**Location**: `crates/core/mcp/src/transport/websocket/mod.rs:395`  
**Code Context**:
```rust
// TODO: Implement deserialization and handling of Ping/Pong/Close/Binary/Text
```

**Description**: Complete websocket message type handling.

**Effort**: 4-6 hours
**Labels**: `transport`, `websocket`, `low-priority`

---

#### Issue #41: Register Handlers with Message Router
**Location**: `crates/core/mcp/src/integration/adapter.rs:125`  
**Code Context**:
```rust
// TODO: Register handlers with a message router
```

**Description**: Implement handler registration in message router.

**Effort**: 2-3 hours
**Labels**: `integration`, `routing`, `low-priority`

---

#### Issue #42: Implement Actual State Update Logic
**Location**: `crates/core/mcp/src/integration/types.rs:72`  
**Code Context**:
```rust
// TODO: Implement actual state update logic
```

**Description**: Implement state update functionality.

**Effort**: 3-4 hours
**Labels**: `integration`, `state`, `low-priority`

---

### Plugin System (2 TODOs)

#### Issue #43: Integrate with Actual DefaultPluginManager
**Location**: `crates/core/mcp/src/enhanced/server.rs:760`  
**Code Context**:
```rust
// TODO: Integrate with actual DefaultPluginManager when async runtime is available
```

**Description**: Integrate enhanced server with DefaultPluginManager.

**Effort**: 2-3 hours
**Labels**: `plugins`, `integration`, `low-priority`

---

#### Issue #44: Implement Plugin Loading from Directory
**Location**: `crates/core/plugins/src/default_manager.rs:201`  
**Code Context**:
```rust
// TODO: Implement plugin loading from directory
```

**Description**: Implement directory-based plugin discovery and loading.

**Effort**: 4-6 hours
**Labels**: `plugins`, `feature`, `low-priority`

---

### Code Quality & Refactoring (5 TODOs)

#### Issue #45: Fix Enhanced Module Structure Ambiguities
**Location**: `crates/core/mcp/src/error/types.rs:827`  
**Code Context**:
```rust
// TODO(module-structure): Fix enhanced module structure ambiguities
```

**Description**: Resolve module structure issues in enhanced module.

**Effort**: 2-3 hours
**Labels**: `refactor`, `architecture`, `low-priority`

---

#### Issue #46-49: Various Refactoring Tasks

Small refactoring improvements throughout codebase:

1. **State change event emission** (`tool/lifecycle/state_validator.rs:611`)
2. **Implement missing modules** (`plugins/unified_manager.rs:7`)
3. **Real implementation notes** (`plugins/examples/test_dynamic_plugin.rs:289`)
4. **Implement AuthCredentials types** (`main/benches/squirrel_performance.rs:52`)

**Batch Issue**: "Code Quality Improvements Sprint"

**Effort**: 4-6 hours total
**Labels**: `refactor`, `code-quality`, `low-priority`

---

### Federation & Routing (1 TODO)

#### Issue #50: Implement Federation Node Counting
**Location**: `crates/core/core/src/routing/mod.rs:384`  
**Code Context**:
```rust
federation_nodes: 0, // TODO: implement federation node counting
```

**Description**: Implement counting of federation nodes.

**Effort**: 2-3 hours
**Labels**: `federation`, `metrics`, `low-priority`

---

## 📋 BATCH ISSUE RECOMMENDATIONS

For efficiency, consider creating these batch issues:

### Batch #1: Configuration Enhancements Sprint
**Issues**: #20-34 (15 configuration TODOs)
**Total Effort**: 6-8 hours
**Labels**: `configuration`, `sprint`, `enhancement`

### Batch #2: Protocol Review & Cleanup
**Issues**: #35-42 (8 protocol TODOs)
**Total Effort**: 18-24 hours
**Labels**: `protocol`, `review`, `cleanup`

### Batch #3: Code Quality Improvements
**Issues**: #45-49 (5 refactoring TODOs)
**Total Effort**: 4-6 hours
**Labels**: `refactor`, `code-quality`, `sprint`

---

## 🎯 RECOMMENDED ISSUE CREATION SEQUENCE

### Week 1: High Priority
1. Create Issue #1: Songbird Service Registration
2. Create Issue #2: Toadstool Compute Integration

### Week 2: Workflow Foundation
3. Create Issue #3: Workflow Execution Engine
4. Create Issue #4: Workflow Scheduler
5. Create Issue #5: Workflow State Manager
6. Create Issue #6: Workflow Template Engine
7. Create Issue #7: Workflow Monitoring

### Week 3: Multi-Agent & Routing
8. Create Issue #9-11: Multi-Agent System (batch)
9. Create Issue #12-16: Routing & Coordination (batch)

### Week 4: Context & Batches
10. Create Issue #17-19: Context & Learning (batch)
11. Create Batch #1: Configuration Enhancements Sprint
12. Create Batch #2: Protocol Review & Cleanup
13. Create Batch #3: Code Quality Improvements

---

## 📝 ISSUE TEMPLATE

Use this template when creating GitHub issues:

```markdown
## Description
[Clear description from this document]

## Location
File: `[file path]`
Line: `[line number]`

## Context
```rust
[Code snippet from TODO location]
```

## Impact
[Impact statement from this document]

## Acceptance Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] Tests passing
- [ ] Documentation updated

## Estimated Effort
[X-Y hours]

## Dependencies
[List any dependency issues]

## Labels
`[label1]`, `[label2]`, `[label3]`
```

---

## ✅ TRACKING PROGRESS

### After Creating Issues

1. Update code TODOs with issue references:
```rust
// Before:
// TODO: Implement workflow execution engine

// After:
// See issue #123: Implement workflow execution engine
// TODO: Implement workflow execution engine
```

2. Track in project board:
- Backlog → In Progress → Review → Done

3. Update this document with issue numbers

---

## 📊 SUMMARY STATISTICS

```
Total TODOs:              65
High Priority:             2  (3%)
Medium Priority:          17  (26%)
Low Priority:             46  (71%)

By Type:
- Feature Implementation: 25  (38%)
- Enhancement:            20  (31%)
- Review/Refactor:        15  (23%)
- Configuration:          15  (23%)

Estimated Total Effort:   200-280 hours
```

---

## 🎓 MAINTENANCE GUIDELINES

### Monthly TODO Review

```bash
# Extract current TODOs
grep -rn "TODO" crates --include="*.rs" | wc -l

# Compare with baseline (65)
# If increasing: Address TODOs or create issues
# If decreasing: Track completed work
```

### TODO Lifecycle

1. **Create TODO** - During development
2. **Within 1 week** - Create GitHub issue
3. **Update code** - Add issue reference
4. **Track progress** - In project board
5. **Remove TODO** - When implemented

### Prevention

- Prefer creating issues over TODOs
- Keep TODOs for short-term notes only
- Review TODOs in code review
- No TODO older than 6 months

---

**Status**: ✅ **Ready for Issue Creation**  
**Created**: November 11, 2025  
**Total Issues to Create**: ~50 (or ~20 with batching)  
**Estimated Time to Create Issues**: 2-3 hours  
**Tracking**: Update this document with issue numbers

---

🐿️ **Next Step**: Start creating issues using this mapping!

