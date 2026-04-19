---
name: 'Feature Specifications'
description: 'Guidelines for creating and editing feature specs'
applyTo: 'docs/features/**/spec.md'
---

When editing feature specs, follow these rules:

- Focus on **WHAT** users need and **WHY**, never on HOW to implement.
- Written for business stakeholders, not developers.
- Every user story must be prioritized (P1, P2, P3) and independently testable.
- Every functional requirement must be testable and unambiguous. Vague terms like "fast", "easy", "intuitive" must be quantified.
- Success criteria must be measurable and technology-independent.
- Conformance criteria must have: ID, Scenario, Input, Expected Output.
- Minimum 3 conformance cases: happy path, error scenario, edge case.
- Maximum 3 [NEEDS CLARIFICATION] markers total.
- Executive Summary must declare a Change type: `new surface`, `additive to existing`, `modifies existing boundary`, or `removes existing surface`.
- When Change type is not `new surface`, the `Compatibility and Transition` section is required, and at least one compliance case (CC-C*) must cover mixed-version coexistence, delayed consumer behavior, or rollback against state written by the new version.
- Dates (including `Created on`) default to `YYYY-MM-DD`. Other formats are allowed when the consumer repo has an established convention; once chosen, apply the format consistently across all specs in the repo.
- Use the template at `docs/features/TEMPLATE.md` as a structure reference.
- Follow the formatting rules in the `documentation-style` skill.
