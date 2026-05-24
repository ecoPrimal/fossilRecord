#!/bin/bash
# Script to restore crates/universal-patterns/src/lib.rs

echo "🔧 Restoring crates/universal-patterns/src/lib.rs..."
echo ""

# Restore from git
git show e8480501:crates/universal-patterns/src/lib.rs > crates/universal-patterns/src/lib.rs

# Check result
SIZE=$(wc -c < crates/universal-patterns/src/lib.rs)
LINES=$(wc -l < crates/universal-patterns/src/lib.rs)

echo "Result:"
echo "  Size: $SIZE bytes (should be ~9800)"
echo "  Lines: $LINES (should be ~305)"
echo ""

if [ "$SIZE" -gt 1000 ]; then
    echo "✅ File restored successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Verify file stays intact (wait 10 seconds, check size again)"
    echo "2. If it gets cleared again, investigate what process is doing it"
    echo "3. Once stable, run: cargo build --workspace"
else
    echo "❌ File restoration failed or file was immediately cleared!"
    echo "ACTION REQUIRED: Check for interfering processes"
fi
