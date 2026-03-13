# Communication between Conductor and Sub-agents

* **Status**: Accepted
* **Date**: 2025-02-01

## Context

Given that the framework adopts the Conductor pattern (Mediated Coordinator-Worker) as per [ADR 0001: Agent Orchestration](./0001-agent-orchestration.md), it is necessary to define how the conductor and sub-agents communicate and how sub-agents behave when invoked directly by the user (without the conductor).

The central challenge: sub-agents need to function in two distinct contexts (via conductor and via direct invocation) without logic duplication.

## Priorities and Requirements (ordered)

1. **Single codebase**: the same sub-agent must serve both modes without complex branches or separate files.
2. **Structured communication**: the conductor needs to programmatically interpret sub-agent responses to execute side effects (create files, update board, etc.).
3. **Consistent experience**: Socratic behavior, checkpoints, and output quality must be identical regardless of invocation mode.
4. **Implementation simplicity**: new sub-agents must be easy to create following the established pattern.

## Options considered

### Option 1: Prefix protocol with structured actions

The conductor injects the prefix `[CONDUCTOR]` into the sub-agent's prompt. The sub-agent detects the prefix and returns structured actions (`[ASK]`, `[CREATE]`, `[BOARD]`, `[CHECKPOINT]`, `[DONE]`) instead of interacting directly with the user. Without the prefix, the sub-agent operates in direct mode.

**Evaluation against priorities**:
* **Single codebase**: the sub-agent has a single check at the start (prefix presence) that defines the output mode. Domain logic is shared.
* **Structured communication**: the actions are parseable text tags. The conductor interprets and executes the side effects.
* **Consistent experience**: both modes execute the same domain logic, varying only the interaction format.
* **Simplicity**: the pattern is easy to replicate. A new sub-agent only needs to implement the prefix check and format output with the actions.

### Option 2: Two agents per phase (conductor-mode and direct-mode)

Each phase would have two agent files: one optimized for the conductor and another for direct invocation.

**Evaluation against priorities**:
* **Single codebase**: violated. Domain logic duplication between the two files.
* **Structured communication**: the conductor-mode agent can be optimized for this.
* **Consistent experience**: hard to guarantee. Changes to domain logic need to be replicated in two files.
* **Simplicity**: doubles the number of files and maintenance effort.

### Option 3: Adapter layer in the conductor

The conductor translates sub-agent free-text responses into structured actions by interpreting the content.

**Evaluation against priorities**:
* **Single codebase**: sub-agents don't need mode logic. Just one file.
* **Structured communication**: weak. The conductor needs to parse free text, which is ambiguous and error-prone.
* **Consistent experience**: depends on the quality of the conductor's interpretation.
* **Simplicity**: high complexity in the conductor, which needs to understand each sub-agent's domain to interpret responses.

## Decision

Prefix protocol with structured actions (Option 1). Meets all priorities without significant trade-offs. The prefix check is trivial, actions are explicit, and domain logic remains in a single place.

The accepted trade-off is that sub-agents need to format output in two ways (structured actions vs direct interaction), but this is a low implementation cost compared to the risks of the alternatives.

### Communication flow via conductor

:::mermaid
sequenceDiagram
    participant Dev as User
    participant Conductor as sdd (conductor)
    participant SubAgent as sub-agent

    Dev->>Conductor: "I want to specify a feature"
    Conductor->>Conductor: Detect state + intent
    Conductor->>SubAgent: [CONDUCTOR] Phase: specify, Turn: 1
    SubAgent->>SubAgent: Read files, analyze context
    SubAgent-->>Conductor: [ASK] "Which feature?" + options
    Conductor-->>Dev: Relay questions (formatting preserved)
    Dev->>Conductor: "authentication feature"
    Conductor->>SubAgent: [CONDUCTOR] Turn: 2, Responses: {feature: auth}
    SubAgent->>SubAgent: Generate spec
    SubAgent-->>Conductor: [CHECKPOINT] Reasoning Log + [CREATE spec.md]
    Conductor-->>Dev: Present summary, request confirmation
    Dev->>Conductor: "approved"
    Conductor->>Conductor: Execute [CREATE spec.md]
    SubAgent-->>Conductor: [DONE] Spec created, next: sdd.plan
    Conductor-->>Dev: "Spec completed! Continue to planning?"
:::

### Dual-mode of sub-agents

Sub-agents detect the invocation mode by the `[CONDUCTOR]` prefix in the prompt:

:::mermaid
flowchart TB
    invoke["Sub-agent invoked"]
    invoke --> check{"Prompt starts<br/>with [CONDUCTOR]?"}

    check -->|Yes| conductor["Conductor Mode"]
    check -->|No| direct["Direct Mode"]

    conductor --> read_c["Read files with read tools"]
    read_c --> actions["Return structured actions"]
    actions --> ask["[ASK] Questions"]
    actions --> create["[CREATE] Files"]
    actions --> board["[BOARD] Work items"]
    actions --> checkpoint["[CHECKPOINT] Validation"]
    actions --> done["[DONE] Completed"]

    direct --> read_d["Read files with read tools"]
    read_d --> interactive["Interact directly with user"]
    interactive --> socratic["Socratic Questions"]
    interactive --> generates["Create files"]
    interactive --> boards["Create work items"]
:::

Both modes:
* Execute the same domain logic (context analysis, artifact generation)
* Maintain Socratic behavior ([ADR 0005](./0005-socratic-ai.md))
* Produce the same artifacts with the same quality

### Summary comparison

| Aspect | Prefix + actions | Two agents | Adapter layer |
|--------|-----------------|-------------|---------------|
| Single codebase | Yes (prefix check) | No (duplication) | Yes |
| Structured communication | Explicit (tags) | Explicit | Ambiguous (parsing) |
| Consistent experience | Guaranteed | Difficult | Depends on parsing |
| Simplicity | High | Low (2x files) | Low (complex conductor) |

## References

* [ADR 0001: Agent Orchestration](./0001-agent-orchestration.md)
* [ADR 0005: Socratic AI](./0005-socratic-ai.md)
