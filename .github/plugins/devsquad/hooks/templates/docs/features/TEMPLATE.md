# Feature Specification: [FEATURE_NAME]

- **Created on**: [DATE]
- **Status**: Draft

## Executive Summary

<!--
  Condensation of the spec into 3-5 key points.
  Serves as a quick reference for the agent and developers.
  Update whenever the spec changes significantly.
-->

- **Objective**: [One sentence describing what the feature does]
- **Primary user**: [Who uses it]
- **Value delivered**: [Why it matters]
- **Scope**: [What is included / excluded]
- **Change type**: [new surface | additive to existing | modifies existing boundary | removes existing surface]
- **Primary success criterion**: [Most important metric]

## Non-Scope *(required)*

<!--
  Explicitly declare what is NOT part of this feature.
  Protects the scope against implicit expansion and aligns expectations.
  Minimum 1 item.
-->

- [What is out of scope and reason for exclusion]

## Assumptions

<!--
  Document reasonable defaults assumed during specification.
  Example: "Session-based authentication (web standard, no explicit requirement)"
-->

- [Assumption and basis for making it]

## User Scenarios & Tests *(required)*

<!--
  IMPORTANT: User stories must be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning that if you implement only ONE of them,
  you will still have an MVP (Minimum Viable Product) that delivers value.
  
  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as an independent slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - [Brief Title] (Priority: P1)

[Describe this user journey in simple language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently - e.g.: "Can be fully tested by [specific action] and delivers [specific value]"]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected result]
2. **Given** [initial state], **When** [action], **Then** [expected result]

---

### User Story 2 - [Brief Title] (Priority: P2)

[Describe this user journey in simple language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected result]

---

### User Story 3 - [Brief Title] (Priority: P3)

[Describe this user journey in simple language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected result]

---

[Add more user stories as needed, each with an assigned priority]

### Edge Cases

<!--
  ACTION REQUIRED: The content of this section represents placeholders.
  Fill them in with the correct edge cases.
-->

- What happens when [boundary condition]?
- How does the system handle [error scenario]?

### Failure Modes *(include if the feature has external dependencies or shared state)*

<!--
  Document how the system should behave under real-world failure conditions.
  Required when the feature involves: external APIs, databases, message queues,
  concurrent users, distributed state, or modifies an existing boundary
  (API, event schema, stored data shape).
  Omit for purely local, single-user, stateless features with no prior version.
-->

- What happens when [external dependency] is unavailable or times out?
- What happens when two users perform [action] concurrently on the same resource?
- What happens when [operation] partially fails (e.g., payment charged but confirmation not sent)?
- What consistency model is required? (immediate, eventual, or best-effort)
- What happens during a partial rollout when some consumers still run the prior version?
- What happens when a delayed consumer (queue backlog, cached client, mobile app) catches up after the producer has advanced?
- What happens if rollback is triggered after state has been written in the new shape?

## Requirements *(required)*

<!--
  ACTION REQUIRED: The content of this section represents placeholders.
  Fill them in with the correct functional requirements.
-->

### Functional Requirements

- **FR-001**: The system MUST [specific capability, e.g.: "allow users to create accounts"]
- **FR-002**: The system MUST [specific capability, e.g.: "validate email addresses"]  
- **FR-003**: Users MUST be able to [key interaction, e.g.: "reset their password"]
- **FR-004**: The system MUST [data requirement, e.g.: "persist user preferences"]
- **FR-005**: The system MUST [behavior, e.g.: "log all security events"]

*Example of marking unclear requirements:*

- **FR-006**: The system MUST authenticate users via [NEEDS CLARIFICATION: authentication method not specified - email/password, SSO, OAuth?]
- **FR-007**: The system MUST retain user data for [NEEDS CLARIFICATION: retention period not specified]

### Key Entities *(include if the feature involves data)*

- **[Entity 1]**: [What it represents, key attributes without implementation]
- **[Entity 2]**: [What it represents, relationships with other entities]

## Success Criteria *(required)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-independent and measurable.
-->

