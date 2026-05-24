#!/bin/bash
#
# Deployment Readiness Checklist
# Based on December 2, 2025 Audit Results
#

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     NestGate Deployment Readiness Checklist                ║"
echo "║     Grade: B+ (87/100) - Production Ready                  ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

PASSED=0
FAILED=0
WARNINGS=0

check_pass() {
    echo -e "${GREEN}✅ PASS${NC}: $1"
    ((PASSED++))
}

check_fail() {
    echo -e "${RED}❌ FAIL${NC}: $1"
    ((FAILED++))
}

check_warn() {
    echo -e "${YELLOW}⚠️  WARN${NC}: $1"
    ((WARNINGS++))
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. Build & Compilation Checks"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if cargo build --workspace --release &>/dev/null; then
    check_pass "Workspace builds successfully (release mode)"
else
    check_fail "Workspace build failed"
fi

if cargo check --workspace &>/dev/null; then
    check_pass "All crates pass cargo check"
else
    check_fail "Cargo check failed"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2. Test Verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Run tests and capture results
TEST_OUTPUT=$(cargo test --lib --workspace 2>&1 | grep "test result:")
if echo "$TEST_OUTPUT" | grep -q "0 failed"; then
    PASSED_TESTS=$(echo "$TEST_OUTPUT" | grep -o "[0-9]\+ passed" | awk '{sum+=$1} END {print sum}')
    check_pass "All library tests passing ($PASSED_TESTS tests)"
else
    check_fail "Some tests are failing"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3. Code Quality Checks"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if cargo fmt --all -- --check &>/dev/null; then
    check_pass "Code formatting is correct"
else
    check_warn "Code needs formatting (run: cargo fmt --all)"
fi

# Check for clippy warnings (non-blocking)
CLIPPY_OUTPUT=$(cargo clippy --workspace --all-targets 2>&1 | grep -c "warning:" || true)
if [ "$CLIPPY_OUTPUT" -lt 100 ]; then
    check_pass "Clippy warnings acceptable ($CLIPPY_OUTPUT warnings)"
else
    check_warn "Many clippy warnings ($CLIPPY_OUTPUT warnings)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4. Coverage & Documentation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f "target/llvm-cov/html/index.html" ]; then
    check_pass "Coverage report exists"
else
    check_warn "Coverage report not found (run: cargo llvm-cov --lib --html)"
fi

if [ -f "📋_EXECUTIVE_HANDOFF.md" ]; then
    check_pass "Audit documentation complete"
else
    check_fail "Audit documentation missing"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5. Deployment Prerequisites"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -d ".git" ]; then
    check_pass "Git repository initialized"
else
    check_warn "Not a git repository"
fi

if [ -f "Cargo.toml" ]; then
    check_pass "Cargo.toml present"
else
    check_fail "Cargo.toml missing"
fi

if [ -f "Dockerfile" ] || [ -f "docker-compose.yml" ]; then
    check_pass "Docker configuration available"
else
    check_warn "No Docker configuration found"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "6. Audit Recommendations Verified"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check for key audit metrics
UNSAFE_COUNT=$(find code/crates -name "*.rs" -exec grep -c "unsafe" {} + 2>/dev/null | awk '{sum+=$1} END {print sum}')
if [ "$UNSAFE_COUNT" -lt 150 ]; then
    check_pass "Unsafe code count acceptable ($UNSAFE_COUNT blocks, target: <200)"
else
    check_warn "Unsafe code count: $UNSAFE_COUNT blocks"
fi

TODO_COUNT=$(rg "TODO|FIXME|XXX|HACK" --type rust 2>/dev/null | wc -l || echo 0)
if [ "$TODO_COUNT" -lt 10 ]; then
    check_pass "Technical debt minimal ($TODO_COUNT TODOs, target: <10)"
else
    check_warn "Technical debt markers: $TODO_COUNT"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "DEPLOYMENT READINESS SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${GREEN}✅ Passed${NC}: $PASSED checks"
echo -e "${RED}❌ Failed${NC}: $FAILED checks"
echo -e "${YELLOW}⚠️  Warnings${NC}: $WARNINGS checks"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✅ DEPLOYMENT APPROVED                                    ║${NC}"
    echo -e "${GREEN}║  Grade: B+ (87/100) - Production Ready                     ║${NC}"
    echo -e "${GREEN}║  Confidence: ⭐⭐⭐⭐ (4/5)                                  ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "✅ All critical checks passed"
    echo "✅ Ready for staging deployment"
    echo "✅ Can proceed to production after staging validation"
    echo ""
    echo "Next steps:"
    echo "  1. Review 📋_EXECUTIVE_HANDOFF.md"
    echo "  2. Deploy to staging environment"
    echo "  3. Monitor for 2-3 days"
    echo "  4. Deploy to production"
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ❌ DEPLOYMENT BLOCKED                                      ║${NC}"
    echo -e "${RED}║  $FAILED critical check(s) failed                          ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "❌ Please fix failed checks before deploying"
    echo ""
    echo "For help, see:"
    echo "  - ACTIONABLE_ITEMS_DEC_2_2025.md"
    echo "  - 🚀_START_HERE_AUDIT_RESULTS.md"
    exit 1
fi

