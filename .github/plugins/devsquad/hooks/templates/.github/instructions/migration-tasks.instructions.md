---
name: 'Migration Task Lists'
description: 'Guidelines for creating and editing migration task decomposition files'
applyTo: 'docs/migrations/**/tasks.md'
---

When editing migration task lists, follow these rules:

- Tasks MUST be organized by migration phase to reflect sequential execution dependencies.
- Format for each task: `- [ ] [P?] Description with file path`
- [P] indicates a parallelizable task.
- Required phases: Setup, Foundational, Infrastructure Provisioning, Data Migration Setup, Cutover Automation, Rollback and Validation, Polish.
- Within Infrastructure Provisioning: Compute -> Networking -> Storage -> Identity -> Configuration.
- Within Data Migration Setup: Initial sync mechanism -> Delta capture -> Validation pipeline.
- Phase dependencies must be explicit: phases are typically sequential, not independently deployable.
- DO NOT generate separate test tasks. Tests are part of each task's acceptance criteria — the implement agent verifies coverage upon completion.
- Missing ADRs must be blocking tasks in the Foundational phase.
- Data validation tasks and rollback testing tasks are mandatory for any migration.
- When creating work items on the board, apply the checklist from the `work-item-creation` skill.
