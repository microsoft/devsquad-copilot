# Harness Learnings

* **Status**: Proposed
* **Date**: 2026-04-20

## Context

The framework coordinates 25+ agents across the full software development lifecycle (specify, plan, implement, review, refine). Each agent operates in an isolated context window and produces feedback (review findings, test failures, drift detections, debugging outcomes). When an agent struggles with a codebase-specific pattern, the correction is ephemeral: the self-correction loop fixes the immediate issue, but the learning is lost when the session ends. The next session repeats the same mistake, triggers the same correction loop, and wastes the same tokens.

Examples of recurring patterns observed in practice:
* The agent generates auth code without token refresh handling, requiring 2 correction loops every time
* Test suites fail because a database seed step is needed before running, but the agent discovers this through trial and error each session
* Review finds the same API backward-compatibility violation repeatedly because the agent does not know about the project's compatibility matrix
* The agent adds dependencies without checking the project's approved-dependency policy

The harness engineering discipline (Fowler, 2025; OpenAI, 2025) frames this as the "steering loop" problem: the human's job is to iterate on the harness whenever an issue repeats, improving feedforward guides and feedback sensors so the same failure becomes less probable over time.

The framework currently has no mechanism for this. Agents cannot learn from past sessions, and there is no structured way to capture, store, and retrieve codebase-specific operational knowledge.

## Priorities and Requirements (ordered)

1. **Zero-friction capture**: Learnings must be captured at the moment of observation without requiring PRs, human approval, or source-code changes. If capture is expensive, agents will not do it consistently.
2. **Immediate availability**: Learnings must be usable by agents in the next session. A mechanism that requires a release cycle to propagate is too slow.
3. **Whole-lifecycle coverage**: Learnings can originate from any phase (implement, verify, review, refine, debug) and be consumed by any phase (implement, review, plan, specify). The mechanism must not be tied to a single agent.
4. **Self-curation**: The mechanism must prevent unbounded growth. Stale, unconfirmed, or contradictory learnings must be managed automatically without requiring human gardening.
5. **Path to durability**: High-confidence learnings that prove their value over time should have a path to becoming permanent harness controls (instruction rules, hooks, skill amendments). Local workspace knowledge should be promotable to shared team knowledge.
6. **Low context cost**: Agents must be able to consult learnings without loading the entire history into their context window. Filtering by relevance (phase, dimension, affected modules) must be supported.
7. **Consistency with existing patterns**: The mechanism should follow established framework conventions for workspace-level state.

## Options Considered

### Option 1: Store learnings in `.memory/harness-learnings.md`

Use the existing `.memory/` directory (the same mechanism used by `board-config.md` and `git-config.md`) to store a structured markdown file of codebase-specific learnings. A new skill (`harness-learnings`) provides capture and consult procedures. Learnings follow a two-tier lifecycle: Tier 1 captures in `.memory/` with confidence scoring, Tier 2 promotes proven learnings to permanent harness controls via `devsquad.extend`.

**Evaluation against priorities**:
* **Zero-friction capture**: `.memory/` is a local directory. Writing a learning is a file edit, no PR or approval required. The skill provides a structured format so agents produce consistent entries.
* **Immediate availability**: The file exists on disk. The next session reads it on phase start.
* **Whole-lifecycle coverage**: The skill is invoked by any agent at any phase. Capture triggers are embedded in implement, verify, review, refine, and debugging-recovery. Consumption is filtered by phase and dimension.
* **Self-curation**: Confidence scoring (low/medium/high), occurrence tracking, auto-pruning of stale unconfirmed entries (60 days), conflict detection, and a size cap (200 entries) with promotion pressure.
* **Path to durability**: Two-tier design. When confidence reaches high and occurrences reach 3+, the skill suggests promotion to instruction/hook/skill via `devsquad.extend`. Promotion is human-gated.
* **Low context cost**: Agents filter by Phase and Dimension fields, scanning only relevant entries. The structured format (one heading per learning) supports selective reading.
* **Consistency**: `.memory/` is the established convention for workspace-level state. The pattern (hook seeds file, skill reads/writes file, agents consult file) is identical to board-config and git-config.

### Option 2: Patch harness source code directly

