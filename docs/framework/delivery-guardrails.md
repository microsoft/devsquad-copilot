# Guardrails for Sustainable AI-Assisted Software Delivery

The framework is built on the premise that **value lies not in generating code quickly, but in structuring thought before and after code generation**, with AI accelerating each step of that cycle.

## Why structure thought *before* generation

Code generated without structured thought typically turns into technical debt. The framework uses the following tactics:

### Phase Structuring

| Phase | Agent | What the dev does | Rework it eliminates |
|-------|-------|-------------------|---------------------|
| Vision | `sdd.envision` | Articulates business pains and objectives | "We built the wrong thing" |
| Specification | `sdd.specify` | Defines verifiable requirements and conformance criteria | "The requirement was ambiguous" |
| Planning | `sdd.plan` | Makes technical decisions with explicit trade-offs | "Why did we do it this way?" |
| Decomposition | `sdd.decompose` | Validates tasks and complexity analysis | "This task was more complex than it seemed" |
| Implementation | `sdd.implement` | Executes with comprehension checkpoints | "It works but I don't know why" |

By the time the dev reaches implementation, they have already articulated *what* they want, *why* they want it, and *how* they will do it. The generated code is not a surprise; it is a consequence of decisions they made.

### Comprehension Checkpoint

Before executing medium or high impact tasks, the `sdd.implement` agent requests confirmation of understanding:

```
Before implementing, confirm that you understand what will be done:

Task: [ID and description]
Affected files: [list]
Approach: [summary]

Briefly describe what this change does, or say "reviewed, proceed" if you have already analyzed the plan.
```

Generic responses ("ok", "go", "do it") trigger a request for more specific confirmation. The goal is to encourage the dev to process what will happen, not merely authorize it.

## Why structure thought *after* generation

