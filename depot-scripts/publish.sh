#!/usr/bin/env bash
set -euo pipefail

DEPOT_LOCAL="/opt/ecoPrimals/depot"
DEPOT_REMOTE="root@10.13.37.1:/opt/ecoPrimals/depot/"
PLASMID_BIN="$HOME/.local/share/ecoPrimals/plasmidBin/primals"
PRIMALS_DIR="$HOME/Development/ecoPrimals/primals"

TARGETS=(
    "x86_64-unknown-linux-musl"
    "aarch64-linux-android"
)

BINARIES=(songbird beardog)

echo "╔══════════════════════════════════╗"
echo "║  Pepti Warehouse — Publish       ║"
echo "╚══════════════════════════════════╝"

for target in "${TARGETS[@]}"; do
    mkdir -p "$DEPOT_LOCAL/$target"
    for bin in "${BINARIES[@]}"; do
        src=""
        # Check staged plasmidBin first
        if [ -f "$PLASMID_BIN/$target/$bin" ]; then
            src="$PLASMID_BIN/$target/$bin"
        fi
        # Check cargo build output
        for primal_dir in "$PRIMALS_DIR"/*/; do
            built="$primal_dir/target/$target/release/$bin"
            if [ -f "$built" ]; then
                src="$built"
            fi
        done
        if [ -n "$src" ]; then
            cp "$src" "$DEPOT_LOCAL/$target/$bin"
            echo "  ✅ $target/$bin ($(du -h "$src" | cut -f1))"
        else
            echo "  ⏭️  $target/$bin (not built)"
        fi
    done
done

echo ""
echo "Publishing to golgi..."
rsync -az "$DEPOT_LOCAL/" "$DEPOT_REMOTE"
echo "✅ Pepti warehouse synced"
