---
name: 'Task Lists'
description: 'Guidelines for creating and editing task decomposition files'
applyTo: 'docs/features/**/tasks.md'
---

When editing task lists, follow these rules:

- Tasks MUST be organized by user story to enable independent implementation.
- Format for each task: `- [ ] [P?] Description with file path`
- [P] indicates a parallelizable task.
- Required phases: Setup, Foundational, User Stories (P1, P2, P3...), Polish.
- Within each story: Models -> Services -> Endpoints -> Integration.
- Each phase must be a complete and independently testable increment.
- DO NOT generate separate test tasks. Tests are part of each task's acceptance criteria — the implement agent verifies coverage upon completion.
- Missing ADRs must be blocking tasks in the Foundational phase.
- Task lists are re-generated scope-by-scope when the spec is amended mid-implementation (see `concepts/spec-amendment`). Only tasks derived from the amended user story or section should change; tasks outside the amended scope must be preserved verbatim, along with their completion status on the board.
- When creating work items on the board, apply the checklist from the `work-item-creation` skill.
