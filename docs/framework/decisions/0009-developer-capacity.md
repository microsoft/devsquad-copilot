# Developer Capacity

**Status**: Accepted
**Date**: 2026-03-07

## Context

Developers frequently accumulate in-progress tasks without finishing any. In projects with AI-generated code, the temptation to "pick up one more task" increases because the perceived cost of starting is low. The result is constant context switching, partially completed tasks, and long-lived branches that accumulate conflicts. The framework needs to define limits on simultaneous work.

## Priorities and Requirements (ordered)

1. **Context switching reduction** -- Each context switch between tasks has real cognitive cost. The developer loses mental state, needs to reload context, and decision quality degrades. The limit should minimize switches.
2. **Completed vs. started tasks** -- Real progress is measured by completed tasks (code + tests + PR), not by started tasks. The model should incentivize completion before starting new work.
3. **Flexibility for blockers** -- When a task is blocked (external dependency, awaiting review), the developer needs to be able to work on something else. The limit cannot be so rigid that it paralyzes the developer.
4. **Enforcement simplicity** -- The rule must be simple enough to be automatically verified by the workflow, without subjective judgment.

## Options considered

### Option 1: No limit on in-progress tasks

Each developer manages their own workload. Reliance on individual discipline.

**Evaluation against priorities**:
- **Context switching reduction**: Nonexistent. No structural incentive to limit.
- **Completed vs. started tasks**: Weak. Nothing prevents accumulating 5+ "in-progress" tasks with none completed.
- **Flexibility for blockers**: Total. Developer can always pick up another task.
- **Enforcement simplicity**: Maximum. No rule to enforce.

### Option 2: Fixed WIP limit per developer (classic Kanban)

Rigid limit of N in-progress tasks per developer. When the limit is reached, the system blocks new assignments until a task is completed.

**Evaluation against priorities**:
- **Context switching reduction**: Good if N is low (2-3). Ineffective if N is high.
- **Completed vs. started tasks**: Good. Blocking forces completion before new starts.
- **Flexibility for blockers**: Weak. If all N tasks are blocked, the developer is stuck. Rigid blocking doesn't distinguish "developer accumulating" from "developer blocked".
- **Enforcement simplicity**: Good. Simple count.

### Option 3: One task at a time with soft concurrency limit

Main rule: developers work on one task at a time. Soft limit of 3 in-progress tasks as a warning signal, not a block. When the limit is reached, the system recommends finishing a task before picking up another, but the developer can override with justification.

**Evaluation against priorities**:
- **Context switching reduction**: High. The "one at a time" rule is the strongest mechanism. The limit of 3 accommodates blocking situations without incentivizing accumulation.
- **Completed vs. started tasks**: High. "One at a time" prioritizes completion. The warning at 3 signals accumulation.
- **Flexibility for blockers**: Good. A blocked developer can pick up another task (up to 3). The system signals but doesn't block.
- **Enforcement simplicity**: Good. Simple count + confirmation prompt.

## Decision

One task at a time with soft concurrency limit (Option 3). The "one task at a time" rule meets the primary priority (context switching reduction) directly. The soft limit of 3 balances flexibility for blockers with a warning signal against accumulation. The accepted trade-off is that the developer can ignore the warning, meaning the system relies on team norms instead of rigid enforcement. In practice, the warning with a list of in-progress tasks is sufficient for the developer to reflect before accumulating.

The `work-item-workflow` skill implements this decision by checking capacity before assigning a new task:

```
You already have [N] tasks in progress:

- [ID]: [title]

[F] Finish a task before picking up another (recommended)
[C] Continue and pick up another task
```

### Summary comparison

| Aspect | No limit | Rigid WIP | One at a time + soft limit |
|--------|---------|-----------|---------------------------|
| Context switching reduction | Nonexistent | Good (if N low) | High |
| Completed vs. started tasks | Weak | Good | High |
| Flexibility for blockers | Total | Weak | Good |
| Enforcement simplicity | Maximum | Good | Good |

## References

* `work-item-workflow/SKILL.md` -- capacity check before assigning tasks
* `delivery-guardrails.md` -- context on autonomy limits and capacity