[Anthropic research (2026)](https://arxiv.org/abs/2601.20245) shows that devs who delegate code to AI without cognitive engagement retain 17% less knowledge, and the greatest skill loss from passive AI use is debugging.

**Sustainable velocity = code generation x comprehension.** If comprehension is low, effective velocity is too, regardless of how many lines of code were generated. The framework adds deliberate steps that initially seem to slow things down. But over the project horizon (long-term development, team turnover, changing requirements), each step provides greater protection against exponential rework.

The framework addresses this with the following tactics:

### Knowledge Transfer Verification

After implementation, the agent asks verification questions:

```
Implementation complete. To ensure knowledge transfer:

1. Where is the entry point for this feature?
2. Which test covers the main error scenario?
3. What happens if [critical dependency] fails?
```

This ensures the dev knows how to navigate the generated code.

### Comprehension Anti-pattern Detection

The `sdd.implement` agent detects signs that the dev did not understand the code:

| Anti-pattern | Agent response |
|---|---|
| "It works but I don't know why" | "Let's understand together. What do you think each part does?" |
| "I copied it from somewhere else" | "Is that context the same as yours? What might be different?" |
| "Copilot generated this" | "Right, but do you understand what this code does? Walk me through it." |
| Trial-and-error debugging | "Before trying more things, let's understand what's happening." |

### Socratic Guidance (Don't Give Direct Answers)

When the dev has questions, the `sdd.plan` and `sdd.implement` agents guide through questions instead of giving ready-made answers:

- **Clarify the problem**: "What do you expect to happen? What is actually happening?"
- **Guide investigation**: "Have you checked the value of [variable] at this point?"
- **Point to existing resources**: "In [file:line], there is an example of how this is done."
- **Verify understanding**: "In your own words, what is causing the problem?"

The dev only receives direct implementation when they demonstrate understanding.

## Cognitive Sustainability: Protecting Developer Attention

### Impact Classification and Fast-track

Not every change needs all tactics. The framework classifies tasks by impact and adjusts the level of ceremony:

| Impact | Criteria | Ceremony |
|--------|----------|----------|
| **Low** | Typo, log, formatting | Executes directly, no checkpoints |
| **Medium** | New function, local refactoring | Plan + confirmation + automated review |
| **High** | New service, schema, public API | Mandatory ADR + approval + review + all checkpoints |

Low impact tasks skip: validation against spec, comprehension checkpoint, reasoning log, pre-PR review. This avoids unnecessary overhead that causes cognitive fatigue.

> If a task classified as low turns out to be more complex, it is reclassified to medium.

### Context Cleanup Between Phases

When multiple phases run in the same session without cleanup, assumptions from the previous phase can contaminate the next one. The framework defines clear rules:

| Transition | Recommendation | Reason |
|-----------|---------------|--------|
| specify to plan | Clear | Spec is a persistent artifact; plan should read from the file |
| plan to decompose | Clear | Tasks should come from artifacts, not from memory |
| decompose to implement | Clear | Decomposition context is not relevant for implementation |
| implement to review | **Mandatory** | Independent review requires clean context |

The Handoff Envelope is the formal context-passing contract between agents, which explicitly defines:

- **Relevant artifacts**: what the next agent should read
- **Inherited assumptions**: what was assumed and needs validation
- **Pending decisions**: what was left open
- **Discarded information**: alternatives that were considered and discarded, with rationale

### Code Churn Detection

If the dev asks to modify code generated in the same session, the agent identifies the pattern:

```
You are asking to modify code that was generated recently.

Before proceeding, this may indicate:
1. Requirement was unclear. Go back to spec?
2. Chosen approach was not adequate. Review trade-offs?
3. Legitimate requirement change. Document the reason?
```

If the pattern repeats (3+ modifications to the same code), the agent suggests pausing to review the spec/plan.
This prevents the `generate-fix-generate` cycle that consumes attention without real progress.

### Capacity Verification

Before starting work on a task, the `work-item-workflow` skill checks the developer's workload:

```
You already have [N] tasks in progress:

- #[ID]: [title]

[F] Finish a task before picking up another (recommended)
[C] Continue and pick up another task
```

The default limit is 3 tasks in progress. The dev can ignore it, but the system flags it.
Devs should work on **one task at a time**; the framework enforces this rule via workflow.

### Refusing Debugging Without Context

The agent refuses requests like "fix this" or "debug this" without sufficient context:

```
I cannot implement fixes without understanding the problem. Please provide:

1. Expected behavior vs observed behavior
2. Complete error message (if any)
3. What you have already tried
```

This protects against the cycle of "generating code to fix poorly defined problems," which frequently introduces new problems.

### Autonomy Limits by Impact

No non-trivial technical decision is executed without explicit approval:

- **Low impact**: executes directly
- **Medium impact**: presents plan and waits for confirmation
- **High impact**: requires ADR + explicit approval

> High impact tasks **are not eligible** for streamlined mode (end-to-end). The full flow with all checkpoints is mandatory.

### Risk-Based Complexity Analysis

Isolated numerical estimates (story points, hours) are of little use without context. The framework focuses on the **unknowns**, not the knowns:

- **Known work**: tasks with established patterns and clear scope
- **Unknown work (risks)**: first time, external dependency, vague requirement, missing ADR
- **Scenarios**: 2-3 approaches with explicit trade-offs ("if it goes well" vs "if risks materialize")

Explicit anti-pattern: "Don't give a number without justification (e.g., '3 story points')."

### Sprint Planning with Overload Protection

The `sdd.sprint` agent prepares planning by presenting **scope options**, not recommendations. The team decides what fits. The agent classifies items by readiness (ready / almost ready / not ready) with **cited evidence** for each classification, flagging:

- Cross-feature dependencies that are easy to forget
- Tasks that are bottlenecks (prerequisites for multiple others)
- Gaps between spec and tasks that indicate future rework

## Multi-Dev Coordination: Boundaries for Parallel Sessions

Each Copilot session operates independently, with no visibility into what other sessions are deciding. Git resolves code conflicts, and the board resolves task conflicts. But **divergent design decisions in parallel** are the real risk: two devs can make conflicting architectural decisions without knowing.

The framework addresses this risk through layers of increasing cost.

### Convention: ADRs as Synchronization Points

ADRs function as the team's "semantic lock." The convention:

- ADRs are created with **Status: Proposed** by default. An ADR should not move to **Accepted** without review by at least one other team member.
- The `sdd.plan` agent warns when a dev tries to accept an ADR directly, suggesting creating it as Proposed first.
- The board signals work in progress: if a dev is in `sdd.plan` for "Data Persistence", the work item is assigned and In Progress. Another dev sees this and knows that decision is in progress.

### Duplicate Domain Detection

Before creating a new ADR, the `sdd.plan` agent checks if there is already a Proposed or Accepted ADR in the same domain. If one exists:

- Alerts the dev with the existing ADR and its status
- Suggests reviewing the existing one before creating a new one
- If the decision has changed, guides the change flow

This prevents the scenario of two devs creating conflicting ADRs for the same domain (e.g., two "Authentication" ADRs with different decisions).

### Reactive Inconsistency Detection

The `sdd.refine` agent complements the previous layers by detecting inconsistencies that escaped:

- Proposed ADRs not reviewed for a long time
- Conflicting decisions between ADRs of related domains
- Specs updated after task creation
- Orphan work items without link to spec or feature

Using `sdd.refine` periodically is the safety net for what the proactive layers did not capture.

## Maintenance and Continuity: Surviving Team Turnover

### Persistent Artifacts as Source of Truth

Each phase of the flow produces artifacts that persist beyond the session and the people:

| Artifact | What it answers | Agent that generates it |
|----------|----------------|-------------------------|
| `envisioning/README.md` | Why does this project exist? What problem does it solve? | `sdd.envision` |
| `features/<name>/spec.md` | What should the system do? What are the conformance criteria? | `sdd.specify` |
| `architecture/decisions/*.md` | Why did we choose this technology/pattern? What alternatives? | `sdd.plan` |
| `features/<name>/plan.md` | How will we build it? Stack, data model, contracts | `sdd.plan` |
| `features/<name>/tasks.md` | What tasks, in what order, with which dependencies? | `sdd.decompose` |

A new dev on the project can read these artifacts and understand **decisions that were made months ago by people who have already left the team**.

### ADRs: Traceable Technical Decisions

Architecture Decision Records document not only *what* was decided, but *why* and *which alternatives were discarded*:

- **Title = decision domain** (e.g., "Data Persistence"), not the choice made (e.g., "Use of PostgreSQL")
- **Priorities defined before listing options** — options are evaluated against ranked priorities
- **Traceable status**: Proposed → Accepted → Updated by NNNN
- **Options come from the user, not the agent** — the agent does not invent alternatives

### Reasoning Log: Auditable Reasoning

Each agent records the decisions made during its execution:

| # | Decision | Alternatives considered | Justification | Confidence |
|---|----------|-------------------------|---------------|------------|
| 1 | CQRS for read/write | Simple Repository, Event Sourcing | Read volume 10x larger (envisioning) | High |
| 2 | Rate limiting at gateway | Per endpoint, no limiting | Inferred from multi-tenancy | Medium |

Confidence levels (High/Medium/Low) indicate what needs additional validation. Low confidence decisions require validation before proceeding.

### Session Memory: Continuity Across Sessions

For flows that span multiple sessions:

1. Persistent artifacts (specs, ADRs, tasks, work items) are the source of truth
2. When resuming, the agent reads artifacts from disk and reconstructs the necessary context
3. The Handoff Envelope (via skill `reasoning`) preserves decisions and assumptions between phases

This allows a dev to resume work days later, or another dev to continue where the first one left off.

### Independent Review with Clean Context

The `sdd.review` agent operates with one principle: **whoever implemented should not validate without a context reset**. Confirmation bias (tendency to consider correct what was just created) is reduced when the reviewer:

- Operates with clean context (the implement → review transition is mandatorily clean)
- Validates against documented artifacts (spec, ADRs, plan), not against session memory
- Classifies findings by severity with evidence (file:line)
- Does not invent problems: "If the implementation conforms to the artifacts, the result is correct"

### End-to-End Traceability

The framework maintains formal links between all levels:

```
Business vision → Epics → Features → User Stories → Tasks → Branches → PRs → Code
```

- Work items on the board with hierarchy, required tags (`copilot-generated`, `ai-model:<name>`) and validation via hooks
- Tasks reference requirements (FR-XXX) and conformance criteria (CC-XXX) from the spec
- PRs reference tasks (`Closes #N`)
- Code traceable to the requirement that motivated it

### Inconsistency Detection

The `sdd.refine` agent detects inconsistencies between artifacts that indicate outdated documentation:

| Scenario | What refine detects |
|----------|---------------------|
| Spec updated after tasks | Tasks may not reflect current requirements |
| ADR replaced with active tasks | Tasks depend on obsolete decision |
| Orphan work items | Items without link to spec or feature |

Using it periodically prevents artifacts from becoming misleading documentation — which is worse than the absence of documentation.

## Limitations and Residual Risks

No framework eliminates all risks. The main residual risks are:

1. **Artifact volume.** The framework makes it easy to generate specs, ADRs, and tasks. If the team generates more artifacts than it can maintain, the documentation becomes misleading. Mitigation: use `/sdd.refine` regularly.

2. **Illusion of rigor.** A well-formatted Reasoning Log can appear rigorous without being substantive. Human judgment about the quality of decisions is not replaceable by templates. Artifacts are vehicles for thought, not substitutes.

3. **Velocity normalization.** If the team demonstrates high velocity with the framework, leadership may normalize it as a permanent baseline. The framework protects artifact quality, but **has no mechanism to signal team overload** beyond the limit of in-progress tasks per dev.

4. **Change propagation.** The flow does not automatically propagate the impact of changes in specs/ADRs to existing work items. It depends on periodic use of `/sdd.refine` to detect inconsistencies.
