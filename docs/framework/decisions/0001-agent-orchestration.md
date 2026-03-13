# Agent Orchestration

**Status**: Accepted
**Date**: 2025-02-01

## Context

The framework needs to coordinate more than 10 specialized agents (envisioning, specify, plan, implement, review, etc.) that operate in distinct phases of an engineering workflow. The coordination must support both a guided flow for developers unfamiliar with the framework and direct use of individual agents by experienced developers.

## Priorities and Requirements (ordered)

1. **Failure resilience**: if the coordination mechanism fails, individual agents must continue to function. Developers cannot be blocked.
2. **Low maintenance cost**: adding or removing agents should not require changes to coordination logic. The framework evolves rapidly.
3. **Usage flexibility**: developers with different experience levels should be able to use the framework in their preferred way (guided or direct).
4. **Cross-phase context**: decisions and artifacts from one phase must be accessible to the next phase without manual rework.

## Options considered

### Option 1: Classic Orchestrator

A central agent that knows *what* to do and *how* to decompose work. It defines the plan, distributes granular tasks to workers, and controls the flow top-down.

:::mermaid
flowchart TB
    user["User"] --> orch["Orchestrator"]
    orch -->|"decomposes and distributes"| w1["Worker A"]
    orch -->|"decomposes and distributes"| w2["Worker B"]
    orch -->|"decomposes and distributes"| w3["Worker C"]
:::

**Evaluation against priorities**:
- **Resilience**: Single point of failure. If the orchestrator fails, workers cannot function on their own (they lack the full task context).
- **Maintenance**: High. The orchestrator needs to know the logic of each phase to decompose correctly. Changes to a worker may require changes to the orchestrator.
- **Flexibility**: Low. Workers are designed to receive instructions, not to operate independently.
- **Context**: Good. The orchestrator maintains centralized state.

### Option 2: Independent agents (no coordination)

Each agent operates in isolation. The user chooses which to invoke and manages the sequence manually.

:::mermaid
flowchart TB
    user["User"] --> a1["Agent A"]
    user --> a2["Agent B"]
    user --> a3["Agent C"]
:::

**Evaluation against priorities**:
- **Resilience**: Excellent. No central point of failure.
- **Maintenance**: Low. Each agent is self-contained.
- **Flexibility**: Partial. Works well for experienced developers, but beginners don't know which agent to use or in what order.
- **Context**: Weak. Each session starts clean. Cross-phase context depends solely on artifacts on disk.

### Option 3: Conductor (Mediated Coordinator-Worker)

Inspired by the Mediator pattern. A conductor agent is the entry point that detects intent and mediates communication, but has no domain knowledge. Sub-agents contain all the knowledge, return structured actions (`[ASK]`, `[CREATE]`, `[CHECKPOINT]`, `[DONE]`), and the conductor executes the side effects.

Sub-agents operate in dual-mode: via conductor or direct invocation by the user.

:::mermaid
flowchart TB
    user["User"] <-->|"interact"| conductor["Conductor"]
    conductor -->|"invoke"| w1["Sub-agent A"]
    conductor -->|"invoke"| w2["Sub-agent B"]
    conductor -->|"invoke"| w3["Sub-agent C"]
    w1 -.->|"actions"| conductor
    w2 -.->|"actions"| conductor
    w3 -.->|"actions"| conductor
:::

**Evaluation against priorities**:
- **Resilience**: High. When the conductor fails, sub-agents remain directly accessible (dual-mode). Gradual degradation instead of total failure.
- **Maintenance**: Low. Conductor has no domain logic. Adding/removing a sub-agent means updating a routing table in the instructions.
- **Flexibility**: High. Beginners use the conductor as a unified guide. Experienced developers go directly to the desired sub-agent. Both modes maintain the same behavior.
- **Context**: Good via conductor (accumulates across phases). Acceptable via direct invocation (depends on artifacts on disk, mitigated by the Handoff Envelope).

## Decision

Conductor (Option 3). The combination of resilience (dual-mode ensures that conductor failure does not block the developer), low maintenance cost (zero domain logic in the conductor), and usage flexibility (guided or direct) meets the priorities in the established order.

The accepted trade-off is higher token overhead (conductor + sub-agent) and latency (intermediate invocation) compared to individual agents. In practice, the cost is justified by the improved experience for developers unfamiliar with the framework.

### Summary comparison

| Aspect | Orchestrator | Individual agents | Conductor |
|--------|-------------|-------------------|-----------|
| Resilience | Single point of failure | No central failure | Dual-mode: gradual degradation |
| Maintenance | High (domain logic) | Low | Low (zero domain) |
| Flexibility | Only via orchestrator | Only direct | Both (dual-mode) |
| Cross-phase context | Good (centralized) | Weak (disk) | Good (conductor) / Acceptable (direct) |
| Token overhead | Medium | Low | High |

## References

- [Mediator pattern](https://refactoring.guru/design-patterns/mediator)
