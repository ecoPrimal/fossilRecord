# 📋 Visualization Types Refactoring Plan - READY FOR EXECUTION

## 🎯 Target: Split types.rs (1,142 lines) → 4 modules

**Current**: Single monolithic file  
**Target**: Well-organized module structure

---

## 📊 Analysis Complete

### File Structure (50 types identified)
```
Core Types (14):
- VisualizationType, VisualizationRequest, VisualizationResponse
- VisualizationConfig, VisualizationSeries, DataPoint
- InteractiveElement, FilterConfig, etc.

Theme/Styling (4):
- VisualizationTheme, VisualizationLayout
- MarginConfig, PaddingConfig

Configuration (8):
- GridConfig, AnimationConfig, ExportConfig
- QualityConfig, AxisConfig, TickConfig
- LegendConfig, TooltipConfig

Implementations (24):
- Default impls for all structs
- Display impl for VisualizationType
- FromStr impl for VisualizationType
```

---

## 🏗️ Proposed Module Structure

```
visualization/types/
├── mod.rs           (~50 lines)   - Re-exports & module docs
├── core.rs          (~350 lines)  - Core visualization types
├── config.rs        (~400 lines)  - Configuration types
├── theme.rs         (~200 lines)  - Theme & layout types
└── display.rs       (~150 lines)  - Display & conversion impls
```

### Breakdown by File:

#### **mod.rs** (~50 lines)
```rust
//! Visualization type system
//! 
//! Organized into logical modules:
//! - core: Core visualization types
//! - config: Configuration structures
//! - theme: Theme and layout types
//! - display: Display implementations

pub mod core;
pub mod config;
pub mod theme;
pub mod display;

// Re-export commonly used types
pub use core::*;
pub use config::*;
pub use theme::*;
```

#### **core.rs** (~350 lines)
```rust
//! Core visualization types

- VisualizationType enum
- VisualizationRequest struct
- VisualizationResponse struct
- VisualizationConfig struct
- VisualizationSeries struct
- DataPoint struct
- InteractiveElement struct
- FilterConfig struct
```

#### **config.rs** (~400 lines)
```rust
//! Configuration types

- AnimationConfig struct + Default
- ExportConfig struct + Default
- QualityConfig struct + Default
- GridConfig struct + Default
- AxisConfig struct + Default
- TickConfig struct + Default
- LegendConfig struct + Default
- TooltipConfig struct + Default
- VisualizationConfig Default impl
```

#### **theme.rs** (~200 lines)
```rust
//! Theme and layout types

- VisualizationTheme struct + Default
- VisualizationLayout struct + Default
- MarginConfig struct + Default
- PaddingConfig struct + Default
```

#### **display.rs** (~150 lines)
```rust
//! Display and conversion implementations

- Display impl for VisualizationType
- FromStr impl for VisualizationType
- Other conversion traits
```

---

## 🔧 Implementation Steps

### Step 1: Create Directory Structure
```bash
mkdir -p crates/core/context/src/visualization/types
```

### Step 2: Create mod.rs with Re-exports
- Module documentation
- Submodule declarations
- Public re-exports for backward compatibility

### Step 3: Extract Core Types → core.rs
- Lines 14-323 (core type definitions)
- Keep imports minimal
- Remove Default impls (go to respective modules)

### Step 4: Extract Config Types → config.rs
- Configuration structs
- Their Default implementations
- Grid, Animation, Export, Quality configs

### Step 5: Extract Theme Types → theme.rs
- VisualizationTheme + Default
- VisualizationLayout + Default
- Margin/Padding configs + Defaults

### Step 6: Extract Implementations → display.rs
- Display trait impl
- FromStr trait impl
- Any other trait implementations

### Step 7: Update Original types.rs → types/mod.rs
- Replace with module structure
- Ensure all public API preserved

### Step 8: Update Imports Throughout Codebase
```bash
# Find all imports
grep -r "use.*visualization::types" crates/

# Most should continue working due to re-exports
# Update any that reference specific internal types
```

### Step 9: Verify Everything Works
```bash
cargo build
cargo test --workspace
cargo clippy --workspace
```

---

## ✅ Success Criteria

- [ ] All files <1000 lines
- [ ] No functionality lost
- [ ] All tests passing
- [ ] Imports working
- [ ] Documentation preserved
- [ ] Backward compatibility maintained

---

## ⏱️ Estimated Effort

**Total**: 3-4 hours

```
Analysis:          ✅ DONE (30 min)
Directory setup:      5 min
Create mod.rs:       15 min
Extract core.rs:     45 min
Extract config.rs:   45 min
Extract theme.rs:    30 min
Extract display.rs:  20 min
Update imports:      20 min
Testing:            30 min
```

---

## 🚀 Ready to Execute

**Status**: ✅ Plan complete, ready for implementation  
**Confidence**: HIGH  
**Risk**: LOW (mostly mechanical splitting)

**Next**: Execute Step 1 when ready to proceed

---

**Plan Created**: November 27, 2025  
**File**: visualization/types.rs (1,142 lines)  
**Target**: 4 files (<400 lines each)

*This refactoring will improve:*
- ✅ Maintainability
- ✅ Code navigation
- ✅ Build times (parallel compilation)
- ✅ File size compliance

