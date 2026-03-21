# Rubric: Migration Spec (spec.md)

Evaluate each dimension as PASS or FAIL. Each FAIL must include **what is wrong** and **how to fix it**.

## Critical Criteria (FAIL blocks delivery)

| # | Dimension | PASS Criterion | Evidence |
|---|-----------|----------------|----------|
| MS1 | System mapping complete | Every in-scope component has source, target, and migration notes. No component is missing from the table. | Review System Mapping table |
| MS2 | Data migration defined | Data volume estimated, sync strategy specified, validation rules listed (row counts + checksums at minimum). | Check Data Migration section |
| MS3 | Cutover plan ordered | Numbered steps from pre-validation through post-cutover monitoring. Each step has a clear completion criterion. | Check Cutover Plan section |
| MS4 | Rollback plan actionable | Rollback trigger conditions defined, revert steps listed, maximum rollback time specified. | Check Rollback Plan section |
| MS5 | Conformance criteria | Minimum 3 cases: parity validation, failure/rollback, and edge case. Each has ID, scenario, input/condition, and expected output. | Check CC-XXX table |
| MS6 | NFRs quantified | Non-functional requirements include specific numeric thresholds (latency, throughput, availability, error rate) compared against source baselines. | Review NFR-XXX items |

## Quality Criteria (FAIL generates alert, does not block)

| # | Dimension | PASS Criterion | Evidence |
|---|-----------|----------------|----------|
| MS7 | Environment parity defined | Runtime versions, OS versions, DB versions, and dependencies are listed with specific version constraints. | Check Environment Parity section |
| MS8 | Migration scenarios testable | Each migration scenario has phase number, acceptance scenarios in Given/When/Then format, and a validation method. | Check Migration Scenarios section |
| MS9 | Risk scenarios identified | Minimum 2 risk scenarios: one data-related, one infrastructure-related. | Check Risk Scenarios subsection |
| MS10 | Success criteria measurable | Criteria include concrete metrics for data integrity, downtime, parity, and rollback. All are verifiable by automated checks. | Check SC-XXX items |
| MS11 | Scope boundaries clear | Out of Scope section exists with at least 1 item. Items explicitly prevent accidental modernization. | Check Out of Scope section |
| MS12 | Executive summary complete | Contains: objective, source environment, target environment, scope, downtime target, primary success criterion. | Check 6 points |
| MS13 | Clarification limit | Maximum 3 [NEEDS CLARIFICATION] markers. Each has a specific question and described impact. | Count markers |

## Cross-Verification (deep level)

- Does the system mapping cover all components mentioned in the executive summary scope?
- Are cutover plan steps consistent with the migration strategy (approach, deployment model, traffic switch)?
- Do success criteria align with NFR thresholds?
- Does the rollback plan address failure modes identified in risk scenarios?
- If related feature specs exist, are cross-references bidirectional?
- Are data validation rules in conformance criteria consistent with data migration validation rules?
