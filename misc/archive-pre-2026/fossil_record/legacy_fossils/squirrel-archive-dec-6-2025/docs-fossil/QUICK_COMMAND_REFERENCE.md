# ⚡ Quick Command Reference - Squirrel

**Last Updated**: November 22, 2025

---

## 🚀 BUILD & TEST

### Basic Commands
```bash
# Build library
cargo build --lib --workspace

# Build everything (slower)
cargo build --workspace

# Run all tests (normal speed)
cargo test --lib --tests

# Run specific test
cargo test --lib test_basic_experiment_execution

# Run with output
cargo test --lib --tests -- --nocapture
```

### Fast Test Modes (NEW! ⚡)
```bash
# 10x faster tests
TEST_DURATION_MULTIPLIER=0.1 cargo test --lib --tests

# 100x faster tests (smoke test)
TEST_DURATION_MULTIPLIER=0.01 cargo test --lib --tests

# Custom multiplier (e.g., 5x faster)
TEST_DURATION_MULTIPLIER=0.2 cargo test --lib --tests
```

### Test Organization
```bash
# Run only unit tests
cargo test --lib

# Run only integration tests
cargo test --tests

# Run tests in parallel (default)
cargo test --lib --tests

# Run tests serially
cargo test --lib --tests -- --test-threads=1
```

---

## 🔧 CODE QUALITY

### Linting
```bash
# Run clippy (fast)
cargo clippy --lib --workspace

# Run clippy with all checks
cargo clippy --workspace --lib --tests --all-targets

# Auto-fix clippy warnings
cargo clippy --fix --lib --allow-dirty --allow-staged
```

### Formatting
```bash
# Check formatting
cargo fmt --all -- --check

# Apply formatting
cargo fmt --all

# Format specific file
cargo fmt --package squirrel -- path/to/file.rs
```

### Documentation
```bash
# Generate docs
cargo doc --no-deps

# Generate and open docs
cargo doc --no-deps --open

# Check doc tests
cargo test --doc
```

---

## 📊 COVERAGE & BENCHMARKS

### Test Coverage
```bash
# Generate coverage report
cargo llvm-cov --lib --workspace --html

# View coverage report
xdg-open target/llvm-cov/html/index.html  # Linux
open target/llvm-cov/html/index.html      # macOS

# Summary only
cargo llvm-cov --lib --workspace --summary-only
```

### Benchmarks
```bash
# Run all benchmarks
cargo bench

# Run specific benchmark
cargo bench --bench core_performance

# With profiling
cargo bench -- --profile-time=10
```

---

## 🛠️ MODERN TEST PATTERNS (NEW!)

### Apply Concurrent Patterns
```bash
# Preview changes (safe)
./scripts/fix_test_concurrency.sh --dry-run

# Apply changes
./scripts/fix_test_concurrency.sh

# View script help
./scripts/fix_test_concurrency.sh --help
```

### Measure Performance
```bash
# Full performance measurement
./scripts/measure_test_performance.sh

# View previous results
cat /tmp/test_normal.log
cat /tmp/test_fast.log
cat /tmp/test_ultrafast.log
```

---

## 🔍 DEBUGGING

### Verbose Output
```bash
# Show test output
cargo test --lib --tests -- --nocapture

# Show all logging
RUST_LOG=debug cargo test --lib --tests -- --nocapture

# Specific module logging
RUST_LOG=squirrel::chaos=debug cargo test --lib test_chaos

# Backtrace on panic
RUST_BACKTRACE=1 cargo test --lib --tests
```

### Test Debugging
```bash
# Run single test with timeout
timeout 30 cargo test --lib test_name -- --nocapture

# Run with gdb
rust-gdb --args target/debug/deps/test_binary

# Run with valgrind
valgrind target/debug/deps/test_binary
```

---

## 📦 DEPENDENCIES

### Update Dependencies
```bash
# Check for updates
cargo outdated

# Update Cargo.lock
cargo update

# Update specific dependency
cargo update -p tokio

# Tree view of dependencies
cargo tree
```

### Clean Build
```bash
# Remove target directory
cargo clean

# Remove specific package build
cargo clean --package squirrel

# Clean and rebuild
cargo clean && cargo build --lib --workspace
```

---

## 🎯 SPECIFIC WORKFLOWS

### Pre-Commit Checks
```bash
# Full check before commit
cargo fmt --all --check && \
cargo clippy --lib --workspace && \
TEST_DURATION_MULTIPLIER=0.1 cargo test --lib --tests
```

### Development Loop
```bash
# Fast iteration (while coding)
TEST_DURATION_MULTIPLIER=0.01 cargo test --lib

# Before git commit
cargo fmt --all && \
cargo clippy --lib && \
TEST_DURATION_MULTIPLIER=0.1 cargo test --lib --tests
```

### CI Simulation
```bash
# Simulate CI locally
cargo fmt --all --check && \
cargo clippy --workspace --lib --tests -- -D warnings && \
cargo test --lib --workspace && \
cargo doc --no-deps
```

---

## 🚨 EMERGENCY FIXES

### Build Broken?
```bash
# Clean everything
cargo clean

# Remove lock file (last resort)
rm Cargo.lock
cargo build --lib

# Check specific crate
cd crates/main
cargo build --lib
```

### Tests Hanging?
```bash
# Use fast mode
TEST_DURATION_MULTIPLIER=0.1 cargo test --lib --tests

# With timeout
timeout 120 cargo test --lib --tests

# Find hanging test
cargo test --lib --tests -- --test-threads=1 --nocapture
```

