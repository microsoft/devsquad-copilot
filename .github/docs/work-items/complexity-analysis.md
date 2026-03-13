# Complexity Analysis for User Stories

Isolated numerical estimates (story points, hours) are of little use without context. This guide defines how to analyze complexity in a way that enables informed decisions.

## Principle

**Focus on the unknowns, not the knowns.** Unknown work dominates software projects. Useful estimates map risks and present scenarios, not numbers.

## Analysis Structure

Each user story should include a complexity analysis section with:

### 1. Known Work

List tasks whose effort can be estimated with confidence:

```markdown
**Known work:**
- Create REST endpoint for registration (½ day)
- Input validations per spec (½ day)
- Service unit tests (½ day)
```

**Criteria for "known":**
- We have done something similar in this project
- Established pattern in ADR or existing code
- Well-defined scope in the spec

### 2. Unknown Work (Risks)

Identify areas of uncertainty that may expand scope:

```markdown
**Unknown work (risks):**
- Payment API integration: first time, incomplete documentation
- Database schema: unclear whether it supports change history
- Performance: expected volume is not defined
```

**Signals of unknown work:**
| Signal | Example |
|-------|---------|
| First time | Technology, integration, or pattern never used in the project |
| External dependency | Third-party API, service from another team |
| Vague requirement | "Should be fast", "easy to use" |
| Pending decision | ADR does not exist for a required technical choice |
| Legacy code | Area of the system without tests or documentation |
| Concurrency/scale | Behavior under load not tested |

### 3. Scenarios

Present 2-3 approaches with explicit trade-offs:

```markdown
**Scenarios:**

| Scenario | Approach | If it goes well | If risks materialize | Trade-offs |
|---------|-----------|--------------|------------------------------|------------|
| A | Direct API integration | 2 days | 1 week | Simpler, but exposed to API changes |
| B | Use existing adapter | 3 days | 4 days | More code, but isolated from external changes |
| C | Mock + feature flag | 1 day + debt | 1 day | Fast delivery, but accumulates technical debt |
```

### 4. Recommendation

Indicate which scenario is recommended and why:

```markdown
**Recommendation:** Scenario B (adapter)

Justification: The payment API is in beta and has already changed 2x in the last month. 
The additional cost of 1 day compensates for the predictability and ease of 
future maintenance.
```

## Consolidated Risk Classification

After the analysis, classify the user story:

| Risk | Criteria | Implication |
|-------|-----------|------------|
| **High** | 2+ unknown risks, critical external dependency, or missing ADR | Requires supervision, checkpoint before merge |
| **Medium** | 1 manageable unknown risk, or complex business logic | Validation checkpoints recommended |
| **Low** | Only known work, established pattern | Candidate for autonomous execution |

## Format for Work Items

### In the User Story body (GitHub/Azure DevOps)

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
|---------|--------------|------------------------------|--------------|
| A | X days | Y days | |
| B | X days | Y days | ✓ |

### Decision
[Chosen scenario and justification, or "Awaiting team decision"]
```

## When to Revisit Analysis

The analysis should be updated when:

- A risk materializes (document actual impact)
- A new risk is discovered during implementation
- A scenario decision is changed
- A relevant ADR is created or modified

## Anti-patterns

**Don't:**

- Give a number without justification (e.g., "3 story points")
- Ignore risks to appear faster
- List only known work
- Present a single scenario as "the solution"

**Do:**

- Explain what is behind the estimate
- Be honest about uncertainties
- Present options with trade-offs
- Update the analysis as you learn more
