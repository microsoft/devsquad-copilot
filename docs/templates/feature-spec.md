
# Feature Specification: [FEATURE_NAME]

**Created on**: [DATE]  
**Status**: Draft  

## Executive Summary

<!--
  Condensation of the spec into 3-5 key points.
  Serves as a quick reference for agents and developers.
  Update whenever the spec changes significantly.
-->

- **Objective**: [One sentence describing what the feature does]
- **Primary user**: [Who uses it]
- **Value delivered**: [Why this matters]
- **Scope**: [What is included / excluded]
- **Primary success criterion**: [Most important metric]

## Out of Scope *(required)*

<!--
  Explicitly declare what is NOT part of this feature.
  Protects scope against implicit expansion and aligns expectations.
  Minimum 1 item.
-->

- [What is out of scope and reason for exclusion]

## Assumptions

<!--
  Document reasonable defaults assumed during specification.
  Example: "Session-based authentication (web standard, no explicit requirement)"
-->

- [Assumption and basis for assuming it]

## User Scenarios & Tests *(required)*

<!--
  IMPORTANT: User stories must be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning that if you implement only ONE of them,
  you still have an MVP (Minimum Viable Product) that delivers value.
  
  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as an independent slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - [Brief Title] (Priority: P1)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently - e.g.: "Can be fully tested by [specific action] and delivers [specific value]"]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected result]
2. **Given** [initial state], **When** [action], **Then** [expected result]

---

### User Story 2 - [Brief Title] (Priority: P2)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected result]

---

### User Story 3 - [Brief Title] (Priority: P3)

[Describe this user journey in plain language]

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
  These should be technology-independent and measurable.
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
| CC-001 | [Main happy path] | [Valid input data] | [Expected result] |
| CC-002 | [Error scenario] | [Invalid or incomplete data] | [Error message or behavior] |
| CC-003 | [Edge case] | [Boundary or extreme condition] | [Expected behavior] |

<!--
  These criteria serve as a contract between spec and implementation.
  The agent must verify the implementation against these cases.
-->

## Related Specs

<!--
  Bidirectional links to related specifications.
  Migration specs that affect or depend on this feature.
  Other feature specs with shared dependencies.
-->

- [MS-001: Migration name](../migrations/<short-name>/spec.md) - [Relationship description]
- [FS-001: Feature name](../features/<short-name>/spec.md) - [Relationship description]
