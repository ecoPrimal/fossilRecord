#!/bin/bash
# Push local depot binaries to golgi after cascade harvest.
# Non-blocking — failure doesn't break the cascade cycle.
DEPOT="$HOME/Development/ecoPrimals/infra/plasmidBin/primals/x86_64-unknown-linux-musl"
REMOTE="golgi:/srv/depot/primals/x86_64-unknown-linux-musl/"

rsync -az --checksum "$DEPOT/" "$REMOTE" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "depot-push: golgi musl sync OK ($(ls "$DEPOT" | wc -l) binaries)"
else
    echo "depot-push: golgi sync failed (non-blocking)" >&2
fi
