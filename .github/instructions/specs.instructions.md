---
name: 'Feature Specifications'
description: 'Guidelines for creating and editing feature specs'
applyTo: 'docs/features/**/spec.md'
---

When editing feature specs, follow these rules:

- Focus on **WHAT** users need and **WHY**, never on HOW to implement.
- Written for business stakeholders, not developers.
- Every user story must be prioritized (P1, P2, P3) and independently testable.
- The spec must describe a slice that (1) has at least one conformance case that runs end-to-end, not a unit-level check; (2) can be demoed, called, or observed by someone outside the implementing team without referring to a future spec; (3) touches every layer the feature requires (data, logic, and surface). Sizing is handled by `complexity-analysis` during decomposition, not in the spec — if a slice is too large to estimate, decomposition will flag it.
- Resist specifying P2/P3 in detail until P1 is implemented and reviewed. Write a short placeholder for later priorities (intent + assumptions) and expand when the slice becomes current.
- Specs are living artifacts. When implementation reveals that a story boundary, conformance case, NFR, or entity is wrong, amend the affected section via `devsquad.refine` in Spec Amendment mode rather than deviating silently. Amendments are scoped to the affected section; whole-spec rewrites are a new envisioning cycle, not an amendment.
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