### Out of Disk Space?
```bash
# Clean build artifacts
cargo clean

# Clean dependencies cache
rm -rf ~/.cargo/registry/cache

# Clean LLVM coverage artifacts
rm -rf target/llvm-cov
```

---

## 📚 DOCUMENTATION WORKFLOW

### View Documentation
```bash
# Open main docs
cat 00_START_HERE.md

# View session progress
cat SESSION_2_CONCURRENT_MODERNIZATION_SUCCESS.md

# View test patterns
cat MODERN_CONCURRENT_TEST_PATTERNS_NOV_22_2025.md

# List all markdown docs
find . -name "*.md" -not -path "./archive/*" -not -path "./target/*"
```

### Generate Reports
```bash
# Test coverage
cargo llvm-cov --lib --workspace --summary-only > coverage_report.txt

# Clippy warnings
cargo clippy --lib --workspace 2>&1 | grep "warning:" > clippy_warnings.txt

# Dependency tree
cargo tree > dependency_tree.txt
```

---

## 🔧 CRATE-SPECIFIC

### Main Library
```bash
cd crates/main
cargo build --lib
cargo test --lib
cargo clippy --lib
```

### AI Tools
```bash
cd crates/tools/ai-tools
cargo build --lib
cargo test --lib
cargo run --example multi_model_demo
```

### MCP Core
```bash
cd crates/core/mcp
cargo build --lib
cargo test --lib
cargo doc --no-deps --open
```

---

## ⚡ PERFORMANCE TIPS

### Faster Builds
```bash
# Use mold linker (if installed)
cargo build --lib

# Parallel jobs
cargo build --lib -j8

# Skip dependencies
cargo build --lib --no-deps
```

### Faster Tests
```bash
# Use duration multiplier
TEST_DURATION_MULTIPLIER=0.1 cargo test --lib --tests

# Parallel execution
cargo test --lib --tests -- --test-threads=4

# Skip doc tests
cargo test --lib --bins --tests
```

---

## 🎯 ALIASES (Add to ~/.bashrc or ~/.zshrc)

```bash
# Quick commands
alias cb='cargo build --lib --workspace'
alias ct='TEST_DURATION_MULTIPLIER=0.1 cargo test --lib --tests'
alias ctf='TEST_DURATION_MULTIPLIER=0.01 cargo test --lib'  # Ultra fast
alias cc='cargo clippy --lib --workspace'
alias cf='cargo fmt --all'

# Full check
alias ccheck='cargo fmt --all --check && cargo clippy --lib && TEST_DURATION_MULTIPLIER=0.1 cargo test --lib --tests'

# Documentation
alias cdoc='cargo doc --no-deps --open'
alias cov='cargo llvm-cov --lib --workspace --html && xdg-open target/llvm-cov/html/index.html'
```

---

## 📊 STATUS CHECKS

### Current State
```bash
# Build status
cargo build --lib 2>&1 | tail -3

# Test count
cargo test --lib --tests -- --list | wc -l

# Warning count
cargo clippy --lib --workspace 2>&1 | grep -c "warning:"

# Coverage
cargo llvm-cov --lib --workspace --summary-only | grep "TOTAL"
```

### File Stats
```bash
# Lines of code
find crates -name "*.rs" | xargs wc -l | tail -1

# Test files
find crates -path "*/tests/*.rs" | wc -l

# Large files (>1000 lines)
find crates -name "*.rs" -exec wc -l {} \; | awk '$1 > 1000' | sort -rn
```

---

## 🚀 QUICK WINS

### Fast Development Cycle
```bash
# 1. Make changes
# 2. Fast test
TEST_DURATION_MULTIPLIER=0.01 cargo test --lib my_test

# 3. Full check before commit
TEST_DURATION_MULTIPLIER=0.1 cargo test --lib --tests && \
cargo clippy --lib && \
cargo fmt --all
```

### Pre-Push Checklist
```bash
# Format
cargo fmt --all

# Lint
cargo clippy --lib --workspace

# Test (fast)
TEST_DURATION_MULTIPLIER=0.1 cargo test --lib --tests

# Build docs
cargo doc --no-deps
```

---

## 📞 HELP

### Get Help
```bash
# Cargo help
cargo --help
cargo test --help
cargo clippy --help

# Script help
./scripts/fix_test_concurrency.sh --help
./scripts/measure_test_performance.sh --help
```

### Common Issues
```bash
# "Cannot find crate"
cargo clean && cargo build --lib

# "Tests hanging"
TEST_DURATION_MULTIPLIER=0.1 cargo test --lib --tests

# "Out of memory"
cargo test --lib --tests -- --test-threads=1

# "Too many open files"
ulimit -n 4096
```

---

## 🎉 PRODUCTIVITY HACKS

### Watch Mode (requires cargo-watch)
```bash
# Auto-rebuild on changes
cargo watch -x 'build --lib'

# Auto-test on changes
cargo watch -x 'test --lib'

# With duration multiplier
cargo watch -x 'test --lib' -s 'TEST_DURATION_MULTIPLIER=0.1'
```

### One-Liners
```bash
# Quick status
cargo build --lib && TEST_DURATION_MULTIPLIER=0.1 cargo test --lib --tests && echo "✅ All good!"

# Find slow tests
cargo test --lib --tests -- --nocapture 2>&1 | grep "test.*took"

# Count TODO comments
rg "TODO|FIXME|XXX" --type rust | wc -l
```

---

**Squirrel Quick Reference - November 22, 2025**

*Tip: Set `TEST_DURATION_MULTIPLIER=0.1` in your shell profile for 10x faster tests by default!*

```bash
# Add to ~/.bashrc or ~/.zshrc
export TEST_DURATION_MULTIPLIER=0.1
```

**Happy coding! 🐿️✨**

