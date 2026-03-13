# Work Decomposition

**Status**: Accepted
**Date**: 2026-03-07

## Context

The framework decomposes features into executable tasks. The organization of these tasks directly impacts the ability to parallelize work among developers, incremental testability, and delivery predictability. Without a defined structure, each decomposition follows different criteria, making sprint planning difficult and leaving dependencies implicit.

## Priorities and Requirements (ordered)

1. **Independently testable increments** -- Each phase or group of tasks should produce an increment that works and can be validated without depending on future phases. This enables fast feedback and reduces the risk of late integration.
2. **Explicit dependencies** -- The execution order should be evident from the structure, without requiring the developer to discover dependencies through trial and error.
3. **Parallelization among developers** -- Within each phase, it should be possible to identify which tasks can be executed in parallel by different developers.
4. **Consistency across features** -- All features should follow the same structure so that developers can transition between features without relearning the organization.

## Options considered

### Option 1: Flat task list

Tasks listed in suggested order, without grouping by phase or story. Dependencies indicated by free text ("depends on task X").

**Evaluation against priorities**:
- **Testable increments**: Weak. Without grouping, there's no clear point where to stop and validate.
- **Explicit dependencies**: Weak. Dependencies in free text are easy to forget and hard to validate automatically.
- **Parallelization**: Weak. Without marking, it's not evident what can run in parallel.
- **Consistency**: Nonexistent. Each developer organizes differently.

### Option 2: Grouping by technical layer

Tasks grouped by layer (all models, then all services, then all endpoints). Vertical order by layer.

**Evaluation against priorities**:
- **Testable increments**: Weak. Completing "all models" without services or endpoints doesn't produce a testable increment from the user's perspective.
- **Explicit dependencies**: Partial. The order between layers is clear, but within each layer there's no guidance.
- **Parallelization**: Good within each layer (independent models can be parallel).
- **Consistency**: Good. Structure is predictable.

### Option 3: Mandatory phases with grouping by user story

Fixed structure: Setup, Foundational, User Stories (grouped by priority P1/P2/P3), Polish. Within each user story, fixed order: Models, Services, Endpoints, Integration. Tasks marked with `[P]` when parallelizable. Each phase is a complete increment.

**Evaluation against priorities**:
- **Testable increments**: High. Each phase produces a validatable increment. Completing the "User Story P1" phase delivers testable value independent of P2/P3.
- **Explicit dependencies**: High. The hierarchical structure (phase, story, layer) makes dependencies implicit by position. Missing ADRs are blocking tasks in the Foundational phase.
- **Parallelization**: High. Tasks marked with `[P]` are explicitly parallelizable. Stories of the same priority can be executed in parallel among developers.
- **Consistency**: High. All features follow the same structure.

## Decision

Mandatory phases with grouping by user story (Option 3). The combination of testable increments per phase, explicit dependencies through structure, and parallelism marking meets all priorities. The accepted trade-off is less flexibility: the structure is prescriptive and may seem excessive for simple features. In practice, simple features result in few tasks within the same structure, so the overhead is minimal.

Mandatory structure:

```
Setup
  - Initial configurations, dependencies
Foundational
  - Missing ADRs (blocking)
  - Shared infrastructure
User Stories (by priority)
  P1: Story A
    - Models
    - Services
    - Endpoints
    - Integration
  P2: Story B
    - (same order)
Polish
  - Documentation, cleanup, optimizations
```

### Summary comparison

| Aspect | Flat list | By layer | By phase + story |
|--------|----------|----------|------------------|
| Testable increments | Weak | Weak | High |
| Explicit dependencies | Weak | Partial | High |
| Parallelization | Weak | Good (intra-layer) | High (marker [P]) |
| Consistency | Nonexistent | Good | High |

## References

* `tasks.instructions.md` -- formatting rules for tasks.md
* `delivery-guardrails.md` -- context on phases and increments
