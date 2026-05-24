# Architectural Decision Records (ADRs)

This directory contains Architectural Decision Records for the Squirrel project.

## What are ADRs?

Architectural Decision Records document significant architectural decisions made throughout the project lifecycle, including:
- The context and problem being addressed
- The decision that was made
- The rationale behind the decision
- The consequences (both positive and negative)

## ADR Index

### Phase 3 - Unification & Modernization

- [ADR-001](./ADR-001-config-system-consolidation.md) - Config System Consolidation Strategy
- [ADR-002](./ADR-002-trait-standardization.md) - Trait Standardization and Type Evolution
- [ADR-003](./ADR-003-compatibility-layer.md) - Backward Compatibility Layer Design
- [ADR-004](./ADR-004-type-system-domain-separation.md) - Type System Domain Separation (Nov 8, 2025)

## ADR Format

Each ADR follows this structure:

```markdown
# ADR-XXX: Title

**Status**: Accepted | Proposed | Deprecated | Superseded  
**Date**: YYYY-MM-DD  
**Decision Makers**: Team/Individual  
**Tags**: category, category

## Context

What is the issue that we're seeing that is motivating this decision?

## Decision

What is the change that we're proposing and/or doing?

## Rationale

Why did we choose this option over alternatives?

## Consequences

What becomes easier or more difficult to do because of this change?

## Alternatives Considered

What other options were evaluated?

## Related Decisions

- ADR-XXX: Related decision
```

## Contributing

When making significant architectural decisions:

1. Create a new ADR file with the next sequential number
2. Follow the standard format
3. Get team review before marking as "Accepted"
4. Update this index

## References

- [Documenting Architecture Decisions](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions) by Michael Nygard
- [ADR GitHub Organization](https://adr.github.io/)

