# Context Management between Phases

* **Status**: Accepted
* **Date**: 2025-02-01

## Context

The framework operates in sequential phases (envision, specify, plan, decompose, implement, review) that can execute in the same session or in separate sessions over days. Each phase generates reasoning, assumptions, and intermediate decisions. Without an explicit management mechanism, assumptions from one phase contaminate the next: the agent assumes it knows things that were only considered, not decided.

## Priorities and Requirements (ordered)

1. **Isolation between phases**: assumptions and intermediate reasoning from one phase must not leak into the next without explicit validation.
2. **Cross-session persistence**: relevant context must survive session termination. Flows that span days cannot lose state.
3. **Auditability**: it must be possible to trace what information was passed between phases and what assumptions were inherited.
4. **Operational simplicity**: the mechanism should not require additional infrastructure (databases, external services).

## Options considered

### Option 1: Accumulated context in the session

The conversation context naturally accumulates across phases. Each phase inherits everything that came before.

**Evaluation against priorities**:
* **Isolation**: nonexistent. Assumptions discarded by the agent in the previous phase remain in the context and influence the next phase.
* **Persistence**: none. When the session closes, all context is lost.
* **Auditability**: weak. The context is implicit in the conversation, difficult to inspect.
* **Simplicity**: maximum. No additional infrastructure.

### Option 2: State database

A database (SQLite, Redis) stores state between phases. Each phase reads from and writes to the database.

**Evaluation against priorities**:
* **Isolation**: good, if modeled correctly with namespaces per phase.
* **Persistence**: excellent. Survives sessions and restarts.
* **Auditability**: good. Database queries show state at any point.
* **Simplicity**: low. Requires infrastructure, schema, migrations, and agents need to know how to read/write to the database.

### Option 3: Disk artifacts as source of truth + Handoff Envelope

Persistent artifacts (spec.md, plan.md, ADRs, tasks.md) are the only source of truth. When transitioning between phases, session context is cleaned and the next phase reconstructs context by reading artifacts from disk. A Handoff Envelope (structured block) explicitly transfers inherited assumptions, pending decisions, and discarded information.

**Evaluation against priorities**:
* **Isolation**: high. Each phase starts with clean context, reading only validated artifacts and the handoff envelope.
* **Persistence**: excellent. Artifacts are in the git repository. They survive sessions, machines, and even team rotation.
* **Auditability**: high. Artifacts are versioned (git). The envelope explicitly documents what was passed.
* **Simplicity**: high. No infrastructure beyond the file system and git, which already exist.

## Decision

Disk artifacts + Handoff Envelope (Option 3). Meets all priorities without significant trade-offs. Isolation via context cleanup between phases eliminates the assumption contamination problem. Persistence via git is free and universal.

The accepted trade-off is that context reconstruction from artifacts consumes additional tokens (the agent needs to read files at the beginning of each phase). In practice, this cost is low compared to the risk of decisions based on contaminated assumptions.

### Transitions with context cleanup

| Transition | Reason for cleanup |
|------------|-------------------|
| specify to plan | Spec is a persistent artifact; plan reads from the file, not from session memory |
| plan to decompose | Work items are generated from artifacts, not from accumulated context |
| decompose to implement | Implementation uses tasks, specs, and ADRs as source |
| implement to review | Independent review requires clean context by principle |

### Summary comparison

| Aspect | Accumulated context | Database | Artifacts + Envelope |
|--------|---------------------|----------|---------------------|
| Isolation | Nonexistent | Good (if modeled) | High (explicit cleanup) |
| Persistence | None | Excellent | Excellent (git) |
| Auditability | Weak | Good | High (versioned) |
| Simplicity | Maximum | Low | High |
| Token cost | Low | Medium (queries) | Medium (re-reading) |

## References

* [Context Management between Phases](../context-management.md)
* [Skill: Reasoning](../../.github/skills/reasoning/SKILL.md) (defines the Handoff Envelope format)
