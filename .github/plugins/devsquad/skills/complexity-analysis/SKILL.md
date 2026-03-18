---
name: complexity-analysis
description: Complexity analysis for user stories with known work, risks, and scenarios. Use when you need to estimate effort, points, size, or analyze complexity of a user story. Do not use for sprint estimates (use devsquad.sprint) or for artifact quality validation (use quality-gate).
---

## Principle

Focus on the unknowns, not the knowns. Unknown work dominates software projects.

## Evidence Rule

Every classification (known/unknown) must cite the evidence that supports it. Reference code, ADR, spec, or absence thereof. If uncertain, say so and indicate what information would resolve the uncertainty.

## Analysis Structure

### 1. Known Work

Tasks whose effort can be estimated with confidence:
- We have done something similar in this project
- Established pattern in ADR or existing code
- Well-defined scope in the spec
- Existing test coverage in the affected area
- Localized change (few impacted dependencies)

For each item, indicate *why* it is known (e.g., "CRUD endpoint, same pattern as `src/api/users`").

### 2. Unknown Work (Risks)

Signals of uncertainty:
- First time (new technology, integration, or pattern)
- External dependency (third-party API, another team's service)
- Vague requirement ("must be fast", "easy to use")
- Pending decision (no ADR exists for technical choice)
- Legacy code (area without tests or documentation)
- Concurrency/scale (behavior under load not tested)
- Cross-team coordination without agreed interface

For each risk, indicate: **what** the risk is, **why** it is a risk, and **impact** if it materializes.

### 3. Dependencies

| Dependency | Owner (team/service) | Status | Impact if delayed |
|------------|----------------------|--------|-------------------|

Flag tentative dependencies, without commitment, or without agreed timeline.

### 4. Open Questions

Before proposing scenarios, list decisions or information that need a human response:
- Decisions needed before starting
- Pending requirement clarifications
- Access or approvals not granted

### 5. Scenarios (2-3 approaches)

| Scenario | Approach | If it goes well | If risks materialize | Trade-offs |
|----------|----------|-----------------|----------------------|------------|

### 6. Recommendation

Indicate the recommended scenario with explicit justification ("recommended because..."), linking to evidence and identified risks.

For high risks, suggest a spike or timebox to reduce uncertainty before committing.

## Risk Classification

| Risk | Criteria | Implication |
|------|----------|-------------|
| High | 2+ unknown risks, critical external dependency, or missing ADR | Mandatory supervision, consider spike |
| Medium | 1 manageable risk, or complex logic | Validation checkpoints |
| Low | Only known work, established pattern | Candidate for autonomous execution |

## Format for Work Items

In the User Story body (GitHub/Azure DevOps):

```markdown
## Complexity Analysis

**Risk:** [High/Medium/Low]

### Known Work
- Item 1 (estimate)
- Item 2 (estimate)

### Identified Risks
- Risk 1: [description and potential impact]
- Risk 2: [description and potential impact]

### Scenarios
| Scenario | Base effort | If risks materialize | Recommended? |
|----------|-------------|----------------------|--------------|
| A | X days | Y days | |
| B | X days | Y days | yes |

### Decision
[Chosen scenario and justification, or "Awaiting team decision"]
```

## When to Revisit Analysis

The analysis should be updated when:

- A risk materializes (document actual impact)
- A new risk is discovered during implementation
- The scenario decision is changed
- A relevant ADR is created or modified

## Anti-patterns

- Do not give a number without justification (e.g., "3 story points")
- Do not ignore risks to appear faster
- Do not list only known work
- Do not present a single scenario as "the solution"
- Do not hide assumptions: always make them explicit
- Do not claim confidence you do not have: declare the uncertainty
