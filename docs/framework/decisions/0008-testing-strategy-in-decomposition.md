# Testing Strategy in Decomposition

**Status**: Accepted
**Date**: 2026-03-07

## Context

When decomposing features into tasks, it is necessary to decide how tests fit into the work structure. The approach affects the board's granularity, the implementation flow, and the definition of "done" for each task. The main risk is tasks marked as completed without test coverage, generating silent technical debt.

## Priorities and Requirements (ordered)

1. **Guaranteed coverage** -- Every completed task must have adequate test coverage. It should not be possible to close a task without the relevant tests existing.
2. **Board overhead reduction** -- The number of work items should reflect meaningful units of work, not bureaucratic artifacts. Tasks that exist solely for tracking without decision value are noise.
3. **Continuous implementation flow** -- The developer should be able to implement code and tests in the same flow, without switching context between "code task" and "test task" for the same functionality.
4. **Progress visibility** -- The board should reflect real progress (functionality delivered and tested), not partial progress (code without tests or tests without code).

## Options considered

### Option 1: Separate test tasks

For each implementation task, create a corresponding test task. Example: "Create registration endpoint" + "Test registration endpoint".

**Evaluation against priorities**:
- **Guaranteed coverage**: Partial. The test task exists, but nothing prevents the implementation task from being closed before the test task is completed. Dependency is manual.
- **Board overhead**: High. Doubles the number of tasks. In a feature with 15 implementation tasks, the board has 30 items, most with an obvious 1:1 relationship.
- **Continuous flow**: Weak. The developer implements, closes the task, then opens another task to test what they just did. Artificial context switching.
- **Progress visibility**: Misleading. An implementation task marked "Done" without the corresponding test task suggests progress that doesn't exist.

### Option 2: Dedicated testing phase (after implementation)

All test tasks grouped in a final phase, executed after all implementation tasks.

**Evaluation against priorities**:
- **Guaranteed coverage**: Weak. Tests are postponed to the end, when delivery pressure is highest and the incentive to skip is strongest.
- **Board overhead**: Medium. Test tasks exist but are grouped.
- **Continuous flow**: Weak. Large temporal separation between implementation and testing. Context is lost.
- **Progress visibility**: Weak. All implementation appears as "Done" before any tests run.

### Option 3: Tests integrated as acceptance criteria

Don't create separate test tasks. Tests are part of each implementation task's acceptance criteria. A task is only considered completed when the code and relevant tests are ready. The implementation agent verifies coverage upon completion.

**Evaluation against priorities**:
- **Guaranteed coverage**: High. It's impossible to close the task without tests because tests are a completion condition, not a separate task. The agent validates coverage before marking as done.
- **Board overhead**: Low. Number of tasks reflects functionality units, not artifacts.
- **Continuous flow**: High. Developer implements and tests in the same unit of work, in the same mental context.
- **Progress visibility**: High. Task "Done" means functionality implemented and tested.

## Decision

Tests integrated as acceptance criteria (Option 3). The primary priority is guaranteed coverage, and this option is the only one that makes tests a completion condition instead of a separate task that can be forgotten or postponed. The accepted trade-off is lower tracking granularity: it's not possible to see on the board "implementation ready, testing pending". In practice, this intermediate state is exactly what we want to avoid, as it incentivizes closing "almost done" tasks.

The `devsquad.implement` agent is responsible for verifying coverage upon completing each task, ensuring the criterion is enforced and doesn't depend on individual discipline.

### Summary comparison

| Aspect | Separate tasks | Testing phase | Integrated in acceptance |
|--------|---------------|--------------|--------------------------|
| Guaranteed coverage | Partial | Weak | High |
| Board overhead | High (2x tasks) | Medium | Low |
| Continuous flow | Weak | Weak | High |
| Progress visibility | Misleading | Weak | High |

## References

* `tasks.instructions.md` -- rule "DO NOT generate separate test tasks"
* `delivery-guardrails.md` -- implementation checkpoints and verification
