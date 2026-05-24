# biomeOS Archive — March 14, 2026

Stale scripts and debris archived from the biomeOS codebase.

## Archived Items

| File | Reason |
|------|--------|
| `scripts/build-genome.sh` | Replaced by `biomeos genome build` |
| `installer/make-biomeos-iso.sh` | Placeholder ISO, not functional |
| `installer/make-federation-iso.sh` | Assumes different layout |
| `tools/test-runner.sh` | References non-existent packages |
| `tests/bootstrap_validation.sh` | Grep targets outdated |

## Archive Location

`/home/eastgate/Development/ecoPrimals/archive/biomeos-mar14-2026/`

## Notes

- The `installer/` directory was removed from biomeOS after archiving (it was empty).
- Use `biomeos nucleus start` instead of `start_nucleus.sh` for Tower/NUCLEUS bootstrap.
- Use `biomeos genome build` for genome builds.
