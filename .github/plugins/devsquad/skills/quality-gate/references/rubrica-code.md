# Rubric: Code (implementation)

Applicable after `devsquad.implement` completes a medium or high impact task. Does not replace human code review, complements it with automated conformance verification.

## Critical Criteria

| # | Dimension | PASS Criterion | Evidence |
|---|-----------|----------------|----------|
| C1 | Conformance with spec | Code implements the functional requirements (RF-XXX) mapped in the task. Relevant conformance criteria (CC-XXX) are met. | Cross-check with spec.md |
| C2 | Conformance with ADR | Technologies, patterns, and versions used match the referenced ADRs. | Cross-check with ADRs |
| C3 | No regression | Existing tests continue passing (if the project has tests). | Run test suite |
| C4 | Behavior coverage | New code with medium/high impact has tests that validate implemented behavior (relevant success and error scenarios). Bug fixes have a test that reproduces the bug. Exemptions: infrastructure tasks, configuration, or when there is no test framework in the project. | Check new/modified tests |

## Quality Criteria

| # | Dimension | PASS Criterion | Evidence |
|---|-----------|----------------|----------|
| C5 | Consistency with codebase | Code follows existing patterns in the project (naming, structure, error handling). | Compare with adjacent code |
| C6 | Error handling | Expected error paths (identified in the spec) have explicit handling. External calls (HTTP, DB, file I/O, SDK) have error handling at each call site. | Check error scenarios from spec and scan call sites |
| C7 | Traceability | Commit references task/issue. If using a branch, the name follows the convention. | Check git |
| C8 | No duplicate logic | No substantially similar code blocks (>15 lines) exist across files that should be a shared utility. | Search for distinctive snippets of new code in the codebase |
| C9 | Justified dependencies | New packages/libraries are referenced in spec/plan or have clear technical justification. No known security advisories. | Check dependency additions against spec and advisory databases |
