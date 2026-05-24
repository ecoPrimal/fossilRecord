# 🔧 UNWRAP MIGRATION PLAN - Systematic Error Handling Evolution

**Created**: Dec 4, 2025 Night  
**Status**: 🔄 IN PROGRESS  
**Goal**: Migrate production unwraps from 1,571 to <100

---

## 🎯 STRATEGY: Systematic, Risk-Based Migration

### Philosophy
**Not all unwraps are equal.** We prioritize by:
1. **Risk**: Config parsing > Network > File I/O > Internal data structures
2. **Context**: User-facing > Internal APIs > Private functions  
3. **Recoverability**: Can we handle the error gracefully?

### Approach
```rust
// ❌ BEFORE: Panic on error
let config = load_config(path).unwrap();

// ✅ AFTER: Return error with context
use anyhow::Context;
let config = load_config(path)
    .context(format!("Failed to load config from {}", path.display()))?;
```

---

## 📊 INVENTORY

### Total Production Unwraps: 1,571

**Distribution**:
- Config parsing: ~200 (🔴 HIGH RISK)
- Network operations: ~300 (🔴 HIGH RISK)
- File I/O: ~150 (🔴 HIGH RISK)
- Data structure manipulation: ~400 (🟡 MEDIUM)
- Internal utilities: ~521 (🟢 LOW)

---

## 🚨 PHASE 1: CRITICAL (Week 1) - Config Parsing

### Target Files (20 files, ~200 unwraps)

#### High Priority:
1. `config/environment.rs` - Environment variable parsing
2. `config/runtime/network.rs` - Network config loading
3. `config/sovereignty_config.rs` - Sovereignty config
4. `config/migration_helpers.rs` - Config fallbacks
5. `config/canonical_primary/*` - Canonical config system

### Pattern: Safe Constants → Proper Errors

**Current Pattern** (questionable):
```rust
// config/runtime/network.rs:67-71
.unwrap_or_else(|| {
    addresses::LOCALHOST_IPV4.parse().unwrap_or_else(|_| {
        "127.0.0.1"
            .parse()
            .expect("INVARIANT: '127.0.0.1' is a valid IpAddr")
    })
})
```

**Evolved Pattern**:
```rust
// Use const validation at compile time
const LOCALHOST: IpAddr = IpAddr::V4(Ipv4Addr::new(127, 0, 0, 1));

.unwrap_or(LOCALHOST)

// OR return Result:
fn parse_host(host: &str) -> Result<IpAddr> {
    host.parse()
        .or_else(|_| Ok(LOCALHOST))
        .context("Failed to parse host address")
}
```

### Estimated Impact:
- **Fixes**: ~200 config-related unwraps
- **Time**: 8-12 hours
- **Risk Reduction**: HIGH → LOW

---

## 🌐 PHASE 2: HIGH PRIORITY (Week 2) - Network Operations

### Target Files (~300 unwraps)

#### Critical Network Paths:
1. `network/client.rs` - HTTP client operations
2. `network/connection.rs` - Connection management
3. `network/native_async/*` - Async networking
4. Discovery backends - Service discovery

### Pattern: Network Errors → Graceful Degradation

**Current** (panic on network error):
```rust
let response = client.get(url).send().await.unwrap();
let data = response.json().unwrap();
```

**Evolved**:
```rust
let response = client
    .get(url)
    .send()
    .await
    .context("Failed to connect to service")?;

let data = response
    .json()
    .await
    .context("Failed to parse response JSON")?;
```

### Estimated Impact:
- **Fixes**: ~300 network unwraps
- **Time**: 12-16 hours
- **Risk Reduction**: HIGH → LOW

---

## 📁 PHASE 3: HIGH PRIORITY (Week 2-3) - File I/O

### Target Files (~150 unwraps)

#### File Operations:
1. Config file loading
2. Certificate reading
3. Log file operations
4. Cache persistence

### Pattern: File Errors → Descriptive Messages

**Current**:
```rust
let contents = fs::read_to_string(path).unwrap();
```

**Evolved**:
```rust
let contents = fs::read_to_string(&path)
    .with_context(|| format!("Failed to read file: {}", path.display()))?;
```

### Estimated Impact:
- **Fixes**: ~150 file I/O unwraps
- **Time**: 6-8 hours
- **Risk Reduction**: HIGH → LOW

---

## 🟡 PHASE 4: MEDIUM PRIORITY (Week 3-4) - Data Structures

### Target (~400 unwraps)

#### Common Patterns:
1. HashMap/BTreeMap lookups
2. Vector indexing
3. Option unwrapping
4. String parsing

### Pattern: Defensive Programming

**Current**:
```rust
let value = map.get(key).unwrap();
let item = vec[index];
```

**Evolved**:
```rust
let value = map
    .get(key)
    .ok_or_else(|| anyhow!("Key '{}' not found in map", key))?;

let item = vec
    .get(index)
    .ok_or_else(|| anyhow!("Index {} out of bounds", index))?;
```

### Estimated Impact:
- **Fixes**: ~400 data structure unwraps
- **Time**: 15-20 hours
- **Risk Reduction**: MEDIUM → LOW

---

## 🟢 PHASE 5: LOW PRIORITY (Week 4-5) - Internal Utilities

### Target (~521 unwraps)

#### Areas:
1. Test utilities (some are actually OK)
2. Internal transformations
3. Validated invariants

### Strategy: Evaluate Case-by-Case

Some unwraps are actually fine:
```rust
// ✅ OK: Const validation ensures this is valid
const DEFAULT_PORT: u16 = 8080;
let port = Port::new_unchecked(DEFAULT_PORT);

// ✅ OK: Just validated above
if value.is_some() {
    let inner = value.unwrap();  // Safe - just checked
}

// ❌ BAD: Could still fail
let parsed = "user_input".parse().unwrap();  // User input - NOT OK
```

