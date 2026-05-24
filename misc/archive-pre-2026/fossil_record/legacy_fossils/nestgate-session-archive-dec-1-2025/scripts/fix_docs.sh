#!/bin/bash
# Script to add missing documentation to fix clippy errors
# Generated: November 29, 2025

set -euo pipefail

echo "🔧 Fixing missing documentation errors..."

# File 1: automation/mod.rs
FILE1="code/crates/nestgate-core/src/config/canonical_primary/domains/automation/mod.rs"

# Add docs for MlPredictionConfig
sed -i '533a\    /// Creates development configuration for ML prediction settings' "$FILE1"
sed -i '545a\    /// Creates production-optimized configuration for ML prediction settings' "$FILE1"

# Add docs for AiAutomationConfig
sed -i '568a\    /// Creates development configuration for AI automation' "$FILE1"
sed -i '581a\    /// Creates production-optimized configuration for AI automation' "$FILE1"

# Add docs for LifecycleConfig
sed -i '605a\    /// Creates development configuration for lifecycle management' "$FILE1"
sed -i '618a\    /// Creates production-optimized configuration for lifecycle management' "$FILE1"

# Add docs for OptimizationConfig
sed -i '646a\    /// Creates development configuration for optimization settings' "$FILE1"
sed -i '659a\    /// Creates production-optimized configuration for optimization settings' "$FILE1"

# Add docs for WorkflowsConfig
sed -i '683a\    /// Creates development configuration for workflow management' "$FILE1"
sed -i '695a\    /// Creates production-optimized configuration for workflow management' "$FILE1"

# Add docs for SchedulingConfig
sed -i '718a\    /// Creates development configuration for scheduling' "$FILE1"
sed -i '730a\    /// Creates production-optimized configuration for scheduling' "$FILE1"

# Add docs for TriggersConfig
sed -i '756a\    /// Creates development configuration for trigger settings' "$FILE1"
sed -i '768a\    /// Creates production-optimized configuration for trigger settings' "$FILE1"

# Add docs for ActionsConfig
sed -i '791a\    /// Creates development configuration for action management' "$FILE1"
sed-i '804a\    /// Creates production-optimized configuration for action management' "$FILE1"

# File 2: network/api.rs
FILE2="code/crates/nestgate-core/src/config/canonical_primary/domains/network/api.rs"

sed -i '339a\    /// Creates production TLS configuration with strict security' "$FILE2"
sed -i '358a\    /// Creates development rate limiting configuration' "$FILE2"
sed -i '367a\    /// Creates production rate limiting configuration with strict limits' "$FILE2"
sed -i '385a\    /// Creates development CORS configuration with permissive settings' "$FILE2"
sed -i '397a\    /// Creates production CORS configuration with strict origin control' "$FILE2"
sed -i '418a\    /// Creates development health check configuration' "$FILE2"
sed -i '435a\    /// Creates production health check configuration with comprehensive checks' "$FILE2"
sed -i '461a\    /// Creates development compression configuration' "$FILE2"
sed -i '475a\    /// Creates production compression configuration optimized for bandwidth' "$FILE2"
sed -i '503a\    /// Creates production API gateway configuration' "$FILE2"

# File 3: network/protocols.rs
FILE3="code/crates/nestgate-core/src/config/canonical_primary/domains/network/protocols.rs"

sed -i '49a\    /// Creates development-optimized network protocol configuration' "$FILE3"
sed -i '68a\    /// Creates production-hardened network protocol configuration with HTTP/2' "$FILE3"
sed -i '96a\    /// Merges another protocol configuration into this one, overwriting with other values' "$FILE3"

# File 4: storage_canonical/mod.rs
FILE4="code/crates/nestgate-core/src/config/canonical_primary/domains/storage_canonical/mod.rs"

# Add module doc if missing
sed -i '29a\/// Caching configuration for storage optimization' "$FILE4"

echo "✅ Documentation fixes applied"
echo "🧪 Testing compilation..."

cd "$(dirname "$0")"
cargo clippy --all-targets --all-features -- -D warnings 2>&1 | head -20

echo "✅ Doc fixes complete!"

