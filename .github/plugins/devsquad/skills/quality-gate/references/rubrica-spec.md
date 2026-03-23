# Rubric: Spec (spec.md)

Evaluate each dimension as PASS or FAIL. Each FAIL must include **what is wrong** and **how to fix it**.

## Critical Criteria (FAIL blocks delivery)

| # | Dimension | PASS Criterion | Evidence |
|---|-----------|----------------|----------|
| S1 | Testable requirements | Every functional requirement can be verified with concrete expected input and output. None uses vague terms without quantification ("fast", "easy", "intuitive"). | Review each RF-XXX |
| S2 | Conformance criteria | Minimum 3 cases: happy path, error, and edge. At least one negative case (must NOT happen). Each case has ID, scenario, input, and expected output. | Check CC-XXX table |
| S3 | Prioritized user stories | Every user story has priority (P1/P2/P3) and is independently testable. | Check user stories section |
| S4 | Defined scope | An out of scope section exists with at least 1 item. | Check section |

## Quality Criteria (FAIL generates alert, does not block)

| # | Dimension | PASS Criterion | Evidence |
|---|-----------|----------------|----------|
| S5 | Measurable success criteria | Criteria include concrete metrics, are technology-independent, and verifiable without implementation details. | Check section |
| S6 | Technical decisions identified | Implicit decisions are listed with status (ADR exists / missing). | Check decisions table |
| S7 | Clarification limit | Maximum 3 [NEEDS CLARIFICATION] markers. Each has a specific question and described impact. | Count markers |
| S8 | Executive summary | Contains: objective (1 sentence), primary user, delivered value, scope, main success criterion. | Check 5 points |
| S9 | Invariants | For features with state mutations or external integrations, cross-cutting properties that must always hold are documented. | Check Invariants section |
| S10 | Failure modes | For features with external dependencies or shared state, failure conditions (timeouts, partial failures, concurrency) are documented. | Check Failure Modes subsection |

## Cross-Verification (deep level)

- Does the spec correctly reference existing ADRs?
- Are technical decisions identified in the spec aligned with ADRs?
- If envisioning exists, are pain points/goals reflected in success criteria?
