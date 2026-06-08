---
name: 'Feature Specifications'
description: 'Guidelines for creating and editing feature specs'
applyTo: 'docs/features/**/spec.md'
---

When editing feature specs, follow these rules:

- Focus on **WHAT** users need and **WHY**, never on HOW to implement.
- Written for business stakeholders, not developers.
- Every user story must be prioritized (P1, P2, P3) and independently testable.
- The spec must describe a vertical slice (tracer bullet) that (1) has at least one conformance case that runs end-to-end, not a unit-level check; (2) can be demoed, called, or observed by someone outside the implementing team without referring to a future spec; (3) touches every layer the feature requires (data, logic, and surface). Each slice cuts through all integration layers, not a horizontal slice of one layer. Sizing is handled by `complexity-analysis` during decomposition, not in the spec — if a slice is too large to estimate, decomposition will flag it.
- Every functional requirement must be testable and unambiguous. Vague terms like "fast", "easy", "intuitive" must be quantified.
- Success criteria must be measurable and technology-independent.
- Conformance criteria must have: ID, Scenario, Input, Expected Output.
- Minimum 3 conformance cases: happy path, error scenario, edge case.
- Maximum 3 [NEEDS CLARIFICATION] markers total.
- Executive Summary must declare a Change type: `new surface`, `additive to existing`, `modifies existing boundary`, or `removes existing surface`.
- Executive Summary must declare `Describes AI capability: yes | no`. When `yes`, the spec must complete the `AI Cost Posture` section (model-tier commitment, latency budget, prompt-stability invariant, per-call cost ceiling, cost-incident escalation). Behavioral constraints on the agent belong in the general `Invariants` section; service composition belongs in `Requirements` and `User Scenarios`.
- Every spec must contain a `Spec Evolution Log` section with at least one row recording the current version. Every subsequent change appends a row with version, date, change summary, trigger, and author. Valid trigger values are `new work`, `drift`, `external constraint`, one of the three `failure (<category>)` values defined in `debugging-recovery/references/failure-taxonomy.md` (`spec`, `validation`, `agent`), or `other (<short reason>)` as a transitional escape hatch.
- When Change type is not `new surface`, the `Compatibility and Transition` section is required, and at least one compliance case (CC-C*) must cover mixed-version coexistence, delayed consumer behavior, or rollback against state written by the new version.
- Dates (including `Created on`) default to `YYYY-MM-DD`. Other formats are allowed when the consumer repo has an established convention; once chosen, apply the format consistently across all specs in the repo.
- Use the template at `docs/features/TEMPLATE.md` as a structure reference.
- Follow the formatting rules in the `documentation-style` skill.
