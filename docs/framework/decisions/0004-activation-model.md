# Component Activation Model

* **Status**: Accepted
* **Date**: 2025-02-01

## Context

The framework needs specific knowledge (code conventions, formatting rules, validations, domain logic) to be injected into the agents' context without overloading each agent with all project rules. The Copilot CLI platform offers multiple extension mechanisms, each with a different activation model. The decision is how to distribute knowledge across these mechanisms.

## Priorities and Requirements (ordered)

1. **Context efficiency**: the agent should receive only the knowledge relevant to the current task. Loading unnecessary rules consumes tokens and reduces quality.
2. **Predictability**: the developer should be able to predict when a rule will be applied. Critical rules cannot depend on probabilistic activation.
3. **Reusability**: knowledge shared across multiple agents should not be duplicated.
4. **Ease of extension**: framework consumers should be able to add knowledge without understanding the internal architecture of agents.

## Options considered

### Option 1: Single mechanism (everything via instructions)

All specific knowledge is added as path-specific instructions with glob patterns.

**Evaluation against priorities**:
* **Efficiency**: low. Instructions are loaded in every interaction involving files matching the pattern. Rules that only matter in specific scenarios generate constant overhead.
* **Predictability**: high. Glob is deterministic.
* **Reusability**: partial. Instructions are loaded by file pattern, not by thematic relevance.
* **Extension**: simple. A file with `applyTo` frontmatter.

### Option 2: Single mechanism (everything via skills)

All knowledge is added as skills with semantic activation by description.

**Evaluation against priorities**:
* **Efficiency**: good. Skills are loaded on demand when relevant.
* **Predictability**: low. Semantic activation is probabilistic. A critical skill may not activate if the conversation doesn't mention relevant terms.
* **Reusability**: high. Any agent can activate the skill.
* **Extension**: simple. A SKILL.md file with a description.

### Option 3: Differentiated model by activation type

Three mechanisms with distinct activation, chosen by the trade-off between determinism and efficiency:

* **Instructions** (deterministic, glob): rules that must apply whenever a file type is edited. Fixed context cost, guaranteed application.
* **Skills** (semantic, description): reusable knowledge across agents, loaded only when relevant. Lower average cost, but probabilistic activation.
* **Agents** (explicit, invocation): complex logic requiring isolated context, dedicated tools, or large instruction volume. Isolated cost per invocation.

Complemented by:
* **Hooks** (event, lifecycle): post-action validations executed as external scripts. Zero LLM context cost.
* **MCP Servers** (tool call): access to external systems via tools made available to agents.

**Evaluation against priorities**:
* **Efficiency**: high. Each mechanism optimizes for its scenario. Instructions pay fixed cost only in their scope; skills load on demand; agents isolate context.
* **Predictability**: balanced. Critical rules go in instructions (deterministic). Contextual rules go in skills (probabilistic, acceptable).
* **Reusability**: high. Skills and instructions are cross-agent by nature.
* **Extension**: requires understanding which mechanism to use, but the decision tree in extensibility.md guides this choice.

## Decision

Differentiated model by activation type (Option 3). The combination of mechanisms allows optimizing the trade-off between determinism and context efficiency on a case-by-case basis.

The accepted trade-off is greater cognitive complexity for the consumer: they need to decide which mechanism to use. The framework mitigates this with a decision tree documented in [extensibility.md](../extensibility.md) and the [devsquad.extend](../../.github/agents/devsquad.extend.agent.md) agent that guides the choice.

### Selection criteria

| Criterion | Instruction | Skill | Agent |
|-----------|-------------|-------|-------|
| Activation | Deterministic (glob) | Semantic (description) | Explicit (invocation) |
| Volume | < 50 lines | 50-200 lines | > 200 lines or tools |
| Cost | Always loaded | On demand | Isolated |
| Scope | By file type | Cross-agent | Own context |
| Predictability | High | Medium | High |

### When semantic activation fails

Skills with generic descriptions may not activate when needed (under-triggering). Mitigations:
* Include specific keywords in the description ("Use when", "Do not use for")
* Complement critical skills with a lower-volume equivalent instruction (as done with `documentation-style`)
* Test activation with representative prompts before publishing

### Summary comparison

| Aspect | All instructions | All skills | Differentiated model |
|--------|-----------------|------------|---------------------|
| Context efficiency | Low (always loads) | Good (on demand) | High (optimized per case) |
| Predictability | High | Low | Balanced |
| Reusability | Partial | High | High |
| Consumer complexity | Low | Low | Medium (mitigated by docs and devsquad.extend) |

## References

* [Framework Extensibility](../extensibility.md) (decision tree and examples)
* [Agent devsquad.extend](../../.github/agents/devsquad.extend.agent.md) (interactive selection guide)