### Estimated Impact:
- **Fixes**: ~200-300 (others are justified)
- **Time**: 10-15 hours
- **Risk Reduction**: LOW → MINIMAL

---

## 🛠️ TOOLS & AUTOMATION

### 1. Unwrap Migrator Tool
```bash
cd tools/unwrap-migrator
cargo run -- ../../code/crates/nestgate-core/src/config/
```

**Features**:
- Finds all unwraps/expects
- Suggests replacements
- Can auto-migrate simple cases
- Generates reports

### 2. Manual Review Script
```bash
# Find all production unwraps (excluding tests)
find code/crates -name "*.rs" \
    -not -path "*/tests/*" \
    -not -name "*test*.rs" \
    -exec grep -n "\.unwrap()\|\.expect(" {} + \
    | tee unwraps_to_review.txt
```

### 3. Clippy Lints
```toml
# Add to Cargo.toml
[lints.clippy]
unwrap_used = "warn"
expect_used = "warn"
panic = "warn"
```

---

## 📋 CHECKLIST: Per-File Migration

For each file:
- [ ] Identify all unwraps/expects
- [ ] Categorize by risk (CRITICAL/HIGH/MEDIUM/LOW)
- [ ] Migrate CRITICAL and HIGH first
- [ ] Add proper error context
- [ ] Update function signatures (add Result where needed)
- [ ] Update tests
- [ ] Verify builds
- [ ] Run tests
- [ ] Update documentation

---

## 🎯 MILESTONES

### Week 1 End:
- [ ] Config parsing complete (~200 fixed)
- [ ] Build passes
- [ ] Tests passing
- **Progress**: 1,571 → ~1,370 (13% reduction)

### Week 2 End:
- [ ] Network operations complete (~300 fixed)
- [ ] File I/O complete (~150 fixed)
- **Progress**: 1,370 → ~920 (42% total reduction)

### Week 3 End:
- [ ] Data structures complete (~400 fixed)
- **Progress**: 920 → ~520 (67% total reduction)

### Week 4 End:
- [ ] Internal utilities reviewed (~200-300 fixed)
- **Progress**: 520 → ~220-320 (80-86% reduction)

### Week 5 End:
- [ ] Final cleanup and review
- **Progress**: <100 production unwraps ✅
- **Goal**: 93%+ reduction achieved

---

## 📈 SUCCESS METRICS

### Target:
- **Start**: 1,571 production unwraps
- **Target**: <100 production unwraps
- **Reduction**: 93%+

### Quality Metrics:
- ✅ No panics in production code paths
- ✅ All errors have context
- ✅ Graceful error handling
- ✅ Descriptive error messages
- ✅ Proper error propagation

---

## 🔄 EXAMPLE MIGRATION

### Before (environment.rs):
```rust
pub fn bind_address(&self) -> SocketAddr {
    SocketAddr::new(
        self.network.host.parse().unwrap_or_else(|_| {
            IpAddr::from_str("127.0.0.1")
                .expect("SAFETY: '127.0.0.1' is a valid IP address literal")
        }),
        self.network.port.get(),
    )
}
```

### After (evolved):
```rust
pub fn bind_address(&self) -> Result<SocketAddr> {
    const LOCALHOST: IpAddr = IpAddr::V4(Ipv4Addr::new(127, 0, 0, 1));
    
    let ip = self.network.host
        .parse()
        .unwrap_or(LOCALHOST);  // Graceful fallback to const
    
    Ok(SocketAddr::new(ip, self.network.port.get()))
}

// OR if we want to surface the parse error:
pub fn bind_address(&self) -> Result<SocketAddr> {
    let ip = self.network.host
        .parse()
        .context("Failed to parse bind host address")?;
    
    Ok(SocketAddr::new(ip, self.network.port.get()))
}
```

---

## 🎓 BEST PRACTICES

### 1. Use `anyhow::Context`
```rust
use anyhow::{Context, Result};

file.read_to_string(&mut buf)
    .context("Failed to read config file")?;
```

### 2. Provide Helpful Messages
```rust
// ❌ BAD: Generic error
.context("Parse failed")?

// ✅ GOOD: Specific, actionable
.with_context(|| format!(
    "Failed to parse port '{}': must be between 1024-65535", 
    input
))?
```

### 3. Use Const for Known-Valid Values
```rust
// ❌ BAD: Runtime parsing that can't fail
const HOST: &str = "127.0.0.1";
let ip = HOST.parse().unwrap();  // Why parse at runtime?

// ✅ GOOD: Compile-time constant
const HOST: IpAddr = IpAddr::V4(Ipv4Addr::LOCALHOST);
```

### 4. Document Remaining Unwraps
```rust
// If an unwrap truly can't fail, document why:
let value = map.get(key).unwrap();  // Safe: key just inserted above
```

---

## 📞 PROGRESS TRACKING

Create `UNWRAP_PROGRESS.md` to track:
```markdown
# Unwrap Migration Progress

## Overall: 1,571 → X (Y% complete)

### Phase 1: Config (Week 1)
- [ ] environment.rs (12 unwraps)
- [ ] runtime/network.rs (18 unwraps)
- [x] sovereignty_config.rs (6 unwraps) ✅
... etc

### Phase 2: Network (Week 2)
...
```

---

**Status**: 📋 **PLAN COMPLETE**  
**Next**: Begin Phase 1 (Config Parsing)  
**Estimated Total Time**: 50-70 hours over 4-5 weeks  
**Priority**: 🔴 HIGH (production stability)

---

*Created: Dec 4, 2025 Night*  
*Ready for execution*

