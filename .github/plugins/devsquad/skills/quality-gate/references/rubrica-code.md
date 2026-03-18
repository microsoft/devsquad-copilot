# Rubric: Code (implementation)

Applicable after `sdd.implement` completes a medium or high impact task. Does not replace human code review, complements it with automated conformance verification.

## Critical Criteria

| # | Dimension | PASS Criterion | Evidence |
|---|-----------|----------------|----------|
| C1 | Conformance with spec | Code implements the functional requirements (RF-XXX) mapped in the task. Relevant conformance criteria (CF-XXX) are met. | Cross-check with spec.md |
| C2 | Conformance with ADR | Technologies, patterns, and versions used match the referenced ADRs. | Cross-check with ADRs |
| C3 | No regression | Existing tests continue passing (if the project has tests). | Run test suite |
| C4 | Behavior coverage | New code with medium/high impact has tests that validate implemented behavior (relevant success and error scenarios). Bug fixes have a test that reproduces the bug. Exemptions: infrastructure tasks, configuration, or when there is no test framework in the project. | Check new/modified tests |

## Quality Criteria

| # | Dimension | PASS Criterion | Evidence |
|---|-----------|----------------|----------|
| C5 | Consistency with codebase | Code follows existing patterns in the project (naming, structure, error handling). | Compare with adjacent code |
| C6 | Error handling | Expected error paths (identified in the spec) have explicit handling. | Check error scenarios from spec |
| C7 | Traceability | Commit references task/issue. If using a branch, the name follows the convention. | Check git |
