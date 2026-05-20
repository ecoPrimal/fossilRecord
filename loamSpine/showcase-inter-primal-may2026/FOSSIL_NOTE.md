# Fossil: loamSpine inter-primal showcase (Level 3)

**Source**: `primals/loamSpine/showcase/03-inter-primal/`  
**Fossilized**: 2026-05-20  
**Reason**: mined + stale (simulated IPC, no live integration)  
**Mined into**: primalSpring exp053 (multi-primal lifecycle)  
**Replacement**: primalSpring `experiments/exp053_multi_primal_lifecycle/` for validation; live loamSpine integration via `CompositionContext` in production code.

## Contents

| Demo | Pattern | Status at fossilization |
|------|---------|------------------------|
| `01-beardog-signing/` | BearDog signed commits | Simulated signing (sha256sum placeholders) |
| `02-nestgate-storage/` | NestGate content storage | Simulated with local files |
| `03-squirrel-sessions/` | AI session commits | Simulated session, gap documented |
| `04-toadstool-compute/` | Compute result anchoring | Simulated compute job |
| `05-full-ecosystem/` | 6-primal research paper lifecycle | Mostly narrative; only step 4 ran real code |

Level 0 (`00-local-primal/`) and Level 1 (`02-rpc-api/`) remain live — real
`cargo run --example` demos against current APIs.
