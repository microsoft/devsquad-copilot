# Sub-agent Nesting Resolution

* **Status**: Accepted
* **Date**: 2026-03-22

## Context

GitHub Copilot currently limits subagent nesting to 1 level: a subagent cannot spawn another subagent. The framework uses a conductor pattern (`devsquad`) that delegates to specialized agents (L1), some of which spawn their own sub-agents (L2). When the user invokes the conductor, L1 agents fail to reach L2. Direct invocation works because there is only 1 level of nesting.

Affected chains:

| L1 Agent | L2 Agents | Mechanism |
|---|---|---|
| `init` | `init-config`, `init-docs`, `init-scaffold` | `agents:` field (parallel) |
| `implement` | `security` | `agents:` field |
| `plan` | `security` | `agents:` field |
| `review` | `security` | `agents:` field |
| `sprint` | `refine` | `agents:` field |

Handoffs (`handoffs:` field) also fail under the conductor because they either attempt L2 spawning or transfer control away from the conductor, breaking orchestration.

## Priorities and Requirements (ordered)

1. **Preserve guided mode** — The conductor must remain the single entry point for guided workflows. Solutions that degrade the conductor experience or make it inferior to direct invocation are not acceptable.
2. **No capability loss** — L1 agents must retain all functionality currently provided by L2 agents (security review, backlog health analysis, init file generation). Tool coverage was verified: every L2 agent's tools are a subset of its L1 consumer's tools.
3. **Maintainability** — Shared logic (e.g., security used by 3 agents) must not be duplicated. Changes to shared workflows should require editing a single file.
4. **Minimal architectural churn** — Prefer patterns already established in the framework over introducing new protocol concepts.
5. **Direct invocation preserved** — Users who invoke specialized agents directly (e.g., `@devsquad.plan`) must retain the same functionality they have today.

## Options Considered

### Option 1: Skill conversion for L2 agents

Convert L2 agent logic into skills (SKILL.md). L1 agents load the skill instructions as context and execute the workflows themselves. Standalone agent files are kept for direct invocation.

- `security` -> `security-review` skill (consumed by `implement`, `plan`, `review`)
- `refine` -> flatten into `sprint` (single consumer, 257 lines)
- `init-config`, `init-docs`, `init-scaffold` -> skills (consumed by `init`)

**Evaluation against priorities**:
- **Preserve guided mode**: The conductor delegates to L1 agents at depth 1. L1 agents execute skill workflows internally. No nesting violation.
- **No capability loss**: All L2 tools are subsets of their L1 consumers (verified). Skills provide the same instructions the L2 agents followed. No tool gaps.
- **Maintainability**: Single `security-review` skill shared by 3 consumers. One edit propagates everywhere. `refine` is flattened (single consumer, no duplication risk).
- **Minimal architectural churn**: Skills are an established pattern (14+ skills already exist). No new protocol concepts. Zero conductor changes.
- **Direct invocation preserved**: Standalone agent files (`devsquad.security`, `devsquad.refine`) remain unchanged for direct use.

### Option 2: Trampoline pattern

L1 agents return a `[DELEGATE agent prompt]` structured action. The conductor intercepts it, invokes the target agent at L1, and feeds results back to the original agent with `[DELEGATE_RESULT]`.

**Evaluation against priorities**:
- **Preserve guided mode**: Fully preserved. Delegation is transparent to the user.
- **No capability loss**: L2 agents run in their own context window with full tool access.
- **Maintainability**: Good. Shared agents remain single files. No duplication.
- **Minimal architectural churn**: Introduces a new protocol concept (`[DELEGATE]`, `[DELEGATE_RESULT]`) to the conductor and all L1 agents that use sub-agents. Requires ~60-80 lines across 6 files. Novel pattern not yet proven in this framework.
- **Direct invocation preserved**: L1 agents use dual-mode logic (agent tool when direct, `[DELEGATE]` when under conductor).

### Option 3: Flatten L2 into L1

Merge L2 agent instructions directly into their consuming L1 agents. No sub-agent calls.

**Evaluation against priorities**:
- **Preserve guided mode**: Fully preserved.
- **No capability loss**: All instructions are inline.
- **Maintainability**: Security logic duplicated across 3 agents (473 lines x 3). Synchronized edits required for any security workflow change. High divergence risk.
- **Minimal architectural churn**: Conceptually simple but creates significant file bloat. `init` grows from 149 to ~1660 lines.
- **Direct invocation preserved**: Yes, but duplicated logic may drift from standalone agents.

### Option 4: Conditional degradation

Detect conductor mode and skip sub-agent calls. L1 agents operate with reduced functionality when nested.

**Evaluation against priorities**:
- **Preserve guided mode**: Guided mode becomes a degraded experience. Security reviews and backlog analysis are skipped.
- **No capability loss**: Capabilities are lost in conductor mode.
- **Maintainability**: Low change count, but two behavior paths per agent.
- **Minimal architectural churn**: Minimal changes.
- **Direct invocation preserved**: Yes, direct mode retains full functionality (making conductor strictly inferior).

## Decision

**Option 1: Skill conversion for L2 agents.**

Skill conversion eliminates nesting without introducing new protocol concepts or duplicating logic. It leverages an established framework pattern (skills), requires zero conductor changes, and preserves both guided and direct invocation modes.

The key trade-off accepted is loss of context isolation for security reviews: the security workflow runs inside the consuming agent's context rather than in an independent window. This was evaluated as acceptable because:

- The security skill provides deterministic instructions (STRIDE categories, OWASP checks) that produce consistent output regardless of execution context.
- The consuming agents already have all required tools.
- The trampoline alternative's overhead (new protocol, extra round-trips, token serialization) outweighs the theoretical isolation benefit.

Parallel execution for `init` sub-agents is also lost, but initialization is a one-time operation where sequential execution is acceptable.

## Implementation Notes

1. **New skills to create**: `security-review/`, `init-config/`, `init-docs/`, `init-scaffold/`.
2. **Flatten `refine` into `sprint`**: Single consumer, 257 lines. Absorb directly rather than creating a skill.
3. **L1 agent changes**: Remove `agents:` field and `agent` tool from `implement`, `plan`, `review`, `sprint`, `init`. Add skill loading instructions.
4. **Keep standalone agents**: `devsquad.security` and `devsquad.refine` remain as agents for direct invocation (`@devsquad.security`). No changes to these files.
5. **Delete or archive**: `devsquad.init-config`, `devsquad.init-docs`, `devsquad.init-scaffold` (marked `user-invocable: false`, only used as sub-agents). Can be removed after skill equivalents are validated.

## References

- GitHub Copilot custom agents: https://code.visualstudio.com/docs/copilot/customization/custom-agents
- GitHub Copilot subagents: https://code.visualstudio.com/docs/copilot/agents/subagents
- Skills best practices: https://github.com/mgechev/skills-best-practices