When a recurring failure is detected, propose a concrete patch to the harness source: a new instruction rule in `.instructions.md`, a new hook script, or a skill amendment. Changes go through `devsquad.extend` and require human approval.

**Evaluation against priorities**:
* **Zero-friction capture**: Does not meet this priority. Every learning requires a code change and human approval. High friction discourages consistent capture.
* **Immediate availability**: Changes require a commit and potentially a new session to take effect. Slower feedback loop.
* **Whole-lifecycle coverage**: Met. Changes to instructions/hooks/skills affect all agents.
* **Self-curation**: Not addressed directly. Source-code changes accumulate in version control. No built-in pruning or confidence tracking.
* **Path to durability**: Excellent. Changes are permanent, version-controlled, and shared via git.
* **Low context cost**: Good for instructions and hooks (loaded automatically). Skills are loaded on demand.
* **Consistency**: Uses standard git workflow. Not a new pattern, but higher friction than `.memory/`.

### Option 3: No steering loop (status quo)

Rely on human developers to manually update instructions, hooks, and skills when they observe recurring agent failures. The framework provides no automated capture or suggestion mechanism.

**Evaluation against priorities**:
* **Zero-friction capture**: Does not apply. Humans must notice patterns, write the fix, and commit.
* **Immediate availability**: Depends on when the human acts. Could be days or never.
* **Whole-lifecycle coverage**: Not met. Humans observe a subset of agent behavior (mainly PR review).
* **Self-curation**: Not applicable.
* **Path to durability**: Changes are permanent when made, but the detection-to-fix cycle is long and unreliable.
* **Low context cost**: Not applicable.
* **Consistency**: Not applicable.

## Decision

**Option 1: Store learnings in `.memory/harness-learnings.md`.**

This option best satisfies the top priorities (zero-friction capture and immediate availability) while providing a structured path to durability via two-tier promotion. It follows the established `.memory/` convention, making it a natural extension of the framework rather than a new pattern.

Option 2 (direct source patching) is not discarded but repositioned as the Tier 2 promotion path: proven learnings graduate from `.memory/` to permanent harness controls. This gives us both speed (Tier 1) and durability (Tier 2) without the friction trade-off.

Option 3 (status quo) is rejected because it relies on human observation of a subset of agent behavior, creating a long and unreliable feedback loop.

Key trade-off accepted: `.memory/` is workspace-local and typically gitignored, so learnings do not automatically propagate across team members' machines. This is acceptable because: (a) most learnings are codebase-specific and develop naturally in each workspace through use, (b) the Tier 2 promotion path is the mechanism for sharing durable learnings via git, and (c) teams that want shared learnings can choose to commit `.memory/harness-learnings.md`.

## Implementation Notes

1. Create skill `harness-learnings` with capture and consult procedures.
2. Define structured learning format with stable IDs, phase, dimension, scope (file paths/modules), pattern, guidance, confidence, and occurrence tracking.
3. Add capture triggers to: `implement.execute` (after self-correction loops), `implement.verify` (after finding issues), `review` (after Major/Critical findings), `refine.health` (after drift detection), `debugging-recovery` (after successful triage), `implement.finalize` (after human PR feedback).
4. Add consult steps to (initial rollout): `implement.execute` (before coding), `implement.verify` (before running tests), `review.code` (before checking patterns).
5. Add consult steps to (follow-up): `plan` (architecture learnings during design), `specify` (behaviour learnings when writing conformance cases).
6. Define promotion criteria: confidence = high AND occurrences >= 3 triggers a suggestion to harden via `devsquad.extend`.
7. Implement staleness rules: auto-prune entries with confidence = low that have not been seen in 60 days.
8. Implement conflict detection: before writing a new learning, check for contradictions with existing entries on the same scope (file paths/modules).

## References

* Martin Fowler, [Harness Engineering](https://martinfowler.com/articles/harness-engineering.html) (2025)
* OpenAI, [Harness Engineering: Leveraging Codex in an Agent-First World](https://openai.com/index/harness-engineering/) (2025)
* ADR 0001 (Agent Orchestration): docs/framework/decisions/0001-agent-orchestration.md
* ADR 0003 (Context Management): docs/framework/decisions/0003-context-management.md
* ADR 0012 (Nested Subagent Architecture): docs/framework/decisions/0012-nested-subagent-architecture.md
