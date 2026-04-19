---
name: 'Migration Specifications'
description: 'Guidelines for creating and editing migration specs'
applyTo: 'docs/migrations/**/spec.md'
---

When editing migration specifications, follow these rules:

- Focus on **WHAT** must be migrated and **WHERE**, never on implementation-level HOW (IaC code, scripts).
- Written for infrastructure leads and stakeholders, not solely for developers.
- Every migration scenario must have a phase number (P1, P2, P3) reflecting execution dependency order. Unlike feature stories, migration phases are typically sequential, not independently deployable.
- Every functional requirement must assert behavioral parity: the system MUST behave identically post-migration unless a deviation is explicitly documented and justified.
- Non-Functional Requirements are mandatory. Latency, throughput, availability, and error rate tolerances must be quantified against source baselines.
- System Mapping must include every in-scope component with source and target.
- Environment Parity must list specific version constraints (runtime, OS, DB, dependencies).
- Data Migration must include validation rules (row counts, checksums, referential integrity).
- Cutover Plan must be an ordered sequence of steps, each with a clear success criterion.
- Cutover Plan must address consumer redirection explicitly, including delayed consumers (cached DNS or connection strings, queue backlogs, lagging batch jobs) and the mechanism that prevents them from reaching the decommissioned source.
- Rollback Plan must specify trigger conditions, revert steps, and maximum rollback time.
- Rollback Plan must state whether the source environment can safely read state produced by the target during the overlap window, or declare that rollback is only viable before a specific cutover step.
- Success Criteria must include: data integrity metric, downtime metric, parity metric, and rollback test metric.
- Conformance criteria must have: ID, Scenario, Input/Condition, Expected Output.
- Minimum 3 conformance cases: parity validation, failure/rollback, edge case.
- Maximum 3 [NEEDS CLARIFICATION] markers total.
- Dates (including `Created on`) default to `YYYY-MM-DD`. Other formats are allowed when the consumer repo has an established convention; once chosen, apply the format consistently across all specs in the repo.
- Use the template at `docs/migrations/TEMPLATE.md` as a structure reference.
- Follow the formatting rules in the `documentation-style` skill.
