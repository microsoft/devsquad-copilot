# Rubric: Tasks (tasks.md / work items)

## Critical Criteria

| # | Dimension | PASS Criterion | Evidence |
|---|-----------|----------------|----------|
| T1 | User story coverage | Every user story from the spec has at least 1 associated task. | Cross-check spec.md with tasks.md |
| T2 | Traceability | Every task references the user story (US-XXX) and the functional requirements (RF-XXX) it implements. | Check description of each task |
| T3 | Consistent ordering | Sequential tasks respect dependencies (models before services, services before endpoints). No task depends on another that comes after it. | Check phases and dependencies |
| T4 | ADRs as blockers | Missing ADRs with status "Proposed" have blocking tasks created in the foundational phase. | Cross-check with ADRs |

## Quality Criteria

| # | Dimension | PASS Criterion | Evidence |
|---|-----------|----------------|----------|
| T5 | File path | Every implementation task includes the file path where the change will be made. | Check format |
| T6 | Incremental phases | Each phase is a complete and independently testable increment. | Analyze phases |
| T7 | Complexity analyzed | Each user story had complexity analysis with known work, risks, and recommendation. | Check if complexity-analysis skill was applied |
| T8 | Consistency with ADRs | Tasks reference correct technologies and versions per ADRs (ADR takes precedence over plan.md). | Cross-check tasks with ADRs |

## Cross-Verification (deep level)

- Do tasks cover all conformance criteria (CC-XXX) from the spec?
- Are complexity estimates aligned with the volume of tasks?
- Do external dependencies identified in the complexity analysis have corresponding tasks?
