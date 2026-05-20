# Fossil: toadStool stale showcase subdirectories

**Source**: `primals/toadStool/showcase/`  
**Fossilized**: 2026-05-20  
**Reason**: stale (untracked remnants, APIs moved to coralReef/biomeOS per S253)  
**Mined into**: primalSpring exp050 (compute triangle), exp054 (bearer token auth)  
**Replacement**: Active showcase tiers remain at `primals/toadStool/showcase/00-local-primal/` and `03-ecosystem-integration/`.

## Contents

| Directory | Description |
|-----------|-------------|
| `gpu-universal/` | Stale GPU universal compute demos (Cargo.lock remnant) |
| `neuromorphic/` | Stale neuromorphic/NPU demos (Cargo.lock remnant) |
| `results/` | Old test output logs |
| `gaming-evolution/` | Legacy gaming mesh evolution demos |
| `multi-primal-nestgate/` | Legacy nestgate multi-primal integration |
| `nestgate-standalone/` | Legacy nestgate standalone demos |
| `real-world/` | Legacy real-world scenario demos |

Shader pipeline (level 01) and compute patterns (level 02) were deleted in S253
when those APIs moved to coralReef and biomeOS. Previous archive exists at
`fossil/toadStool/showcase-legacy-S138/` within the toadStool repo.