### Measurable Outcomes

- **SC-001**: [Measurable metric, e.g.: "Users can complete account creation in less than 2 minutes"]
- **SC-002**: [Measurable metric, e.g.: "System supports 1000 concurrent users without degradation"]
- **SC-003**: [User satisfaction metric, e.g.: "90% of users successfully complete the main task on the first attempt"]
- **SC-004**: [Business metric, e.g.: "Reduce support tickets related to [X] by 50%"]

## Compliance Criteria *(required)*

<!--
  Acceptance tests derived directly from the spec.
  Any implementation must pass all these criteria.
  Format: Input → Expected Output (technology-independent).
-->

### Compliance Cases

| ID | Scenario | Input | Expected Output |
|----|----------|-------|-----------------|
| CC-001 | [Main happy path scenario] | [Valid input data] | [Expected result] |
| CC-002 | [Error scenario] | [Invalid or incomplete data] | [Error message or behavior] |
| CC-003 | [Edge case] | [Boundary or extreme condition] | [Expected behavior] |
| CC-004 | [Must NOT happen] | [Input that could trigger wrong behavior] | [Behavior that must not occur, e.g.: "Must NOT create duplicate records"] |
| CC-C01 | [Mixed-version coexistence or rollback against state] | [Payload written or action taken by new version] | [Prior version still processes without error, or rollback restores prior behavior against existing data] |

<!--
  These criteria serve as a contract between spec and implementation.
  The agent must verify the implementation against these cases.
  Include at least one negative case (CC-XXX with "Must NOT" scenario)
  to define what the system must never do.
  When the Change type is not "new surface", include at least one CC-C*
  (compatibility) case covering mixed-version coexistence, delayed consumer
  behavior, or rollback against state written by the new version.
-->

## Invariants

<!--
  Cross-cutting properties that must ALWAYS hold, regardless of implementation path.
  Invariants describe the PROPERTY, not a specific test case.
  Include this section when the feature involves state mutations, financial transactions,
  concurrent access, or external integrations.
  Omit for simple read-only or UI-only features.
-->

- [Property that must always hold, e.g.: "Each idempotency key maps to at most one transaction"]
- [Safety constraint, e.g.: "Account balance must never go negative"]
- [Consistency rule, e.g.: "Sum of line items must equal order total"]
- [Compatibility invariant when applicable, e.g.: "Events written by version N+1 must remain deserializable by version N for one release cycle"]

## Compatibility and Transition *(required when Change type is not "new surface")*

<!--
  Required when the feature modifies, replaces, or removes an existing boundary:
  public or internal API, event payload, stored data shape, user-facing contract,
  CLI flag, configuration key, or any observable behavior consumed by other teams
  or long-lived clients.
  For a purely additive new surface, write "N/A: purely additive new surface"
  and skip the rest of this section.
-->

- **Existing consumers**: [Known producers, consumers, or clients of the current behavior that must be considered. Include delayed consumers such as queue backlogs, cached clients, or mobile apps.]
- **Backward compatibility stance**: [strict (no break), tolerant window (old and new coexist for N releases), or break with deprecation period of at least X]
- **Coexistence requirement**: [Whether version N and N+1 must run simultaneously against shared state, and for how long. State the minimum coexistence window in business terms, not implementation terms.]
- **Rollback requirement**: [Whether the prior version must be able to safely read state written by the new version, or whether forward-fix is acceptable. Include the maximum acceptable rollback time window.]
- **Deprecation signal**: [How consumers of the old path are informed that it will be removed. Stated as a requirement, not as an implementation mechanism.]
- **Telemetry requirement**: [What signal confirms that old consumers have stopped using the old path. Required before any destructive removal step is authorized.]

## Related Specs

<!--
  Bidirectional links to related specifications.
  Migration specs that affect or depend on this feature.
  Other feature specs with shared dependencies.
-->

- [MS-001: Migration name](../migrations/<short-name>/spec.md) - [Relationship description]
- [FS-001: Feature name](../features/<short-name>/spec.md) - [Relationship description]
