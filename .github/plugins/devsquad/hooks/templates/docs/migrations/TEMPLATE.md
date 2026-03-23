# Migration Specification: [SYSTEM_NAME]

**Created on**: [DATE]
**Status**: Draft
**Type**: [Lift-and-Shift | Rehost | Replatform-Lite]

## Executive Summary

<!--
  Condensation of the migration scope into key decision points.
  Serves as a quick reference for agents and developers.
  Update whenever the spec changes significantly.
-->

- **Objective**: [One sentence describing what is being migrated and why]
- **Source environment**: [Where the system currently runs]
- **Target environment**: [Where the system will run after migration]
- **Scope**: [Systems and components included in this migration]
- **Downtime target**: [Zero-downtime | Planned maintenance window of X | Maximum X minutes]
- **Primary success criterion**: [Most important metric, e.g., "Zero data loss with less than 5 minutes downtime"]

## Out of Scope *(required)*

<!--
  Explicitly declare what is NOT part of this migration.
  Critical for preventing accidental modernization, which is the most common failure mode in lift-and-shift.
  Minimum 1 item.
-->

- [What is excluded and reason for exclusion]

## Assumptions

<!--
  Document infrastructure and environment assumptions.
  Examples:
  - "Network latency between source and target is equivalent to current on-prem latency"
  - "Same database engine and version available in target environment"
  - "No changes to authentication mechanism during migration"
-->

- [Assumption and basis for assuming it]

## System Mapping *(required)*

<!--
  Component-level mapping from source to target environment.
  Every component in scope must appear here.
  This is the primary input for IaC generation.
-->

| Component | Source | Target | Migration Notes |
|-----------|--------|--------|-----------------|
| [API Service] | [VM (Linux, Ubuntu 22.04)] | [Azure VM / AKS] | [Containerized or direct rehost] |
| [Database] | [SQL Server 2019] | [Azure SQL Managed Instance] | [Backup/restore compatible] |
| [Message Queue] | [RabbitMQ 3.12] | [Azure Service Bus] | [Protocol mapping required] |
| [Storage] | [NFS mount] | [Azure Blob Storage] | [Path remapping needed] |

## Environment Parity *(required)*

<!--
  Explicit constraints on environment equivalence.
  The target environment must satisfy all listed parity requirements.
  Deviations must be documented with justification and risk assessment.
-->

- **Runtime versions**: [List specific versions that MUST match, e.g., ".NET 8.0.x", "Node.js 20.x"]
- **OS versions**: [e.g., "Ubuntu 22.04 LTS or equivalent"]
- **Database versions**: [e.g., "SQL Server 2019 compatibility level 150"]
- **Configuration equivalence**: [e.g., "All environment variables and config files must produce identical runtime behavior"]
- **Dependencies**: [e.g., "All third-party packages at same major version"]
- **Deviations**: [Any known parity gaps with justification]

## Migration Scenarios & Tests *(required)*

<!--
  Testable migration sequences replacing user stories.
  Each scenario represents a critical migration phase that must be validated.
  Assign phase numbers (P1 = must complete first, P2 = depends on P1, etc.).
  Unlike feature stories, these are typically sequential, not independently deployable.
-->

### Migration Scenario 1 - [Brief Title] (Phase: P1)

[Describe this migration phase in plain language]

**Why this phase**: [Explain the dependency order and criticality]

**Validation**: [How to verify this phase completed successfully]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [migration action], **Then** [expected result]
2. **Given** [initial state], **When** [migration action], **Then** [expected result]

---

### Migration Scenario 2 - [Brief Title] (Phase: P2)

[Describe this migration phase in plain language]

**Why this phase**: [Explain the dependency order and criticality]

**Validation**: [How to verify this phase completed successfully]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [migration action], **Then** [expected result]

---

### Migration Scenario 3 - [Brief Title] (Phase: P3)

[Describe this migration phase in plain language]

**Why this phase**: [Explain the dependency order and criticality]

**Validation**: [How to verify this phase completed successfully]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [migration action], **Then** [expected result]

---

[Add more scenarios as needed, maintaining phase dependency order]

### Risk Scenarios

<!--
  Failure modes and recovery paths that must be tested.
  Minimum 2: one data-related, one infrastructure-related.
-->

- What happens when [data sync fails mid-transfer]?
- What happens when [target environment becomes unreachable during cutover]?
- How does the system handle [rollback after partial traffic switch]?

## Migration Strategy *(required)*

<!--
  High-level approach for executing the migration.
  This section informs the plan agent's artifact generation (IaC, scripts, pipelines).
-->

- **Migration approach**: [Backup/restore | CDC (Change Data Capture) | Dual-write | Snapshot + replay]
- **Deployment model**: [Blue/green | Parallel run | In-place cutover]
- **Traffic switch mechanism**: [DNS switch | Load balancer reconfiguration | Feature flag | Application-level routing]
- **Sync strategy**: [One-shot | Initial bulk + incremental delta | Continuous replication]

