# Socratic AI

* **Status**: Accepted
* **Date**: 2025-02-01

## Context

AI agents that generate code and artifacts create a risk of passive automation: the developer accepts outputs without understanding the reasoning, loses critical judgment capacity, and accumulates knowledge debt. In teams with early-career developers or those ramping up, this effect is more pronounced.

The framework needs to define how agents interact with the developer: execute silently, explain what they did, or involve the developer in the decision-making process.

## Priorities and Requirements (ordered)

1. **Knowledge transfer**: every interaction with the framework should be a learning opportunity. The developer should leave the session understanding the *why* behind decisions, not just the result.
2. **Speed for experienced developers**: senior developers should not be slowed down by pedagogical mechanisms. The framework should adapt the interaction level to the context.
3. **Decision quality**: confirmation bias (accepting the agent's first suggestion) and automation bias (blindly trusting the output) should be structurally mitigated.
4. **Traceability**: decisions made during the flow should be auditable. The reasoning that led to each choice should be recorded.

## Options considered

### Option 1: Silent execution

Agents execute the task and deliver the result. Default behavior of most generative AI tools.

**Evaluation against priorities**:
* **Transfer**: None. The developer receives the output without understanding the reasoning.
* **Speed**: Excellent. No intermediate interaction.
* **Decision quality**: Weak. Accepting without questioning is the path of least resistance.
* **Traceability**: Weak. No reasoning record.

### Option 2: Post-execution explanation

Agents execute and then explain what they did and why. The developer can review but the work is already done.

**Evaluation against priorities**:
* **Transfer**: Partial. Explanation exists but arrives late (decision already made, anchoring bias).
* **Speed**: Good. Execution is not blocked.
* **Decision quality**: Partial. Developer can review, but reverting is more costly than deciding together.
* **Traceability**: Good. Explanation can be recorded.

### Option 3: Socratic AI (questioning before execution)

Agents ask before assuming, verify understanding, explain principles during decision-making, and adapt the interaction level to the task's impact.

**Evaluation against priorities**:
* **Transfer**: High. The developer participates in the decision and understands the reasoning before execution. Mechanisms include: Socratic questioning, comprehension checkpoints, anti-pattern detection.
* **Speed**: Moderate by default, but adaptable. Low-impact tasks use fast-track mode (no checkpoints). High-impact tasks require confirmation.
* **Decision quality**: High. Confirmation bias mitigated by active questioning. Automation bias mitigated by comprehension checkpoints.
* **Traceability**: High. Reasoning Log records each decision with the principle that guided it.

## Decision

Socratic AI (Option 3). The primary priority (knowledge transfer) is met significantly better. The speed trade-off is mitigated by impact-based adaptation: low-impact tasks use streamlined/fast-track mode, preserving speed when judgment already exists.

### How it manifests in agents

| Mechanism | Where | Behavior |
|-----------|-------|----------|
| Socratic questioning | `sdd.plan` | Guides technical decisions with questions instead of prescribing solutions |
| Principle explanation | `sdd.implement` | When presenting an implementation plan (medium/high impact), makes explicit the engineering principle guiding the approach |
| Comprehension checkpoint | `sdd.implement` | Before executing, asks the developer to explain what will be done; rejects generic responses |
| Anti-pattern detection | `sdd.implement` | When the user says "it works but I don't know why", questions understanding before proceeding |
| Knowledge transfer | `sdd.implement` | After implementation, asks verification questions and reports principles practiced in the session |
| Learning Insights | `sdd.review` | Connects findings to reusable fundamentals, explains why something is a problem in production |
| Applied principle | Reasoning Log | Each recorded decision includes the principle or heuristic that guided it |

### What Socratic AI is not

* Does not replace human mentorship: it facilitates knowledge transfer, but communication and pair programming remain essential.
* Does not slow down the flow for seniors: mechanisms like streamlined and fast-track mode (low impact) preserve speed when judgment already exists.

## References

* Russinovich, M. and Hanselman, S. (2026). _Redefining the Software Engineering Profession for AI_. Communications of the ACM. DOI: [10.1145/3779312](https://dl.acm.org/doi/10.1145/3779312)
* [Anthropic Research: How AI assistance impacts the formation of coding skills](https://www.anthropic.com/research/AI-assistance-coding-skills)
