# Rubric: ADR

## Critical Criteria

| # | Dimension | PASS Criterion | Evidence |
|---|-----------|----------------|----------|
| A1 | Ranked priorities | "Priorities and Requirements" section exists with a minimum of 2 priorities ordered by importance. Each priority has a concrete (not generic) justification. | Check priorities section |
| A2 | Options evaluated against priorities | Minimum 2 options, each explicitly evaluated against each ranked priority (meets/does not meet/partial or text). Does not use a generic pros/cons list. | Check options section |
| A3 | Decision with justification | Chosen decision has justification linked to ranked priorities, not to generic preference. | Check decision section |
| A4 | Title and domain | Title reflects the decision domain, not the choice made (e.g., "Data Persistence", not "Use of PostgreSQL"). | Check title and file name |
| A5 | Valid status | Status is one of: Proposed, Accepted, Superseded by NNNN. | Check frontmatter |

## Quality Criteria

| # | Dimension | PASS Criterion | Evidence |
|---|-----------|----------------|----------|
| A6 | User-provided options | Options came from the user or were requested, not invented or inferred from templates. | Check conversation history |
| A7 | Concrete context | Context section describes the actual project problem, not generic text. | Read context |
| A8 | Documented impact | ADR indicates which features/components are affected by the decision. | Check section |

## Cross-Verification (deep level)

- Does the ADR conflict with another existing ADR?
- Are specs referencing this ADR consistent with the decision?
- If ADR is "Proposed", are dependent tasks marked as blocked?