## Data Migration *(required)*

<!--
  Detailed data migration plan.
  This is the core of lift-and-shift. Incomplete data specs are the primary cause of migration failures.
-->

- **Data volume**: [Estimated total size across all data stores]
- **Sync strategy**: [Initial bulk load + delta sync | One-shot during maintenance window]
- **Delta handling**: [How changes during migration window are captured and applied]
- **Validation rules**:
  - Row counts must match between source and target
  - Checksum validation on critical tables: [list tables]
  - Referential integrity verified post-migration
  - [Additional domain-specific validation rules]
- **Data freeze**: [When and how write operations are frozen before cutover]

## Cutover Plan *(required)*

<!--
  Ordered steps for the actual migration execution.
  Each step must have a clear owner, duration estimate, and success criterion.
  The plan agent uses this to generate deployment pipelines.
-->

1. **Pre-cutover validation**: [Verify target environment readiness]
2. **Initial data sync**: [Bulk data transfer]
3. **Delta sync**: [Catch-up replication]
4. **Write freeze**: [Stop writes on source system]
5. **Final delta sync**: [Apply remaining changes]
6. **Data validation**: [Row counts, checksums, integrity checks]
7. **Traffic switch**: [Execute DNS/LB change]
8. **Post-cutover monitoring**: [Verify system health for X minutes]
9. **Declare success or rollback**: [Decision criteria]

## Rollback Plan *(required)*

<!--
  Steps to revert to the source environment if migration fails.
  Must be tested before the actual cutover.
-->

- **Rollback trigger**: [Conditions that trigger rollback, e.g., "data validation failure", "error rate above X%"]
- **Rollback steps**:
  1. [Revert traffic to source system]
  2. [Resume writes on source]
  3. [Verify source system operational]
  4. [Assess and preserve any data written to target during cutover]
- **Maximum rollback time**: [X minutes from decision to full revert]
- **Rollback tested**: [Yes/No, date of last test]

## Requirements *(required)*

### Functional Requirements

<!--
  System behavior requirements that must hold post-migration.
  Focus on parity: the system MUST behave identically to the source.
-->

- **FR-001**: The system MUST [behavioral parity requirement, e.g., "return identical API responses for all existing endpoints"]
- **FR-002**: The system MUST [data requirement, e.g., "preserve all historical data with no record loss"]
- **FR-003**: The system MUST [integration requirement, e.g., "maintain all existing external integrations"]

### Non-Functional Requirements *(required)*

<!--
  Performance, reliability, and operational requirements for the target environment.
  These define acceptable deviation from source environment behavior.
-->

- **NFR-001**: [Latency parity, e.g., "API response latency must not increase by more than 10% compared to source baseline"]
- **NFR-002**: [Throughput, e.g., "System must handle X requests per second (matching current production peak)"]
- **NFR-003**: [Availability, e.g., "99.9% uptime SLA post-migration"]
- **NFR-004**: [Error rate, e.g., "Error rate must not exceed current baseline of X%"]

## Success Criteria *(required)*

<!--
  Measurable outcomes that define migration success.
  These should be verifiable by automated checks where possible.
-->

### Measurable Outcomes

- **SC-001**: [Data integrity, e.g., "Zero data loss: 100% row count and checksum match between source and target"]
- **SC-002**: [Downtime, e.g., "Total downtime during cutover is less than X minutes"]
- **SC-003**: [Parity, e.g., "100% API response parity validated against baseline test suite"]
- **SC-004**: [Rollback, e.g., "Rollback completes successfully within X minutes in pre-cutover test"]
- **SC-005**: [Operational, e.g., "Monitoring and alerting operational within X minutes of cutover"]

## Conformance Criteria *(required)*

<!--
  Acceptance tests derived directly from the spec.
  Any implementation must pass all these criteria.
  Format: Input/Condition -> Expected Output (technology-independent).
  Minimum 3 cases: parity validation, failure/rollback, edge case.
-->

### Conformance Cases

| ID | Scenario | Input / Condition | Expected Output |
|----|----------|-------------------|-----------------|
| CC-001 | [Data parity after full sync] | [Query: SELECT COUNT(*) on all tables] | [Identical counts on source and target] |
| CC-002 | [API parity post-cutover] | [Replay baseline request set against target] | [Identical response bodies and status codes] |
| CC-003 | [Rollback execution] | [Trigger rollback during cutover] | [Source system fully operational within X minutes] |
| CC-004 | [Partial failure recovery] | [Network interruption during delta sync] | [Sync resumes from last checkpoint, no data corruption] |

<!--
  These criteria serve as a contract between spec and implementation.
  The agent must verify the implementation against these cases.
-->

## Related Specs

<!--
  Bidirectional links to related specifications.
  Feature specs that depend on or are affected by this migration.
  Other migration specs for related systems.
-->

- [FS-001: Feature name](../features/<short-name>/spec.md) - [Relationship description]
- [MS-001: Migration name](../migrations/<short-name>/spec.md) - [Relationship description]
